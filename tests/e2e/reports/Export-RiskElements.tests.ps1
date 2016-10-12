$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -tag 'Export-RiskElements' "Export-RiskElements PS: $PSVersion" {

    Setup -Dir CKL
    Setup -Dir Nessus
    Setup -Dir Controls
    Setup -Dir Empty
    Setup -Dir results

    Copy-Item "$Global:testData\CKL\CKLv1\Sample04_Win2008R2MS.ckl" "TestDrive:\CKL\Sample04_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\CKL\CKLv1\Sample05_Win2008R2MS.ckl" "TestDrive:\CKL\Sample05_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\Controls\Sample_DODI_8500_2_Controls.xlsx" "TestDrive:\Controls\Sample_DODI_8500_2_Controls.xlsx"
    Copy-Item "$Global:testData\Nessus_Scans\Nessus_Sample_Linux.nessus" "TestDrive:\Nessus\Nessus_Sample_Linux.nessus"
    Copy-Item "$Global:testData\Nessus_Scans\Nessus_Sample_Windows.nessus" "TestDrive:\Nessus\Nessus_Windows.nessus"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No Name was provided'" {
            {Export-RiskElements} | Should Throw "No Name was provided"
        }

        It "Should Throw 'No output path given'" {
            {Export-RiskElements -name "APP_Owner"} | Should Throw "No output path given"
        }

        It "Should Throw 'Nothing to process'" {
            {Export-RiskElements -name "APP_Owner" -Out "$($TestDrive)\Out"} | Should Throw "Nothing to process"
        }

        It "Should Throw 'Both DIACAP and RMF Specified. Please select DIACAP OR RMF" {
            {Export-RiskElements -DIACAP "$($TestDrive)\Controls\Sample_DODI_8500_2_Controls.xlsx" -RMF "$($TestDrive)\Controls\Sample_DODI_8500_2_Controls.xlsx" -name "APP_Owner" -Out "$($TestDrive)\Out"} | Should Throw "Both DIACAP and RMF Specified. Please select DIACAP OR RMF"
        }

        It "Should Throw 'No Files Found'" {
            {Export-RiskElements -CKLFILES "$($TestDrive)\Empty" -name "APP_Owner" -Out "$($TestDrive)\Out"} | Should Throw "No CKL files found"
            {Export-RiskElements -Nessus "$($TestDrive)\Empty" -name "APP_Owner" -Out "$($TestDrive)\Out"} | Should Throw "No NESSUS files found"

        }

        It "Should Throw 'Path Not Found'" {
             {Export-RiskElements -CKLFILES "$($TestDrive)\test" -name "APP_Owner" -Out "$($TestDrive)\Out"} | Should Throw "CKL Path not found"
             {Export-RiskElements -NESSUS "$($TestDrive)\test" -name "APP_Owner" -Out "$($TestDrive)\Out"} | Should Throw "Nessus Path not found"
        }

        It "Should output risk elements xlsx" {
            Export-RiskElements -CKLFILES "$($TestDrive)\CKL" -NESSUS "$($TestDrive)\Nessus" -DIACAP "$($TestDrive)\Controls\Sample_DODI_8500_2_Controls.xlsx" -Name "APP_OWNER" -Output "$($TestDrive)\results" -mergecontrol
            $filetest = Get-Item -Path "$($TestDrive)\results\APP_OWNER_Risk.xlsx"
            $filetest.extension | Should Be ".xlsx"
        }
    }
}
