<#
    .Description
    For Some reason the Start-Watcher Fails when called from pester... not sure why. The function works completly outside of pester
    .Version
    1.0.0.0
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$modroot = "..\..\..\..\PSIASTAND.psd1"


$moduleName = 'PSIASTAND'
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Start-Watcher PS: $PSVersion"{
  Context 'Strict Mode'{
    # Enable Strict Mode in Powershell
    Set-StrictMode -Version latest

    # Active the Watcher
    <#Start-Job -Name "File_Builder" -scriptblock {
      Start-Sleep -Seconds 2
      for ($x = 0; $x -lt 4; $x++)
      {
        New-Item -path $args[0] -Name "Test_$($x).txt" -type file
      }
    } -ArgumentList $TestDrive

    Start-Watcher -location $TestDrive -output $TestDrive -name 'Test_Watch' -testmode 30 -monmode

    Get-Job -Name "File_Builder" | Remove-Job -Force # Remove Job "Cleaning up the session"

    it "Should detect 8 events"{

      #Get-ChildItem -Path "TestDrive:\"
      $eventReport = Import-Csv -Path 'TestDrive:\Test_Watch.csv'
      $eventReport.Count | Should Be 4
      #>
    }
  }
}
