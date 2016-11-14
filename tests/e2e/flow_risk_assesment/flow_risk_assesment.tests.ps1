$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -Tag "FlowRisk" "Flow Risk Assesment: $PSVersion" {

    Setup -Dir "nessus"
    setup -Dir "Trackers"
    Setup -Dir "controls"
    Setup -Dir "ckl"
    Setup -Dir "testplan"
    Setup -Dir "map"

    Copy-Item -Path "$Global:testData\Nessus_Scans\Nessus_Sample.nessus" -Destination "TestDrive:\nessus\Nessus_Sample.nessus"
    Copy-Item -Path "$Global:testData\Nessus_Scans\Nessus_Sample_Linux.nessus" -Destination "TestDrive:\nessus\Nessus_Sample_Linux.nessus"
    Copy-Item -Path "$Global:testData\Nessus_Scans\Nessus_Sample_Windows.nessus" -Destination "TestDrive:\nessus\Nessus_Sample_Windows.nessus"
    Copy-Item -Path "$Global:testData\Trackers\Sample06_Win2008R2MS_CKLv2.csv" -Destination "TestDrive:\trackers\Sample06_Win2008R2MS_CKLv2.csv"
    Copy-Item -Path "$Global:testData\Trackers\Sample07_Win2008R2MS_CKLv2.xlsx" -Destination "TestDrive:\trackers\Sample07_Win2008R2MS_CKLv2.xlsx"
    Copy-Item -Path "$Global:testData\Controls\Sample_DODI_8500_2_Controls.xlsx" -Destination "TestDrive:\Controls\Sample_DODI_8500_2_Controls.xlsx"
    Copy-Item -Path "$Global:testData\CKL\CKLv2\sampleV2.ckl" -Destination "TestDrive:\ckl\sampleV2.ckl"
    Copy-Item -Path "$Global:testData\MCCAST_TestPlan\MCCAST_TestPlan_CKLv2.xlsx" -Destination "TestDrive:\testplan\MCCAST_TestPlan_CKLv2.xlsx"
    Copy-Item -Path "$Global:testData\Risk_Mapping\Sample_Risk_Map.xlsx" -Destination "TestDrive:\map\Sample_Risk_Map.xlsx"

    Setup -Dir "results"
    Setup -Dir "results\ckl"
    Setup -Dir "results\nessus"
    Setup -Dir "results\combinedreports"
    Setup -Dir "results\testplan"
    Setup -Dir "results\riskelements"
    Setup -Dir "results\compliance"
    Setup -Dir "results\RiskAlgorithm"

    $dateObject = new-object system.globalization.datetimeformatinfo
    $date = Get-Date

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Invoke-NessusOpenPorts Should create a nessus Listen Ports CSV Report" {
            Invoke-NessusOpenPorts -Nessus "TestDrive:\nessus\Nessus_Sample.nessus" -packagename "Test" -output "TestDrive:\results\nessus"
            $report = Get-Item -Path "TestDrive:\results\nessus\Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
            $report.name | Should Be "Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
        }

        It "Export-CKL Should create 2 CKLv2 files" {
            Export-CKL -Path "$($TestDrive)\trackers" -Out "$($TestDrive)\results\ckl" -version 2
            $files = Get-ChildItem -Path "TestDrive:\results\ckl\" -Filter "*.ckl"
            $files.count | Should be 2
        }

        It "Export-CombinedReports should create 2 xls" {
            Export-CombinedReports -CKLFILES "$($TestDrive)\ckl" -Nessus "$($TestDrive)\nessus\Nessus_Sample.nessus" -output "$($TestDrive)\results\combinedreports" -name "Test" -xlsx
            $reportfile = Get-ChildItem -Path 'TestDrive:\results\combinedreports'
            $reportfile.count | Should Be 2
            $reportfile[0].extension | should be '.xlsx'
        }

        It "Update-Controls" {
            Update-Controls -path "$($testDrive)\controls\Sample_DODI_8500_2_Controls.xlsx" -ckl "$($testDrive)\results\ckl" -output "$($testDrive)\results" -name "APP_OWNER" -diacap
            $xlsx = Import-XLSX -path "$($testDrive)\results\APP_OWNER_8500.2_Controls.xlsx"
            $controls = Import-DIACAP -doc $xlsx
            $($controls | Where-Object {$_."Control Number" -match "PRTN-1" -and $_."Assessment Status" -match "Fail"}).count | Should Be 2
        }

        It "Update-TestPlan" {
            Update-TestPlan -ckl "$($testDrive)\results\ckl" -testplan "$($testDrive)\testplan\MCCAST_TestPlan_CKLv2.xlsx" -output "$($testDrive)\results\testplan" -name "APP_OWNER"
            $xlsx = Import-XLSX -path "$($testDrive)\results\testplan\APP_OWNER_TestPlan.xlsx"
            $results = $xlsx | Where-Object {$_."Implementation Result" -notmatch "^\s*$"}
            $results.count | Should Be 321
        }

        It "Export-RiskElements" {
            Export-RiskElements -CKLFILES "$($TestDrive)\results\ckl" -NESSUS "$($TestDrive)\nessus" -DIACAP "$($TestDrive)\Controls\Sample_DODI_8500_2_Controls.xlsx" -Name "APP_OWNER" -Output "$($TestDrive)\results\riskelements" -mergecontrol
            $filetest = Get-Item -Path "$($TestDrive)\results\riskelements\APP_OWNER_Risk.xlsx"
            $filetest.extension | Should Be ".xlsx"
        }

        It "Get-Compliance" {
            Get-Compliance -ckl "$($testDrive)\results\ckl" -output "$($testDrive)\results\compliance" -name "APP_OWNER"
            $xlsx = Import-XLSX -path "$($testDrive)\results\compliance\APP_OWNER_STIG_Compliance_Report.xlsx"
            $headers = $($xlsx | Get-Member -MemberType NoteProperty).Name
            $($headers -contains "STIG" -and $headers -contains "Systems" -and $headers -contains "System_Count" -and $headers -contains "High_Count_Finding" -and $headers -contains "MED_Count_Finding" -and $headers -contains "LOW_Count_Finding" -and $headers -contains "High_Total" -and $headers -contains "MED_Total" -and $headers -contains "LOW_Total" -and $headers -contains "Total_Checks" -and $headers -contains "Compliance_Percentage" -and $headers -contains "Compliant") | Should Be $true

        }

        It "Invoke-RiskAlgorithm" {
            #Invoke-RiskAlgorithm -risk "$($testDrive)\results\riskelements\APP_OWNER_Risk.xlsx" -map "$($testDrive)\map\Sample_Risk_Map.xlsx" -docrisk 45 -sysrisk 45 -output "$($testDrive)\results\RiskAlgorithm" -name "APP_OWNER"
            #$results = Import-XLSX -path "$($testDrive)\results\RiskAlgorithm\APP_OWNER_Risk_Algorithm_Report.xlsx"
            #$results."Risk Level" | Should Be "MEDIUM"
        }
    }
}
