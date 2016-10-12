$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -tag 'Join-Controls' "Join-Controls PS: $PSVersion" {

    Copy-Item "$Global:testData\CKL\CKLv1\Sample04_Win2008R2MS.ckl" "TestDrive:\Sample04_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\Controls\Sample_DODI_8500_2_Controls.xlsx" "TestDrive:\Sample_DODI_8500_2_Controls.xlsx"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No object provided' Controls" {
            {Join-Controls} | Should Throw "No object provided"
        }

        It "Should Throw 'No object provided' CKL (Requires Import-XLSX, Import-DIACAP)" {
            $diacapxlsx = Import-XLSX -Path "$($TestDrive)\Sample_DODI_8500_2_Controls.xlsx"
            $controls = Import-DIACAP -doc $diacapxlsx
            {Join-Controls -Controls $controls} | Should Throw "No object provided"
        }

        It "Should Merge the Failed STIG Items that Map to IA Controls (Requires Import-XLSX, Import-DIACAP, Import-XML, Import-CKL, Compress-Report)" {
            #IAIA-1, IAIA-2
            $diacapxlsx = Import-XLSX -Path "$($TestDrive)\Sample_DODI_8500_2_Controls.xlsx"
            $controls = Import-DIACAP -doc $diacapxlsx
            $file = Get-Item -Path "$($TestDrive)\Sample04_Win2008R2MS.ckl"
            $cklxml = Import-XML -fileobj $file
            $cklfile = Import-CKL -doc $cklxml
            $filteredCKL = $cklfile | Where-Object{$_.Status -match "Open"}
            $compressedCKL = Compress-Report -Report $filteredCKL -CKL
            $Script:finalControls = Join-Controls -Controls $controls -CKL $compressedCKL -DIACAP
            $Script:finalControls -is [Object] | Should Be True
        }

        It "Should return IAIA-1 with a Count of 12 now Passed" {
            $diacapxlsx = Import-XLSX -Path "$($TestDrive)\Sample_DODI_8500_2_Controls.xlsx"
            $controls = Import-DIACAP -doc $diacapxlsx
            $($controls | Where-Object {$_."Control Number" -match "IAIA-1" -and $_."Assessment Status" -match "Pass"}).count | Should Be 12
        }

        It "Should return IAIA-1 with a Count of 12 now Failed" {
            #$($Script:controls | Where-Object {$_."Control Number" -match "IAIA-1" -and $_."Assessment Status" -match "Pass"}).count | Should Be 12
            $($Script:finalControls | Where-Object {$_."Control Number" -match "IAIA-1" -and $_."Assessment Status" -match "Fail"}).count | Should Be 12
        }
    }
}
