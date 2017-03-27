function Invoke-CVSS
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
      1.0.0 (11.17.2016)
        -Intial Release

  #>

  [CmdletBinding()]
  param
  (
    [String]
    $risk = $(Throw "No RISK Path provided"),

    [String]
    $output = $(Throw "No Output folder provided"),

    [String]
    $name = $(Throw "No Name provided"),

    [int]
    $version = 2
  )

  # Test to see if the path to the risk report exists
  if(!(Test-Path -Path $risk)){Throw "Risk path does not exist"}

  # Import Risk Elements
  $riskelements = Import-XLSX -Path $risk

  # Create CVSS
  if($version -eq 2)
  {
    $cvss = New-CVSS2
  }
  elseif($version -eq 3)
  {
    $cvss = New-CVSS3
  }
  else
  {
    Throw "CVSS Version Does not exsist"
  }

  $findlargest = @()
  # iterate through the Risk Elements Calculating Scores
  foreach ($element in $riskelements)
  {
    # Compute CVSS Score
    $scores = $cvss.calculateCVSSFromVector($element.CVSS)

    # If CVSS Returns Success
    if ($scores.Success)
    {
      # Add Score to findlargest Array
      $findlargest += $scores.environmentalMetricScore

      # Update the Asseed Risk Level in risk elements
      $element."Assessed Risk Level" = $scores.environmentalSeverity
    }

  }

  # Re-export Risk elements report
  Export-XLSX -Path "$($output)\$($name)_Risk_Report_Computed.xlsx" -InputObject $riskelements

  # Write Largest to Screen
  Write-Host $($findlargest | measure -Maximum).Maximum

}

#Invoke-CVSS -risk "C:\Users\josh\Google Drive\Code_Repo\PSIASTAND\tests\test_Risk_Report.xlsx" -output "C:\Users\josh\Google Drive\Code_Repo\PSIASTAND\tests" -name "tests"
