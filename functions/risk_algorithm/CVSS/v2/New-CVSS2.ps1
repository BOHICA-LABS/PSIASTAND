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
  #>

  # Constants used in the formula
  $CVSS = @{} # initialize HashTable
  
  $CVSS.CVSSVersionIdentifier = "CVSS:2.0"
  $CVSS.exploitabilityCoefficient

  # A regular expression to validate that a CVSS 3.0 vector string is well formed. It checks metrics and metric
  # values. It does not check that a metric is specified more than once and it does not check that all base
  # metrics are present. These checks need to be performed separately.
  
  $CVSS.vectorStringRegex_20 = New-Object System.Text.RegularExpressions.Regex '^CVSS:2\.0\/((AV:[LAN]|AC:[HML]|AU:[MSN]|C:[NPC]|I:[NPC]|A:[NPC]|E:([UF]|POC|ND)|RL:([WU]|OF|TF|ND)|RC:([C]|UC|UR|ND)|CDP:([NLH]|LM|MH|ND)|TD:([NLMH]|ND)|CR:([LMH]|ND)|IR:([LMH]|ND)|AR:([LMH]|ND))\/)*(AV:[LAN]|AC:[HML]|AU:[MSN]|C:[NPC]|I:[NPC]|A:[NPC]|E:([UF]|POC|ND)|RL:([WU]|OF|TF|ND)|RC:([C]|UC|UR|ND)|CDP:([NLH]|LM|MH|ND)|TD:([NLMH]|ND)|CR:([LMH]|ND)|IR:([LMH]|ND)|AR:([LMH]|ND))$', 'IgnoreCase'
  
  # Associative arrays mapping each metric value to the constant defined in the CVSS scoring formula in the CVSS v3.0
  # specification.
  
  $CVSS.Weight = @{
    AV = @{ L = 0.395; A = 0.646; N = 1.0; };
    AC = @{ H = 0.35; M = 0.61; L = 0.71; };
    AU = @{ M = 0.45; S = 0.56; N = 0.704; };
    CIA = @{ N = 0.0; P = 0.275; C = 0.660; }; # C, I and A have the same weights

    
  }
}
