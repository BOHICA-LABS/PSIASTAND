$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Get-Compliance PS: $PSVersion" {

    Setup -Dir CKL
    Setup -Dir results

    Copy-Item "$Global:testData\CKL\CKLv1\Sample04_Win2008R2MS.ckl" "TestDrive:\CKL\Sample04_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\CKL\CKLv1\Sample05_Win2008R2MS.ckl" "TestDrive:\CKL\Sample05_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\CKL\CKLv1\Sample.ckl" "TestDrive:\CKL\Sample.ckl"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No CKL Path Provided'" {
            {Get-Compliance} | Should Throw "No CKL Path Provided"
        }

        It "Should Throw 'No Output folder provided'" {
            {Get-Compliance -ckl "FAKE"} | Should Throw "No Output folder provided"
        }

        It "Should Throw 'No Name provided'" {
            {Get-Compliance -ckl "FAKE" -Output "FAKE"} | Should Throw "No Name provided"
        }

        It "Should Create a Compliance Report" {
            Get-Compliance -ckl "$($testDrive)\CKL" -output "$($testDrive)\results" -name "APP_OWNER"
            $xlsx = Import-XLSX -path "$($testDrive)\results\APP_OWNER_STIG_Compliance_Report.xlsx"
            $headers = $($xlsx | Get-Member -MemberType NoteProperty).Name
            $($headers -contains "STIG" -and $headers -contains "Systems" -and $headers -contains "System_Count" -and $headers -contains "High_Count_Finding" -and $headers -contains "MED_Count_Finding" -and $headers -contains "LOW_Count_Finding" -and $headers -contains "High_Total" -and $headers -contains "MED_Total" -and $headers -contains "LOW_Total" -and $headers -contains "Total_Checks" -and $headers -contains "Compliance_Percentage" -and $headers -contains "Compliant") | Should Be $true
        }
    }
}
