$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -tag 'Update-Controls' "Update-Controls PS: $PSVersion" {

    Setup -Dir CKL
    Setup -Dir Controls
    Setup -Dir results

    Copy-Item "$Global:testData\CKL\CKLv1\Sample04_Win2008R2MS.ckl" "TestDrive:\CKL\Sample04_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\CKL\CKLv1\Sample05_Win2008R2MS.ckl" "TestDrive:\CKL\Sample05_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\Controls\Sample_DODI_8500_2_Controls.xlsx" "TestDrive:\Controls\Sample_DODI_8500_2_Controls.xlsx"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No path Provided'" {
            {Update-Controls} | Should Throw "No path Provided"
        }

        It "Should Throw 'No CKL Path Provided'" {
            {Update-Controls -path "FAKE"} | Should Throw "No CKL Path Provided"
        }

        It "Should Throw 'No Output folder provided'" {
            {Update-Controls -path "FAKE" -ckl "FAKE"} | Should Throw "No Output folder provided"
        }

        It "Should Throw 'No Name provided'" {
            {Update-Controls -path "FAKE" -ckl "FAKE" -output "FAKE"} | Should Throw "No Name provided"
        }

        It "Should Throw 'No report type selected'" {
            {Update-Controls -path "FAKE" -ckl "FAKE" -output "FAKE" -name "FAKE"} | Should Throw "No report type selected"
        }

        It "Should Throw 'Both DIACAP and RMF Selected'" {
            {Update-Controls -path "$($testDrive)\Sample_DODI_8500_2_Controls.xlsx" -ckl "FAKE" -output "FAKE" -name "FAKE" -diacap -rmf} | Should Throw "Both DIACAP and RMF Selected"
        }

        It "Should Merge the Failed STIG Items that Map to IA Controls (Requires Import-XLSX, Import-DIACAP)" {
            Update-Controls -path "$($testDrive)\controls\Sample_DODI_8500_2_Controls.xlsx" -ckl "$($testDrive)\CKL" -output "$($testDrive)\results" -name "APP_OWNER" -diacap
            $xlsx = Import-XLSX -path "$($testDrive)\results\APP_OWNER_8500.2_Controls.xlsx"
            $controls = Import-DIACAP -doc $xlsx
            $($controls | Where-Object {$_."Control Number" -match "IAIA-1" -and $_."Assessment Status" -match "Fail"}).count | Should Be 12
        }
    }
}
