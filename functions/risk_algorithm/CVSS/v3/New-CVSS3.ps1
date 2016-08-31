function New-CVSS3 () {
<#
.SYNOPSIS
    Creates a CVSS version 3 object containing all the algorithms and function required to automate analysis

.PARAMETER none

.EXAMPLE
    $cvss = init-CVSS3()

.LINK

.VERSION
    1.0.0 (04.12.2016)
        -Intial Release
    1.0.1 (08/31/2016)
        -Removed Whitespace
#>

# Constants used in the formula

$CVSS = @{}

$CVSS.CVSSVersionIdentifier = "CVSS:3.0"
$CVSS.exploitabilityCoefficient = 8.22
$CVSS.scopeCoefficient = 1.08

# A regular expression to validate that a CVSS 3.0 vector string is well formed. It checks metrics and metric
# values. It does not check that a metric is specified more than once and it does not check that all base
# metrics are present. These checks need to be performed separately.

$CVSS.vectorStringRegex_30 = New-Object System.Text.RegularExpressions.Regex '^CVSS:3\.0\/((AV:[NALP]|AC:[LH]|PR:[UNLH]|UI:[NR]|S:[UC]|[CIA]:[NLH]|E:[XUPFH]|RL:[XOTWU]|RC:[XURC]|[CIA]R:[XLMH]|MAV:[XNALP]|MAC:[XLH]|MPR:[XUNLH]|MUI:[XNR]|MS:[XUC]|M[CIA]:[XNLH])\/)*(AV:[NALP]|AC:[LH]|PR:[UNLH]|UI:[NR]|S:[UC]|[CIA]:[NLH]|E:[XUPFH]|RL:[XOTWU]|RC:[XURC]|[CIA]R:[XLMH]|MAV:[XNALP]|MAC:[XLH]|MPR:[XUNLH]|MUI:[XNR]|MS:[XUC]|M[CIA]:[XNLH])$', 'IgnoreCase'

# Associative arrays mapping each metric value to the constant defined in the CVSS scoring formula in the CVSS v3.0
# specification.

$CVSS.Weight = @{
  AV =   @{ N = 0.85;  A = 0.62;  L = 0.55;  P = 0.2;};
  AC =   @{ H = 0.44;  L = 0.77;};
  PR =   @{ U =       @{N = 0.85;  L = 0.62;  H = 0.27;};         # These values are used if Scope is Unchanged
            C =       @{N = 0.85;  L = 0.68;  H = 0.5;};           # These values are used if Scope is Changed
         };
  UI =   @{ N = 0.85;  R = 0.62;};
  S =    @{ U = 6.42;  C = 7.52;};                             # Note: not defined as constants in specification
  CIA =  @{ N = 0;     L = 0.22;  H = 0.56;};                   # C, I and A have the same weights

  E =    @{ X = 1;     U = 0.91;  P = 0.94;  F = 0.97;  H = 1;};
  RL =   @{ X = 1;     O = 0.95;  T = 0.96;  W = 0.97;  U = 1;};
  RC =   @{ X = 1;     U = 0.92;  R = 0.96;  C = 1;};

  CIAR = @{ X = 1;     L = 0.5;   M = 1;     H = 1.5;};           # CR, IR and AR have the same weights
}

# Severity rating bands, as defined in the CVSS v3.0 specification.

$CVSS.severityRatings  = @(
                          @{ name = "None";     bottom = 0.0; top =  0.0;},
                          @{ name = "Low";      bottom = 0.1; top =  3.9;},
                          @{ name = "Medium";   bottom = 4.0; top =  6.9;},
                          @{ name = "High";     bottom = 7.0; top =  8.9;},
                          @{ name = "Critical"; bottom = 9.0; top = 10.0;}
                         )

<# ** CVSS.severityRating **
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

<# ** CVSS.roundUp1 **
 *
 * Rounds up the number passed as a parameter to 1 decimal place and returns the result.
 *
 * Standard JavaScript errors thrown when arithmetic operations are performed on non-numbers will be returned if the
 * given input is not a number.
#>


Add-Member -InputObject $CVSS ScriptMethod roundUp1 {
    Param($d)
    return [math]::ceiling($d * 10) / 10
}

<# ** CVSS.calculateCVSSFromMetrics **
 *
 * Takes Base, Temporal and Environmental metric values as individual parameters. Their values are in the short format
 * defined in the CVSS v3.0 standard definition of the Vector String. For example, the AttackComplexity parameter
 * should be either "H" or "L".
 *
 * Returns Base, Temporal and Environmental scores, severity ratings, and an overall Vector String. All Base metrics
 * are required to generate this output. All Temporal and Environmental metric values are optional. Any that are not
 * passed default to "X" ("Not Defined").
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
 *                  metrics, as defined in the CVSS v3.0 standard definition of the Vector String.
 *
#>

Add-Member -InputObject $CVSS ScriptMethod calculateCVSSFromMetrics {
    Param(
        $AttackVector,
        $AttackComplexity,
        $PrivilegesRequired,
        $UserInteraction,
        $Scope,
        $Confidentiality,
        $Integrity,
        $Availability,
        $ExploitCodeMaturity,
        $RemediationLevel,
        $ReportConfidence,
        $ConfidentialityRequirement,
        $IntegrityRequirement,
        $AvailabilityRequirement,
        $ModifiedAttackVector,
        $ModifiedAttackComplexity,
        $ModifiedPrivilegesRequired,
        $ModifiedUserInteraction,
        $ModifiedScope,
        $ModifiedConfidentiality,
        $ModifiedIntegrity,
        $ModifiedAvailability
		)

  # If input validation fails, this array is populated with strings indicating which metrics failed validation.
  [System.Collections.ArrayList]$badMetrics = @()

  # ENSURE ALL BASE METRICS ARE DEFINED
  #
  # We need values for all Base Score metrics to calculate scores.
  # If any Base Score parameters are undefined, create an array of missing metrics and return it with an error.

  if ($AttackVector -eq $null -or $AttackVector -eq "") {$badMetrics.Add("AV")}
  if ($AttackComplexity -eq $null -or $AttackComplexity -eq "") {$badMetrics.Add("AC")}
  if ($PrivilegesRequired -eq $null -or $PrivilegesRequired -eq "") {$badMetrics.Add("PR")}
  if ($UserInteraction -eq $null -or $UserInteraction -eq "") {$badMetrics.Add("UI")}
  if ($Scope -eq $null -or $Scope -eq "") {$badMetrics.Add("S")}
  if ($Confidentiality -eq $null -or $Confidentiality -eq "") {$badMetrics.Add("C")}
  if ($Integrity -eq $null -or $Integrity -eq "") {$badMetrics.Add("I")}
  if ($Availability -eq $null -or $Availability -eq "") {$badMetrics.Add("A")}

  if ($badMetrics.Count -gt 0) {
    return @{ Success = $false; errorType = "MissingBaseMetric"; errorMetrics = $badMetrics; }
	}

		# STORE THE METRIC VALUES THAT WERE PASSED AS PARAMETERS
  #
  # Temporal and Environmental metrics are optional, so set them to "X" ("Not Defined") if no value was passed.

  $AV = $AttackVector
  $AC = $AttackComplexity
  $PR = $PrivilegesRequired
  $UI = $UserInteraction
  $S  = $Scope
  $C  = $Confidentiality
  $I  = $Integrity
  $A  = $Availability

  $E =   if ($ExploitCodeMaturity){$ExploitCodeMaturity}else{"X"}
  $RL =  if ($RemediationLevel){$RemediationLevel}else{"X"}
  $RC =  if ($ReportConfidence){$ReportConfidence}else{"X"}

  $CR =  if ($ConfidentialityRequirement){$ConfidentialityRequirement}else{"X"}
  $IR =  if ($IntegrityRequirement){$IntegrityRequirement}else{"X"}
  $AR =  if ($AvailabilityRequirement) {$AvailabilityRequirement}else{"X"}
  $MAV = if ($ModifiedAttackVector){$ModifiedAttackVector}else{"X"}
  $MAC = if ($ModifiedAttackComplexity){$ModifiedAttackComplexity}else{"X"}
  $MPR = if ($ModifiedPrivilegesRequired){$ModifiedPrivilegesRequired}else{"X"}
  $MUI = if ($ModifiedUserInteraction){$ModifiedUserInteraction}else{"X"}
  $MS =  if ($ModifiedScope){$ModifiedScope}else{"X"}
  $MC =  if ($ModifiedConfidentiality){$ModifiedConfidentiality}else{"X"}
  $MI =  if ($ModifiedIntegrity){$ModifiedIntegrity}else{"X"}
  $MA =  if ($ModifiedAvailability){$ModifiedAvailability}else{"X"}

  # CHECK VALIDITY OF METRIC VALUES
  #
  # Use the Weight object to ensure that, for every metric, the metric value passed is valid.
  # If any invalid values are found, create an array of their metrics and return it with an error.
  #
  # The Privileges Required (PR) weight depends on Scope, but when checking the validity of PR we must not assume
  # that the given value for Scope is valid. We therefore always look at the weights for Unchanged Scope when
  # performing this check. The same applies for validation of Modified Privileges Required (MPR).
  #
  # The Weights object does not contain "X" ("Not Defined") values for Environmental metrics because we replace them
  # with their Base metric equivalents later in the function. For example, an MAV of "X" will be replaced with the
  # value given for AV. We therefore need to explicitly allow a value of "X" for Environmental metrics.

  if (!$this.Weight.AV.ContainsKey($AV))   { $badMetrics.Add("AV") }
  if (!$this.Weight.AC.ContainsKey($AC))   { $badMetrics.Add("AC") }
  if (!$this.Weight.PR.U.ContainsKey($PR)) { $badMetrics.Add("PR") }
  if (!$this.Weight.UI.ContainsKey($UI))   { $badMetrics.Add("UI") }
  if (!$this.Weight.S.ContainsKey($S))     { $badMetrics.Add("S") }
  if (!$this.Weight.CIA.ContainsKey($C))   { $badMetrics.Add("C") }
  if (!$this.Weight.CIA.ContainsKey($I))   { $badMetrics.Add("I") }
  if (!$this.Weight.CIA.ContainsKey($A))   { $badMetrics.Add("A") }

  if (!$this.Weight.E.ContainsKey($E))     { $badMetrics.Add("E") }
  if (!$this.Weight.RL.ContainsKey($RL))   { $badMetrics.Add("RL") }
  if (!$this.Weight.RC.ContainsKey($RC))   { $badMetrics.Add("RC") }

  if (!($CR  -eq "X" -or $this.Weight.CIAR.ContainsKey($CR)))  { $badMetrics.Add("CR") }
  if (!($IR  -eq "X" -or $this.Weight.CIAR.ContainsKey($IR)))  { $badMetrics.Add("IR") }
  if (!($AR  -eq "X" -or $this.Weight.CIAR.ContainsKey($AR)))  { $badMetrics.Add("AR") }
  if (!($MAV -eq "X" -or $this.Weight.AV.ContainsKey($MAV)))   { $badMetrics.Add("MAV") }
  if (!($MAC -eq "X" -or $this.Weight.AC.ContainsKey($MAC)))   { $badMetrics.Add("MAC") }
  if (!($MPR -eq "X" -or $this.Weight.PR.U.ContainsKey($MPR))) { $badMetrics.Add("MPR") }
  if (!($MUI -eq "X" -or $this.Weight.UI.ContainsKey($MUI)))   { $badMetrics.Add("MUI") }
  if (!($MS  -eq "X" -or $this.Weight.S.ContainsKey($MS)))     { $badMetrics.Add("MS") }
  if (!($MC  -eq "X" -or $this.Weight.CIA.ContainsKey($MC)))   { $badMetrics.Add("MC") }
  if (!($MI  -eq "X" -or $this.Weight.CIA.ContainsKey($MI)))   { $badMetrics.Add("MI") }
  if (!($MA  -eq "X" -or $this.Weight.CIA.ContainsKey($MA)))   { $badMetrics.Add("MA") }

  if ($badMetrics.Count > 0) {
    return @{ Success = $false; errorType = "UnknownMetricValue"; errorMtrics = $badMetrics}
  }

  # GATHER WEIGHTS FOR ALL METRICS

  $metricWeightAV  = $this.Weight.AV[$AV]
  $metricWeightAC  = $this.Weight.AC[$AC]
  $metricWeightPR  = $this.Weight.PR[$S][$PR]  # PR depends on the value of Scope (S).
  $metricWeightUI  = $this.Weight.UI[$UI]
  $metricWeightS   = $this.Weight.S[$S]
  $metricWeightC   = $this.Weight.CIA[$C]
  $metricWeightI   = $this.Weight.CIA[$I]
  $metricWeightA   = $this.Weight.CIA[$A]

  $metricWeightE   = $this.Weight.E[$E]
  $metricWeightRL  = $this.Weight.RL[$RL]
  $metricWeightRC  = $this.Weight.RC[$RC]

  # For metrics that are modified versions of Base Score metrics, e.g. Modified Attack Vector, use the value of
  # the Base Score metric if the modified version value is "X" ("Not Defined").
  $metricWeightCR  = $this.Weight.CIAR[$CR]
  $metricWeightIR  = $this.Weight.CIAR[$IR]
  $metricWeightAR  = $this.Weight.CIAR[$AR]
  $metricWeightMAV = $this.Weight.AV[$(if ($MAV -ne "X") {$MAV} else {$AV})]
  $metricWeightMAC = $this.Weight.AC[$(if ($MAC -ne "X") {$MAC} else {$AC})]
  $metricWeightMPR = $this.Weight.PR[$(if ($MS  -ne "X") {$MS} else {$S})][$(if ($MPR -ne "X") {$MPR} else {$PR})]  # Depends on MS.
  $metricWeightMUI = $this.Weight.UI[$(if ($MUI -ne "X") {$MUI} else {$UI})]
  $metricWeightMS  = $this.Weight.S[$(if ($MS -ne "X") {$MS} else {$S})]
  $metricWeightMC  = $this.Weight.CIA[$(if ($MC  -ne "X") {$MC} else {$C})]
  $metricWeightMI  = $this.Weight.CIA[$(if ($MI  -ne "X") {$MI} else {$I})]
  $metricWeightMA  = $this.Weight.CIA[$(if ($MA  -ne "X") {$MA} else {$A})]


  # CALCULATE THE CVSS BASE SCORE

  $baseScore
  $impactSubScore
  $exploitabalitySubScore = $this.exploitabilityCoefficient * $metricWeightAV * $metricWeightAC * $metricWeightPR * $metricWeightUI
  $impactSubScoreMultiplier = (1 - ((1 - $metricWeightC) * (1 - $metricWeightI) * (1 - $metricWeightA)))

  if ($S -eq 'U') {
    $impactSubScore = $metricWeightS * $impactSubScoreMultiplier
  } else {
    $impactSubScore = $metricWeightS * ($impactSubScoreMultiplier - 0.029) - 3.25 * [math]::Pow($impactSubScoreMultiplier - 0.02, 15)
  }

  if ($impactSubScore -le 0) {
    $baseScore = 0
  } else {
    if ($S -eq 'U') {
      $baseScore = $this.roundUp1([math]::Min(($exploitabalitySubScore + $impactSubScore), 10))
    } else {
      $baseScore = $this.roundUp1([math]::Min(($exploitabalitySubScore + $impactSubScore) * $this.scopeCoefficient, 10))
    }
  }

  # CALCULATE THE CVSS TEMPORAL SCORE

  $temporalScore = $this.roundUp1($baseScore * $metricWeightE * $metricWeightRL * $metricWeightRC)

  # CALCULATE THE CVSS ENVIRONMENTAL SCORE
  #
  # - envExploitabalitySubScore recalculates the Base Score Exploitability sub-score using any modified values from the
  #   Environmental metrics group in place of the values specified in the Base Score, if any have been defined.
  # - envAdjustedImpactSubScore recalculates the Base Score Impact sub-score using any modified values from the
  #   Environmental metrics group in place of the values specified in the Base Score, and any additional weightings
  #   given in the Environmental metrics group.

  $envScore
  $envModifiedImpactSubScore
  $envModifiedExploitabalitySubScore = $this.exploitabilityCoefficient * $metricWeightMAV * $metricWeightMAC * $metricWeightMPR * $metricWeightMUI

  $envImpactSubScoreMultiplier = [math]::Min(1 - (
                                                 (1 - $metricWeightMC * $metricWeightCR) *
                                                 (1 - $metricWeightMI * $metricWeightIR) *
                                                 (1 - $metricWeightMA * $metricWeightAR)), 0.915)

  if ($MS -eq "U" -or ($MS -eq "X" -and $S -eq "U")) {
    $envModifiedImpactSubScore = $metricWeightMS * $envImpactSubScoreMultiplier
    $envScore = $this.roundUp1($this.roundUp1([math]::Min($envModifiedImpactSubScore + $envModifiedExploitabalitySubScore), 10) * $metricWeightE * $metricWeightRL * $metricWeightRC)
    } else {
    $envModifiedImpactSubScore = $metricWeightMS * ($envImpactSubScoreMultiplier - 0.029) - 3.25 * [math]::Pow($envImpactSubScoreMultiplier - 0.02, 15)
    $envScore = $this.roundUp1($this.roundUp1([math]::Min($this.scopeCoefficient * ($envModifiedImpactSubScore + $envModifiedExploitabalitySubScore), 10)) * $metricWeightE * $metricWeightRL * $metricWeightRC)
  }

  if ($envModifiedImpactSubScore -le 0) {
    $envScore = 0;
  }

  # CONSTRUCT THE VECTOR STRING

  $vectorString = $this.CVSSVersionIdentifier +
    "/AV:" + $AV +
    "/AC:" + $AC +
    "/PR:" + $PR +
    "/UI:" + $UI +
    "/S:"  + $S +
    "/C:"  + $C +
    "/I:"  + $I +
    "/A:"  + $A

  if ($E  -ne "X")  {$vectorString = $vectorString + "/E:" + $E}
  if ($RL -ne "X")  {$vectorString = $vectorString + "/RL:" + $RL}
  if ($RC -ne "X")  {$vectorString = $vectorString + "/RC:" + $RC}

  if ($CR  -ne "X") {$vectorString = $vectorString + "/CR:" + $CR}
  if ($IR  -ne "X") {$vectorString = $vectorString + "/IR:"  + $IR}
  if ($AR  -ne "X") {$vectorString = $vectorString + "/AR:"  + $AR}
  if ($MAV -ne "X") {$vectorString = $vectorString + "/MAV:" + $MAV}
  if ($MAC -ne "X") {$vectorString = $vectorString + "/MAC:" + $MAC}
  if ($MPR -ne "X") {$vectorString = $vectorString + "/MPR:" + $MPR}
  if ($MUI -ne "X") {$vectorString = $vectorString + "/MUI:" + $MUI}
  if ($MS  -ne "X") {$vectorString = $vectorString + "/MS:"  + $MS}
  if ($MC  -ne "X") {$vectorString = $vectorString + "/MC:"  + $MC}
  if ($MI  -ne "X") {$vectorString = $vectorString + "/MI:"  + $MI}
  if ($MA  -ne "X") {$vectorString = $vectorString + "/MA:"  + $MA}


  # Return an object containing the scores for all three metric groups, and an overall vector string.

  return @{
    Success = $true;
    baseMetricScore = $(([math]::Round($baseScore, 1), [system.midpointrounding]::AwayFromZero)[0].ToString());
    baseSeverity = $this.severityRating( $(([math]::Round($baseScore, 1), [System.MidpointRounding]::AwayFromZero)[0].ToString()));

    temporalMetricScore = $(([math]::Round($temporalScore, 1), [system.midpointrounding]::AwayFromZero)[0].ToString());
    temporalSeverity = $this.severityRating( $(([math]::Round($temporalScore, 1), [System.MidpointRounding]::AwayFromZero)[0].ToString()));

    environmentalMetricScore = $(([math]::Round($envScore, 1), [system.midpointrounding]::AwayFromZero)[0].ToString());
    environmentalSeverity = $this.severityRating( $(([math]::Round($envScore, 1), [System.MidpointRounding]::AwayFromZero)[0].ToString()));

    vectorString = $vectorString
  }

}

<# ** CVSS.calculateCVSSFromVector **
 *
 * Takes Base, Temporal and Environmental metric values as a single string in the Vector String format defined
 * in the CVSS v3.0 standard definition of the Vector String.
 *
 * Returns Base, Temporal and Environmental scores, severity ratings, and an overall Vector String. All Base metrics
 * are required to generate this output. All Temporal and Environmental metric values are optional. Any that are not
 * passed default to "X" ("Not Defined").
 *
 * See the comment for the CVSS.calculateCVSSFromMetrics function for details on the function output. In addition to
 * the error conditions listed for that function, this function can also return:
 *   "MalformedVectorString", if the Vector String passed is does not conform to the format in the standard; or
 *   "MultipleDefinitionsOfMetric", if the Vector String is well formed but defines the same metric (or metrics),
 *                                  more than once.
#>

Add-Member -InputObject $CVSS -MemberType ScriptMethod -name 'calculateCVSSFromVector' -value {
    Param($vectorString)
    $metricValues = @{
    AV = $null; AC =  $null; PR =  $null; UI =  $null; S =  $null;
    C =   $null; I =   $null; A =   $null;
    E =   $null; RL =  $null; RC =  $null;
    CR =  $null; IR =  $null; AR =  $null;
    MAV = $null; MAC = $null; MPR = $null; MUI = $null; MS = $null;
    MC =  $null; MI =  $null; MA =  $null
  }

  # If input validation fails, this array is populated with strings indicating which metrics failed validation.
  [System.Collections.ArrayList]$badMetrics = @()

  if (!($this.vectorStringRegex_30.IsMatch($vectorString))) {
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
    $metricValues.AV,  $metricValues.AC,  $metricValues.PR,  $metricValues.UI,  $metricValues.S,
    $metricValues.C,   $metricValues.I,   $metricValues.A,
    $metricValues.E,   $metricValues.RL,  $metricValues.RC,
    $metricValues.CR,  $metricValues.IR,  $metricValues.AR,
    $metricValues.MAV, $metricValues.MAC, $metricValues.MPR, $metricValues.MUI, $metricValues.MS,
    $metricValues.MC,  $metricValues.MI,  $metricValues.MA)

}

#$object = New-Object -TypeName PSObject -Property $CVSS

#return $object
return $CVSS
}
