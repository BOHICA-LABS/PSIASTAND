$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -tag 'Export-CKL' "Export-CKL PS: $PSVersion" {

    Setup -Dir results
    Setup -Dir recursion
    Setup -Dir nofiles

    Copy-Item "$here\Sample_Win2008R2MS.csv" "TestDrive:\Sample_Win2008R2MS1.csv"
    Copy-Item "$here\Sample_Win2008R2MS.xlsx" "TestDrive:\Sample_Win2008R2MS2.xlsx"
    Copy-Item "$here\Sample_Win2008R2MS.csv" "TestDrive:\recursion\Sample_Win2008R2MS3.csv"
    Copy-Item "$here\Sample_Win2008R2MS.xlsx" "TestDrive:\recursion\Sample_Win2008R2MS4.xlsx"


    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No Path provided'" {
            {Export-CKL} | Should Throw "No Path provided"
        }

        It "Should Throw 'No output path provided'" {
            {Export-CKL -Path "TestDrive:\"} | Should Throw "No output path provided"
        }

        It "Should Throw 'No Version provided'" {
            {Export-CKL -Path "TestDrive:\" -Out "TestDrive:\results"} | Should Throw "No Version provided"
        }

        It "Should Throw 'No Files Found'" {
            {Export-CKL -Path "TestDrive:\nofiles" -Out "TestDrive:\results" -version 1} | Should Throw "No Files Found"
        }

        It "Should output 2 files (No Recursion)'" {
            Export-CKL -Path $TestDrive -Out "$($TestDrive)\results" -version 1
            $files = Get-ChildItem -Path "TestDrive:\results" -Filter "*.ckl"
            $files.count | Should Be 2
        }

        It "Should output 4 files (Recursion)'" {
            Export-CKL -Path $TestDrive -Out "$($TestDrive)\results" -version 1 -Recursive
            $files = Get-ChildItem -Path "TestDrive:\results" -Filter "*.ckl"
            $files.count | Should Be 4
        }

        It "Should create 4 Version 1 CKL files (Requires Import-XML, Import-CKL)" {
            $files = Get-ChildItem -Path "TestDrive:\results" -Filter "*.ckl"
            $files.count | Should Be 4
            foreach($file in $files){
                $xml = Import-XML -fileobj $file
                $ckl = Import-CKL -doc $xml
                $ckl[0].StigViewer_Version | Should Be 1
            }
        }
    }
}
