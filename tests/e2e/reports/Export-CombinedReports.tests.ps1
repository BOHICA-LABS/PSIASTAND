$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Export-CombinedReports PS: $PSVersion" {

    Setup -Dir nofiles
    Setup -Dir results
    Setup -Dir single
    Setup -Dir resultsxlsx

    Copy-Item "$Global:testData\CKL\CKLv1\sample.ckl" "TestDrive:\sample.ckl"
    Copy-Item "$Global:testData\CKL\CKLv1\sample.ckl" "TestDrive:\single\sample.ckl"
    Copy-Item "$Global:testData\CKL\CKLv2\sampleV2.ckl" "TestDrive:\sampleV2.ckl"
    Copy-Item "$Global:testData\Nessus_Scans\Nessus_Sample_Linux.nessus" "TestDrive:\Nessus_Sample_Linux.nessus"
    Copy-Item "$Global:testData\Nessus_Scans\Nessus_Sample_Windows.nessus" "TestDrive:\Nessus_Sample_Windows.nessus"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No output path given'" {
            {Export-CombinedReports} | Should Throw "No output path given"
        }

        It "Should Throw 'No paths defined'" {
            {Export-CombinedReports -Output "TestDrive:\"} | Should Throw "No paths defined"
        }

        It "Should Throw 'CKL path does not exist'" {
            {Export-CombinedReports -CKLFILES "TestDrive:\fake" -Output "TestDrive:\"} | Should Throw "CKL path does not exist"
        }

        It "Should Throw 'NESSUS path does not exist'" {
            {Export-CombinedReports -NESSUS "TestDrive:\fake" -Output "TestDrive:\"} | Should Throw "NESSUS path does not exist"
        }

        It "Should Throw 'No CKL Files Found'" {
            {Export-CombinedReports -CKLFILES "TestDrive:\nofiles" -Output "TestDrive:\"} | Should Throw "No CKL Files Found"
        }

        It "Should Throw 'No Nessus Files Found'" {
            {Export-CombinedReports -NESSUS "TestDrive:\nofiles" -Output "TestDrive:\"} | Should Throw "No Nessus Files Found"
        }

        It "Should Throw 'CKL file failed to process'" {
            {Export-CombinedReports -CKLFILES "TestDrive:\" -Output "TestDrive:\results"} | Should Throw "$($(Get-ChildItem -Path "TestDrive:\sampleV2.ckl").name) CKL file failed to process"
        }

        It "Should Create 2 (csv) files" {
            Remove-Item -Path "TestDrive:\sampleV2.ckl"
            Export-CombinedReports -CKLFILES $TestDrive -NESSUS "$TestDrive" -Output "TestDrive:\results" -name "Sample"
            $reportfile = Get-ChildItem -Path "TestDrive:\results"
            $reportfile.count | Should Be 2
            $reportfile[0].extension | should be ".csv"
        }

        It "Should Create 2 (xlsx) files" {
            Export-CombinedReports -CKLFILES $TestDrive -NESSUS "$TestDrive" -Output "TestDrive:\resultsxlsx" -name "Sample" -xlsx
            $reportfile = Get-ChildItem -Path "TestDrive:\resultsxlsx"
            $reportfile.count | Should Be 2
            $reportfile[0].extension | should be ".xlsx"
        }

    }
}
