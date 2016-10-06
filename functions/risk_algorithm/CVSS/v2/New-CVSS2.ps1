function New-CVSS2
{
  <#
      .SYNOPSIS
      Describe purpose of "New-CVSS2" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      New-CVSS2
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online New-CVSS2

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.

      .NOTES
      5.5 should be okay for risk. reassesss this at a later date
  #>

  # Constants used in the formula
  $CVSS = @{} # initialize HashTable

  $CVSS.CVSSVersionIdentifier = "CVSS:2.0"
  $CVSS.exploitabilityCoefficient = 20

  # A regular expression to validate that a CVSS 3.0 vector string is well formed. It checks metrics and metric
  # values. It does not check that a metric is specified more than once and it does not check that all base
  # metrics are present. These checks need to be performed separately.

  $CVSS.vectorStringRegex_20 = New-Object System.Text.RegularExpressions.Regex '^CVSS:2\.0\/((AV:[LAN]|AC:[HML]|AU:[MSN]|C:[NPC]|I:[NPC]|A:[NPC]|E:([UFH]|POC|ND)|RL:([WU]|OF|TF|ND)|RC:([C]|UC|UR|ND)|CDP:([NLH]|LM|MH|ND)|TD:([NLMH]|ND)|CR:([LMH]|ND)|IR:([LMH]|ND)|AR:([LMH]|ND))\/)*(AV:[LAN]|AC:[HML]|AU:[MSN]|C:[NPC]|I:[NPC]|A:[NPC]|E:([UFH]|POC|ND)|RL:([WU]|OF|TF|ND)|RC:([C]|UC|UR|ND)|CDP:([NLH]|LM|MH|ND)|TD:([NLMH]|ND)|CR:([LMH]|ND)|IR:([LMH]|ND)|AR:([LMH]|ND))$', 'IgnoreCase'

  # Associative arrays mapping each metric value to the constant defined in the CVSS scoring formula in the CVSS v2.0
  # specification.

  $CVSS.Weight = @{
    AV = @{ L = 0.395; A = 0.646; N = 1.0; };
    AC = @{ H = 0.35; M = 0.61; L = 0.71; };
    AU = @{ M = 0.45; S = 0.56; N = 0.704; };
    CIA = @{ N = 0.0; P = 0.275; C = 0.660; }; # C, I and A have the same weights

    E = @{ U = 0.85; POC = 0.9; F = 0.95; H = 1.00; ND = 1.00; };
    RL = @{ OF = 0.87; TF = 0.90; W = 0.95; ND = 1.00; };
    RC = @{ UC = 0.90; UR = 0.95; C = 1.00; ND = 1.00; };

    CDP = @{ N = 0; L = 0.1; LM = 0.3; MH = 0.4; H = 0.5; ND = 0; };
    TD = @{ N = 0; L = 0.25; M = 0.75; H = 1.00; ND = 1.00; };

    CIAR = @{ L = 0.5; M = 1.0; H = 1.51; ND = 1.0; }; # CR, IR and AR have the same weights
  }

  # Severity rating bands, as defined in the CVSS v3.0 specification.
  $CVSS.severityRatings  = @(
    @{ name = "None";     bottom = 0.0; top =  0.0;},
    @{ name = "Low";      bottom = 0.1; top =  3.9;},
    @{ name = "Medium";   bottom = 4.0; top =  6.9;},
    @{ name = "High";     bottom = 7.0; top =  8.9;},
    @{ name = "Critical"; bottom = 9.0; top = 10.0;}
  )

  <#  ** CVSS.severityRating **
      *
      * Given a CVSS score, returns the name of the severity rating as defined in the CVSS standard.
      * The input needs to be a number between 0.0 to 10.0, to one decimal place of precision.
      *
      * The following error values may be returned instead of a severity rating name:
      *   NaN (JavaScript "Not a Number") - if the input is not a number.
      *   undefined - if the input is a number that is not within the range of any defined severity rating.
  #>
  Add-Member -InputObject $CVSS -MemberType ScriptMethod -name 'severityRating' -value {
    Param ($score)

    $severityRatingLength = $this.severityRatings.length

    $validatedScore = [convert]::ToDecimal($score)

    #if (isNaN($validatedScore)) {
    #    return $validatedScore
    #}

    for ($i = 0; $i -lt $severityRatingLength; $i++) {
      if ($score -ge $this.severityRatings[$i].bottom -and $score -le $this.severityRatings[$i].top) {
        return $this.severityRatings[$i].name
      }
    }

    return $null
  }

  <#  ** CVSS.roundUp1 **
      *
      * Rounds up the number passed as a parameter to 1 decimal place and returns the result.
      *
      * Standard JavaScript errors thrown when arithmetic operations are performed on non-numbers will be returned if the
      * given input is not a number.
  #>
  Add-Member -InputObject $CVSS ScriptMethod roundUp1 {
    Param($d)
    return [math]::Round($d * 10) / 10
  }

  <#  ** CVSS.fImpact **
      *
      * Checks to see if the provided impact score is 0
      * if 0, it returns 0 if not it returns 1.176
  #>
  Add-Member -InputObject $CVSS ScriptMethod fImpact {
    Param($impact)

    if ($impact -eq 0)
    {
      return 0
    }
    else
    {
      return 1.176
    }
  }

  <#  ** CVSS.calculateCVSSFromMetrics **
      *
      * Takes Base, Temporal and Environmental metric values as individual parameters. Their values are in the short format
      * defined in the CVSS v2.0 standard definition of the Vector String. For example, the AccessComplexity parameter
      * should be "H", "M" or "L".
      *
      * Returns Base, Temporal and Environmental scores, severity ratings, and an overall Vector String. All Base metrics
      * are required to generate this output. All Temporal and Environmental metric values are optional. Any that are not
      * passed default to "ND" ("Not Defined").
      *
      * The output is an object which always has a property named "success".
      *
      * If no errors are encountered, success is Boolean "true", and the following other properties are defined containing
      * scores, severities and a vector string:
      *   baseMetricScore, baseSeverity,
      *   temporalMetricScore, temporalSeverity,
      *   environmentalMetricScore, environmentalSeverity,
      *   vectorString
      *
      * If errors are encountered, success is Boolean "false", and the following other properties are defined:
      *   errorType - a string indicating the error. Either:
      *                 "MissingBaseMetric", if at least one Base metric has not been defined; or
      *                 "UnknownMetricValue", if at least one metric value is invalid.
      *   errorMetrics - an array of strings representing the metrics at fault. The strings are abbreviated versions of the
      *                  metrics, as defined in the CVSS v2.0 standard definition of the Vector String.
      *
  #>
  Add-Member -InputObject $CVSS ScriptMethod calculateCVSSFromMetrics {
    Param(
      $AccessVector,
      $AccessComplexity,
      $Authentication,
      $Confidentiality,
      $Integrity,
      $Availability,
      $Exploitability,
      $RemediationLevel,
      $ReportConfidence,
      $CollateralDamagePotential,
      $TargetDistribution,
      $ConfidentialityRequirement,
      $IntegrityRequirement,
      $AvailabilityRequirement
    )

    # If input validation fails, this array is populated with strings indicating which metrics failed validation.
    [System.Collections.ArrayList]$badMetrics = @()

    # ENSURE ALL BASE METRICS ARE DEFINED
    #
    # We need values for all Base Score metrics to calculate scores.
    # If any Base Score parameters are undefined, create an array of missing metrics and return it with an error.
    if ($AccessVector -eq $null -or $AccessVector -eq "") {$badMetrics.Add("AV") | Out-Null}
    if ($AccessComplexity -eq $null -or $AccessComplexity -eq "") {$badMetrics.Add("AC") | Out-Null}
    if ($Authentication -eq $null -or $Authentication -eq "") {$badMetrics.Add("AU") | Out-Null}
    if ($Confidentiality -eq $null -or $Confidentiality -eq "") {$badMetrics.Add("C") | Out-Null}
    if ($Integrity -eq $null -or $Integrity -eq "") {$badMetrics.Add("I") | Out-Null}
    if ($Availability -eq $null -or $Availability -eq "") {$badMetrics.Add("A") | Out-Null}

    if ($badMetrics.Count -gt 0) {
      return @{ Success = $false; errorType = "MissingBaseMetric"; errorMetrics = $badMetrics; }
    }

    # STORE THE METRIC VALUES THAT WERE PASSED AS PARAMETERS
    #
    # Temporal and Environmental metrics are optional, so set them to "ND" ("Not Defined") if no value was passed.
    # Base
    $AV = $AccessVector
    $AC = $AccessComplexity
    $AU = $Authentication
    $C = $Confidentiality
    $I  = $Integrity
    $A  = $Availability

    # Temporal
    $E =   if ($Exploitability){$Exploitability}else{"ND"}
    $RL =  if ($RemediationLevel){$RemediationLevel}else{"ND"}
    $RC =  if ($ReportConfidence){$ReportConfidence}else{"ND"}

    # Environmental
    $CDP =  if ($CollateralDamagePotential){$CollateralDamagePotential}else{"ND"}
    $TD =  if ($TargetDistribution){$TargetDistribution}else{"ND"}
    $CR = if ($ConfidentialityRequirement){$ConfidentialityRequirement}else{"ND"}
    $IR = if ($IntegrityRequirement){$IntegrityRequirement}else{"ND"}
    $AR = if ($AvailabilityRequirement){$AvailabilityRequirement}else{"ND"}

    # CHECK VALIDITY OF METRIC VALUES
    #
    # Use the Weight object to ensure that, for every metric, the metric value passed is valid.
    # If any invalid values are found, create an array of their metrics and return it with an error.
    # Base
    if (!$this.Weight.AV.ContainsKey($AV))   { $badMetrics.Add("AV") | Out-Null }
    if (!$this.Weight.AC.ContainsKey($AC))   { $badMetrics.Add("AC") | Out-Null }
    if (!$this.Weight.AU.ContainsKey($AU)) { $badMetrics.Add("AU") | Out-Null }
    if (!$this.Weight.CIA.ContainsKey($C))   { $badMetrics.Add("C") | Out-Null }
    if (!$this.Weight.CIA.ContainsKey($I))   { $badMetrics.Add("I") | Out-Null }
    if (!$this.Weight.CIA.ContainsKey($A))   { $badMetrics.Add("A") | Out-Null }

    # Temporal
    if (!($E -eq "ND" -or $this.Weight.E.ContainsKey($E)))     { $badMetrics.Add("E") | Out-Null }
    if (!($RL -eq "ND" -or $this.Weight.RL.ContainsKey($RL)))   { $badMetrics.Add("RL") | Out-Null }
    if (!($RC -eq "ND" -or $this.Weight.RC.ContainsKey($RC)))   { $badMetrics.Add("RC") | Out-Null }

    # Environmental
    if (!($CDP  -eq "ND" -or $this.Weight.CDP.ContainsKey($CDP)))  { $badMetrics.Add("CDP") | Out-Null }
    if (!($TD  -eq "ND" -or $this.Weight.TD.ContainsKey($TD)))  { $badMetrics.Add("TD") | Out-Null }
    if (!($CR  -eq "ND" -or $this.Weight.CIAR.ContainsKey($CR)))  { $badMetrics.Add("CR") | Out-Null }
    if (!($IR -eq "ND" -or $this.Weight.CIAR.ContainsKey($IR)))   { $badMetrics.Add("IR") | Out-Null }
    if (!($AR -eq "ND" -or $this.Weight.CIAR.ContainsKey($AR)))   { $badMetrics.Add("AR") | Out-Null }

    if ($badMetrics.Count > 0) {
      return @{ Success = $false; errorType = "UnknownMetricValue"; errorMtrics = $badMetrics}
    }

    # GATHER WEIGHTS FOR ALL METRICS
    # Base
    $metricWeightAV  = $this.Weight.AV[$AV]
    $metricWeightAC  = $this.Weight.AC[$AC]
    $metricWeightAU  = $this.Weight.AU[$AU]
    $metricWeightC   = $this.Weight.CIA[$C]
    $metricWeightI   = $this.Weight.CIA[$I]
    $metricWeightA   = $this.Weight.CIA[$A]

    # Temporal
    $metricWeightE   = $this.Weight.E[$E]
    $metricWeightRL  = $this.Weight.RL[$RL]
    $metricWeightRC  = $this.Weight.RC[$RC]

    # Environmental
    $metricWeightCDP = $this.Weight.CDP[$CDP]
    $metricWeightTD  = $this.Weight.TD[$TD]
    $metricWeightCR  = $this.Weight.CIAR[$CR]
    $metricWeightIR  = $this.Weight.CIAR[$IR]
    $metricWeightAR  = $this.Weight.CIAR[$AR]

    # CALCULATE THE CVSS BASE SCORE
    $exploitabalityScore = $this.exploitabilityCoefficient * $metricWeightAV * $metricWeightAC * $metricWeightAU
    $impactScore = 10.41*(1 - ((1 - $metricWeightC) * (1 - $metricWeightI) * (1 - $metricWeightA)))
    #$fImpactScore = if ($impactScore -eq 0){ 0 } else { 1.176 }
    $baseScore =  $this.roundUp1(((0.6*$impactScore) + (0.4*$exploitabalityScore) - 1.5) * $($this.fImpact($impactScore)) )

    # CALCULATE THE CVSS TEMPORAL SCORE
    $temporalScore = $this.roundUp1($baseScore*$metricWeightE*$metricWeightRL*$metricWeightRC)

    # CALCULATE THE CVSS ENVIRONMENTAL SCORE
    $adjustedImpact = [Math]::Min(10.41*(1 - ((1 - $metricWeightC*$metricWeightCR)*(1 - $metricWeightI*$metricWeightIR)*(1 - $metricWeightA*$metricWeightAR))),10)
    $adjustedBase = $this.roundUp1(((0.6*$adjustedImpact) + (0.4*$exploitabalityScore) - 1.5) * $($this.fImpact($adjustedImpact)))
    $adjustedTemporal = $this.roundUp1($adjustedBase*$metricWeightE*$metricWeightRL*$metricWeightRC)
    $envScore = $this.roundUp1(($adjustedTemporal+(10 - $adjustedTemporal)*$metricWeightCDP) * $metricWeightTD)

    # CONSTRUCT THE VECTOR STRING
    $vectorString = $this.CVSSVersionIdentifier +
      "/AV:" + $AV +
      "/AC:" + $AC +
      "/AU:" + $AU +
      "/C:" + $C +
      "/I:" + $I +
      "/A:" + $A

    # Temporal
    if ($E  -ne "ND")  {$vectorString = $vectorString + "/E:" + $E}
    if ($RL -ne "ND")  {$vectorString = $vectorString + "/RL:" + $RL}
    if ($RC -ne "ND")  {$vectorString = $vectorString + "/RC:" + $RC}

    # Environmental
    if ($CDP  -ne "ND") {$vectorString = $vectorString + "/CDP:" + $CDP}
    if ($TD  -ne "ND") {$vectorString = $vectorString + "/TD:" + $TD}
    if ($CR  -ne "ND") {$vectorString = $vectorString + "/CR:" + $CR}
    if ($IR  -ne "ND") {$vectorString = $vectorString + "/IR:" + $IR}
    if ($AR  -ne "ND") {$vectorString = $vectorString + "/AR:" + $AR}

    # Return an object containing the scores for all three metric groups, and an overall vector string.
      return @{
        Success = $true;
        baseMetricScore = $(([math]::Round($baseScore, 1), [system.midpointrounding]::AwayFromZero)[0].ToString());
        baseSeverity = $this.severityRating( $(([math]::Round($baseScore, 1), [System.MidpointRounding]::AwayFromZero)[0]));

        temporalMetricScore = $(([math]::Round($temporalScore, 1), [system.midpointrounding]::AwayFromZero)[0].ToString());
        temporalSeverity = $this.severityRating( $(([math]::Round($temporalScore, 1), [System.MidpointRounding]::AwayFromZero)[0]));

        environmentalMetricScore = $(([math]::Round($envScore, 1), [system.midpointrounding]::AwayFromZero)[0].ToString());
        environmentalSeverity = $this.severityRating( $(([math]::Round($envScore, 1), [System.MidpointRounding]::AwayFromZero)[0]));

        vectorString = $vectorString
      }
  }

   <#  ** CVSS.calculateCVSSFromVector **
       *
       * Takes Base, Temporal and Environmental metric values as a single string in the Vector String format defined
       * in the CVSS v2.0 standard definition of the Vector String.
       *
       * Returns Base, Temporal and Environmental scores, severity ratings, and an overall Vector String. All Base metrics
       * are required to generate this output. All Temporal and Environmental metric values are optional. Any that are not
       * passed default to "ND" ("Not Defined").
       *
       * See the comment for the CVSS.calculateCVSSFromMetrics function for details on the function output. In addition to
       * the error conditions listed for that function, this function can also return:
       *   "MalformedVectorString", if the Vector String passed is does not conform to the format in the standard; or
       *   "MultipleDefinitionsOfMetric", if the Vector String is well formed but defines the same metric (or metrics),
       *                                  more than once.
  #>
  Add-Member -InputObject $CVSS -MemberType ScriptMethod -Name 'calculateCVSSFromVector' -Value {
      Param($vectorString)
      $metricValues = @{
        AV = $null; AC = $null; AU = $null;
        C = $null; I = $null; A = $null;
        E = $null; RL = $null; RC = $null;
        CDP = $null; TD = $null;
        CR = $null; IR = $null; AR = $null
      }

      # If input validation fails, this array is populated with strings indicating which metrics failed validation.
      [System.Collections.ArrayList]$badMetrics = @()

      if (!($this.vectorStringRegex_20.IsMatch($vectorString))) {
        return @{ Success = $false; errorType = "MalformedVectorString"}
      }

      # Add 1 to the length of the CVSS Identifier to include the first slash after the Identifer
      # So that when the split happens a $null value is not created
      $metricNameValue = $vectorString.Substring($this.CVSSVersionIdentifier.length + 1).split("/") #-join ",").Trim(",").split(",")

      foreach($i in $metricNameValue) {
        if ($metricNameValue.Contains($i)) { # Validating Input

          $singleMetric = $i.split(":")

          if ($metricValues[$singleMetric[0]] -eq $null) {
            $metricValues[$singleMetric[0]] = $singleMetric[1]
          } else {
            $badMetrics.Add($singleMetric[0]);
          }
        }
      }

     if ($badMetrics.Count -gt 0) {
        return @{ Success = $false; errorType = "MultipleDefinitionsOfMetric"; errorMetrics = $badMetrics }
     }

     return $this.calculateCVSSFromMetrics(
      $metricValues.AV,  $metricValues.AC,  $metricValues.AU,
      $metricValues.C,   $metricValues.I,   $metricValues.A,
      $metricValues.E,   $metricValues.RL,  $metricValues.RC,
      $metricValues.CDP,  $metricValues.TD,
      $metricValues.CR,  $metricValues.IR,  $metricValues.AR)
  }

  #return $object
  return $CVSS
}

#$CVSSobj = New-CVSS2
#$CVSSobj.calculateCVSSFromVector("CVSS:2.0/AV:N/AC:L/AU:N/C:N/I:N/A:C/E:F/RL:OF/RC:C/CDP:H/TD:H/CR:M/IR:M/AR:H")
#$CVSS.calculateCVSSFromMetrics()
