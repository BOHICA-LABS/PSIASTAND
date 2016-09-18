<#
    .Version
    1.0.0.0
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'


$moduleName = 'PSIASTAND'
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Activate-Watcher PS: $PSVersion"{
  Context 'Strict Mode'{
    # Enable Strict Mode in Powershell
    Set-StrictMode -Version latest

    # Active the Watcher
    Activate-Watcher -location $TestDrive -output "TestDrive:\" -name 'Test_Watch'

    it "Should detect 8 events"{
      for ($x = 0; $x -lt 4; $x++)
      {
        "Test Data" | Out-File "TestDrive:\Test$($x)"
      }
      $eventReport = Import-Csv -Path 'TestDrive:\Test_Watch.csv'
      $eventReport.Count | Should Be 8
    }
  }
}
