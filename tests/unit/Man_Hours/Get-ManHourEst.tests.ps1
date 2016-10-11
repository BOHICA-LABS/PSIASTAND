<#
    .Description
    This is the test file for Get-ManHourEst Function
    .Version
    1.0.0.0
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$modroot = "..\..\..\..\PSIASTAND.psd1"

$moduleName = 'PSIASTAND'
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Get-ManHourEst PS: $PSVersion"{
  $testingdata = "$($Global:testData)\Man_Hours"
  Context 'Strict Mode'{
    it "Should return '419' total man hours"{
      $hours = Get-ManHourEst -devicemap "$($testingdata)\HW_SW_STIG.xlsx" -loemap "$($testingdata)\Metrics.xlsx" -Passthru
      $hours | Should be 419
    }
  }
}
