$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -Tag "FlowRisk" "Flow Risk Assesment: $PSVersion" {

    Setup -Dir "nessus"
    setup -Dir "Trackers"
    Setup -Dir "controls"
    Setup -Dir "ckl"

    Copy-Item -Path "$Global:testData\Nessus_Scans\Nessus_Sample.nessus" -Destination "TestDrive:\nessus\Nessus_Sample.nessus"
    Copy-Item -Path "$Global:testData\Trackers\Sample06_Win2008R2MS_CKLv2.csv" -Destination "TestDrive:\trackers\Sample06_Win2008R2MS_CKLv2.csv"
    Copy-Item -Path "$Global:testData\Trackers\Sample07_Win2008R2MS_CKLv2.xlsx" -Destination "TestDrive:\trackers\Sample07_Win2008R2MS_CKLv2.xlsx"
    Copy-Item -Path "$Global:testData\Controls\Sample_DODI_8500_2_Controls.xlsx" -Destination "TestDrive:\Controls\Sample_DODI_8500_2_Controls.xlsx"
    Copy-Item -Path "$Global:testData\CKL\CKLv2\sampleV2.ckl" -Destination "TestDrive:\ckl\sampleV2.ckl"

    Setup -Dir "results"
    Setup -Dir "results\ckl"
    Setup -Dir "results\nessus"
    Setup -Dir "results\combinedreports"
    Setup -Dir "results\testplan"

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

        }

        It "Update-TestPlan" {
            #Update-TestPlan -ckl "$($TestDrive)\results\ckl" -testplan "C:\testplan\testplan.xlsx" -output "C:\results\testplan" -name "Test" -version 2

        }
    }

}