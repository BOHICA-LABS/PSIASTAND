$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -tag 'Invoke-RiskAlgorithm' "Invoke-RiskAlgorithm PS: $PSVersion" {

    Setup -Dir Risk
    SetUp -Dir Map
    Setup -Dir results
    Setup -Dir fake

    Copy-Item "$Global:testData\Mock_APP\APP_OWNER_Risk.xlsx" "TestDrive:\Risk\APP_OWNER_Risk.xlsx"
    Copy-Item "$Global:testData\Mock_APP\APP_OWNER_Risk_ERROR.xlsx" "TestDrive:\Risk\APP_OWNER_Risk_ERROR.xlsx"
    Copy-Item "$Global:testData\Risk_Mapping\Sample_Risk_Map.xlsx" "TestDrive:\Map\Sample_Risk_Map.xlsx"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No RISK Path provided'" {
            {Invoke-RiskAlgorithm} | Should Throw "No RISK Path provided"
        }

        It "Should Throw 'No MAP provided'" {
            {Invoke-RiskAlgorithm -risk "$($testDrive)\risk\APP_OWNER_Risk.xlsx"} | Should Throw "No MAP provided"
        }

        It "Should Throw 'No Documentation level provided'" {
            {Invoke-RiskAlgorithm -risk "$($testDrive)\risk\APP_OWNER_Risk.xlsx" -map "$($testDrive)\map\Sample_Risk_Map.xlsx"} | Should Throw "No Documentation level provided"
        }

        It "Should Throw 'No System Knowledge level provided'" {
            {Invoke-RiskAlgorithm -risk "$($testDrive)\risk\APP_OWNER_Risk.xlsx" -map "$($testDrive)\map\Sample_Risk_Map.xlsx" -docrisk 45} | Should Throw "No System Knowledge level provided"
        }

        It "Should Throw 'No Output folder provided'" {
            {Invoke-RiskAlgorithm -risk "$($testDrive)\risk\APP_OWNER_Risk.xlsx" -map "$($testDrive)\map\Sample_Risk_Map.xlsx" -docrisk 45 -sysrisk 45} | Should Throw "No Output folder provided"
        }

        It "Should Throw 'No Name provided'" {
            {Invoke-RiskAlgorithm -risk "$($testDrive)\risk\APP_OWNER_Risk.xlsx" -map "$($testDrive)\map\Sample_Risk_Map.xlsx" -docrisk 45 -sysrisk 45 -output "$($testDrive)\results"} | Should Throw "No Name provided"
        }

        It "Should Throw 'System Knowledge risk or Documentation risk falls outside of 0-100'" {
            {Invoke-RiskAlgorithm -risk "$($testDrive)\risk\APP_OWNER_Risk.xlsx" -map "$($testDrive)\map\Sample_Risk_Map.xlsx" -docrisk -100 -sysrisk 45 -output "$($testDrive)\results" -name "APP_OWNER"} | Should Throw "System Knowledge risk or Documentation risk falls outside of 0-100"
            {Invoke-RiskAlgorithm -risk "$($testDrive)\risk\APP_OWNER_Risk.xlsx" -map "$($testDrive)\map\Sample_Risk_Map.xlsx" -docrisk 45 -sysrisk 101 -output "$($testDrive)\results" -name "APP_OWNER"} | Should Throw "System Knowledge risk or Documentation risk falls outside of 0-100"
        }

        It "Should Throw 'No Mapping element is not mapped'" {
            {Invoke-RiskAlgorithm -risk "$($testDrive)\risk\APP_OWNER_Risk_ERROR.xlsx" -map "$($testDrive)\map\Sample_Risk_Map.xlsx" -docrisk 45 -sysrisk 45 -output "$($testDrive)\results" -name "APP_OWNER"} | Should Throw "No Mapping is not mapped"
        }

        It "Should create a risk algorithm report (Requires Import-XLSX, Get-Average)" {
            Invoke-RiskAlgorithm -risk "$($testDrive)\risk\APP_OWNER_Risk.xlsx" -map "$($testDrive)\map\Sample_Risk_Map.xlsx" -docrisk 45 -sysrisk 45 -output "$($testDrive)\results" -name "APP_OWNER"
            $results = Import-XLSX -path "$($testDrive)\results\APP_OWNER_Risk_Algorithm_Report.xlsx"
            $results."Risk Level" | Should Be "MEDIUM"
        }
    }
}
