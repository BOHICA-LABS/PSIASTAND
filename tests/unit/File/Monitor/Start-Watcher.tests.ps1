<#
    .Description
    If this test fails, it could be a timing issue. Try changing the delay and run times
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
    Start-Job -Name "File_Builder" -scriptblock {
      Start-Sleep -Seconds 5
      for ($x = 0; $x -lt 4; $x++)
      {
        New-Item -path $args[0] -Name "Test_$($x).txt" -type file
      }
    } -ArgumentList $TestDrive

    Start-Watcher -location $TestDrive -output $TestDrive -name 'Test_Watch' -testmode 15
<<<<<<< HEAD

    Get-Job -Name "File_Builder" | Remove-Job -Force # Remove Job "Cleaning up the session"

    it "Should detect 4 events"{

=======
    Get-Job -Name "File_Builder" | Remove-Job -Force # Remove Job "Cleaning up the session"

    it "Should detect 4 events"{
>>>>>>> 25-merge-the-man-hour-calculator-into-psiastand
      #Get-ChildItem -Path "TestDrive:\"
      $eventReport = Import-Csv -Path 'TestDrive:\Test_Watch.csv'
      $eventReport.Count | Should Be 4
    }

    it "Should Throw 'Cant create output if both name and output location are not defined'"{
      {Start-Watcher -location $TestDrive -output $TestDrive -testmode 1} | Should Throw "Cant create output if both name and output location are not defined"
      {Start-Watcher -location $TestDrive -name "Test_Watch" -testmode 1} | Should Throw "Cant create output if both name and output location are not defined"
    }

    it "Should Throw 'Choose one type of mode.'"{
      {Start-Watcher -location $TestDrive -monmode -passthur -testmode 1} | Should Throw "Choose one type of mode."
    }
  }
}
