$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "ConvertTo-RiskElements PS: $PSVersion" {

    Copy-Item "$Global:testData\CKL\CKLv1\Sample04_Win2008R2MS.ckl" "TestDrive:\Sample04_Win2008R2MS.ckl"
    Copy-Item "$Global:testData\Controls\Sample_DODI_8500_2_Controls.xlsx" "TestDrive:\Sample_DODI_8500_2_Controls.xlsx"
    Copy-Item "$Global:testData\Nessus_Scans\Nessus_Sample_Windows.nessus" "TestDrive:\Nessus_Sample_Windows.nessus"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No report Provided'" {
            {ConvertTo-RiskElements} | Should Throw "No report Provided"
        }

        It "Should Throw 'Report Type not selected'" {
            {ConvertTo-RiskElements -report "FAKE"} | Should Throw "Report Type not selected"
        }

        It "Should Convert to Risk Elements (CKL) (Requires Import-XLSX, Import-DIACAP, Import-XML, Import-CKL, Compress-Report)" {
            $file = Get-Item -Path "$($TestDrive)\Sample04_Win2008R2MS.ckl"
            $xml = Import-XML -fileobj $file
            $ckl = Import-CKL -doc $xml
            $filteredCKL = $ckl | Where-Object{$_.Status -match "Open"}
            $compressedCKL = Compress-Report -Report $filteredCKL -CKL
            $risk = ConvertTo-RiskElements -report $compressedCKL -ckl
            $properties = $($risk | Get-Member -MemberType NoteProperty).Name
            $($properties -contains "Name" -and $properties -contains "Weaknesses" -and $properties -contains "Cat" -and $properties -contains "IA Control" -and $properties -contains "Count" -and $properties -contains "Risk") | Should Be $true
        }

        It "Should Convert to Risk Elements (Nessus) (Requires Import-XLSX, Import-XML, Import-Nessus, Compress-Report)" {
            $file = Get-Item -Path "$($TestDrive)\Nessus_Sample_Windows.nessus"
            $xml = Import-XML -fileobj $file
            $nessus = Import-Nessus -doc $xml
            $filterednessus = $nessus | Where-Object {$_.risk_factor -notmatch "None"}
            $compressnessus = compress-report -report $filterednessus -nessus
            $risk = ConvertTo-RiskElements -report $compressnessus -nessus
            $properties = $($risk | Get-Member -MemberType NoteProperty).Name
            $($properties -contains "Name" -and $properties -contains "Weaknesses" -and $properties -contains "Cat" -and $properties -contains "IA Control" -and $properties -contains "Count" -and $properties -contains "Risk") | Should Be $true
        }

        It "Should Convert to Risk Elements (Controls) (Requires Import-XLSX, Import-DIACAP, Import-XML, Import-CKL, Compress-Report)" {
            $diacapxlsx = Import-XLSX -Path "$($TestDrive)\Sample_DODI_8500_2_Controls.xlsx"
            $controls = Import-DIACAP -doc $diacapxlsx
            $final = $controls | Where-Object {$_."Assessment Status" -match "Fail"}
            $risk = ConvertTo-RiskElements -report $final -diacap
            $properties = $($risk | Get-Member -MemberType NoteProperty).Name
            $($properties -contains "Name" -and $properties -contains "Weaknesses" -and $properties -contains "Cat" -and $properties -contains "IA Control" -and $properties -contains "Count" -and $properties -contains "Risk") | Should Be $true
        }
    }
}
