<#
    .Description
    Test CVSS v3 Powershell.
    .NOTES
    Test Still need to be built to insure input validation is working
    .Version
    1.0.0.0
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$modroot = "..\..\..\..\PSIASTAND.psd1"

$moduleName = 'PSIASTAND'
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "New-CVSS3 PS: $PSVersion"{
  Context 'Strict Mode'{
    # Enable Strict Mode in Powershell
    Set-StrictMode -Version latest

    # Create the CVSSv3 Object
    $CVSSobj = New-CVSS3

    it "CVSSv3 Vector String 'CVSS:3.0/AV:A/AC:H/PR:L/UI:R/S:C/C:L/I:L/A:H/E:U/RL:T/RC:R/CR:M/IR:M/AR:L/MAV:A/MAC:L/MPR:L/MUI:R/MS:U/MC:L/MI:H/MA:H' tested Correctly"{
      $response = $CVSSobj.calculateCVSSFromVector("CVSS:3.0/AV:A/AC:H/PR:L/UI:R/S:C/C:L/I:L/A:H/E:U/RL:T/RC:R/CR:M/IR:M/AR:L/MAV:A/MAC:L/MPR:L/MUI:R/MS:U/MC:L/MI:H/MA:H")
      $response.baseSeverity | Should be "Medium"
      $response.baseMetricScore | Should be 6.8
      $response.temporalSeverity | Should be "Medium"
      $response.temporalMetricScore | Should be 5.8
      $response.environmentalSeverity | Should be "Medium"
      $response.environmentalMetricScore | Should be 5.4
    }

    it "CVSSv3 Vector String 'CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H/E:H/RL:O/RC:C/CR:H/IR:H/AR:H' tested Correctly"{
      $response = $CVSSobj.calculateCVSSFromVector("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H/E:H/RL:O/RC:C/CR:H/IR:H/AR:H")
      $response.baseSeverity | Should be "Critical"
      $response.baseMetricScore | Should be 10.0
      $response.temporalSeverity | Should be "Critical"
      $response.temporalMetricScore | Should be 9.5
      $response.environmentalSeverity | Should be "Critical"
      $response.environmentalMetricScore | Should be 9.5
    }

    it "CVSSv3 Vector String 'CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:L/E:P/RL:O/RC:U/CR:H/IR:H/AR:H/MAV:P/MAC:H/MPR:H/MUI:R/MS:C/MC:L/MI:H/MA:L' tested Correctly"{
      $response = $CVSSobj.calculateCVSSFromVector("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:L/E:P/RL:O/RC:U/CR:H/IR:H/AR:H/MAV:P/MAC:H/MPR:H/MUI:R/MS:C/MC:L/MI:H/MA:L")
      $response.baseSeverity | Should be "High"
      $response.baseMetricScore | Should be 7.3
      $response.temporalSeverity | Should be "Medium"
      $response.temporalMetricScore | Should be 6.0
      $response.environmentalSeverity | Should be "Medium"
      $response.environmentalMetricScore | Should be 5.6
    }
  }
}

$path = "..\..\..\..\..\PSIASTAND.psd1"
Import-Module $path
Import-Module Pester

Invoke-Pester
Remove-Module $path
Remove-Module Pester
