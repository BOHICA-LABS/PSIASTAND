$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Update-TestPlan PS: $PSVersion" {

    Setup -Dir CKL
    SetUp -Dir testplan
    Setup -Dir results
    Setup -Dir fake

    Copy-Item "$Global:testData\CKL\CKLv1\Sample04_Win2008R2MS.ckl" "TestDrive:\CKL\Sample04_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\CKL\CKLv1\Sample05_Win2008R2MS.ckl" "TestDrive:\CKL\Sample05_Win2008R2MS.ckl"
    #Copy-Item "$Global:testData\CKL\CKLv1\Sample.ckl" "TestDrive:\CKL\Sample.ckl"
    Copy-Item "$Global:testData\MCCAST_TestPlan\MCCAST_TestPlan.xlsx" "TestDrive:\testplan\MCCAST_TestPlan.xlsx"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No CKL Path provided'" {
            {Update-TestPlan} | Should Throw "No CKL Path provided"
        }

        It "Should Throw 'No Testplan provided'" {
            {Update-TestPlan -ckl "$($testDrive)\CKL"} | Should Throw "No Testplan provided"
        }

        It "Should Throw 'No Output folder provided'" {
            {Update-TestPlan -ckl "$($testDrive)\CKL" -testplan "$($testDrive)\testplan\MCCAST_TestPlan.xlsx"} | Should Throw "No Output folder provided"
        }

        It "Should Throw 'No Name provided'" {
            {Update-TestPlan -ckl "$($testDrive)\CKL" -testplan "$($testDrive)\testplan\MCCAST_TestPlan.xlsx" -output "$($testDrive)\results"} | Should Throw "No Name provided"
        }

        It "Should Throw 'CKL Path not found'" {
            {Update-TestPlan -ckl "$($testDrive)\blue" -testplan "$($testDrive)\testplan\MCCAST_TestPlan.xlsx" -output "$($testDrive)\results" -name "APP_OWNER"} | Should Throw "CKL Path not found"
        }

        It "Should Throw 'No CKL files found'" {
            {Update-TestPlan -ckl "$($testDrive)\fake" -testplan "$($testDrive)\testplan\MCCAST_TestPlan.xlsx" -output "$($testDrive)\results" -name "APP_OWNER"} | Should Throw "No CKL files found"
        }

        It "Should Throw 'Testplan not found'" {
            {Update-TestPlan -ckl "$($testDrive)\CKL" -testplan "$($testDrive)\testplan1\MCCAST_TestPlan.xlsx" -output "$($testDrive)\results" -name "APP_OWNER"} | Should Throw "Testplan not found"
        }

        It "Should update the testplan (Requires Import-XLSX)" {
            Update-TestPlan -ckl "$($testDrive)\CKL" -testplan "$($testDrive)\testplan\MCCAST_TestPlan.xlsx" -output "$($testDrive)\results" -name "APP_OWNER"
            $xlsx = Import-XLSX -path "$($testDrive)\results\APP_OWNER_TestPlan.xlsx"
            $results = $xlsx | Where-Object {$_."Implementation Result" -notmatch "^\s*$"}
            $results.count | Should Be 662
        }
    }
}
