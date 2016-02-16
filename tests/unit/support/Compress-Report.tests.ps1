$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Compress-Report PS: $PSVersion" {

    Setup -Dir CKL
    Setup -Dir Nessus

    Copy-Item "$Global:testData\CKL\CKLv1\Sample04_Win2008R2MS.ckl" "TestDrive:\CKL\Sample04_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\CKL\CKLv1\Sample05_Win2008R2MS.ckl" "TestDrive:\CKL\Sample05_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\Nessus_Scans\Nessus_Sample_Linux.nessus" "TestDrive:\Nessus\Nessus_Sample_Linux.nessus"
    Copy-Item "$Global:testData\Nessus_Scans\Nessus_Sample_Windows.nessus" "TestDrive:\Nessus\Nessus_Sample_Windows.nessusl"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No report Provided'" {
            {Compress-Report} | Should Throw "No report Provided"
        }

        It "Should Throw 'Report Type not selected'" {
            {Compress-Report -report "FAKE"} | Should Throw "Report Type not selected"
        }

        It "Should Compress CKL Report (Requires Import-XML, Import-CKL)" {
            $files = Get-ChildItem -Path "$($TestDrive)\CKL"
            $compiled = @()
            foreach ($file in $files) {
                $xml = Import-XML -fileobj $file
                $report = Import-CKL -doc $xml
                $compiled += $report
            }
            $filtered = $compiled | Where-Object {$_.Status -match "Open"}
            $compressed = Compress-Report -report $filtered -ckl
            $compressed.count -lt $filtered.count | Should Be $true
        }

        It "Should Compress Nessus Report (Requires Import-XML, Import-Nessus)" {
            $files = Get-ChildItem -Path "$($TestDrive)\Nessus"
            $compiled = @()
            foreach ($file in $files) {
                $xml = Import-XML -fileobj $file
                $report = Import-Nessus -doc $xml
                $compiled += $report
            }
            $filtered = $compiled | Where-Object {$_.risk_factor -match "none"}
            $compressed = Compress-Report -report $filtered -nessus
            $compressed.count -lt $filtered.count | Should Be $true
        }
    }
}
