function Import-RiskAssessment
{
  <#
      .SYNOPSIS
      Launches the CLI for assigning CVSS Scores

      .PARAMETER 

      .PARAMETER 

      .PARAMETER

      .PARAMETER 


      .EXAMPLE


      .LINK

      .VERSION
      1.0.0 (11.14.2016)
        -Intial Release

  #>
  
  [CmdletBinding()]
  param
  (
    [String]
    $risk = $(Throw "No RISK Path provided"),
  
    [String]
    $map = $(Throw "No MAP provided"),
    
    [String]
    $output = $(Throw "No Output folder provided"),
    
    [String]
    $name = $(Throw "No Name provided")
  )
  
  # Test to see if the path to the risk report exists
  if(!(Test-Path -Path $risk)){Throw "Risk path does not exist"} 
  
  # Test to see if the path to the map report exists
  if(!(Test-Path -Path $map)){Throw "Map path does not exist"}

  # Import Risk Elements
  $riskelements = Import-XLSX -Path $risk
  
  # Import mapper
  $riskmap = Import-XLSX -Path $map
  
  # Select the ID from the Risk Map
  $riskmapnamelist = $(($riskmap | Select ID).ID)
}
