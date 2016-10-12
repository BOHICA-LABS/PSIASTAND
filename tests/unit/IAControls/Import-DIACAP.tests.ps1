$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -tag 'Import-DIACAP' "Import-DIACAP PS: $PSVersion" {

    Copy-Item "$Global:testData\Controls\FAIL_Sample_DODI_8500_2_Controls.xlsx" "TestDrive:\FAIL_Sample_DODI_8500_2_Controls.xlsx"
    Copy-Item "$Global:testData\Controls\Sample_DODI_8500_2_Controls.xlsx" "TestDrive:\Sample_DODI_8500_2_Controls.xlsx"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Throw 'No object provided'" {
            {Import-DIACAP} | Should Throw "No object provided"
        }

        It "Should Throw 'Sanity Check Failure: Columns are missing from DIACAP Control Doc' (Requires IMPORT-XLSX)" {
            $xlsx = Import-XLSX -Path "$($TestDrive)\FAIL_Sample_DODI_8500_2_Controls.xlsx"
            {Import-DIACAP -doc $xlsx} | Should Throw "Sanity Check Failure: Columns are missing from DIACAP Control Doc"
        }

        It "Should return an object (Requsires IMPORT-XLSX)" {
            $xlsx = Import-XLSX -Path "$($TestDrive)\Sample_DODI_8500_2_Controls.xlsx"
            $controls = Import-DIACAP -doc $xlsx
            $controls -is [Object] | Should Be $true
        }

        It "Should return all properties" {
            $xlsx = Import-XLSX -Path "$($TestDrive)\Sample_DODI_8500_2_Controls.xlsx"
            $controls = Import-DIACAP -doc $xlsx
            $properties = $($controls | Get-Member -MemberType NoteProperty).Name
            ($properties -contains "Allocated Assessment ID" -and $properties -contains "Allocated Control ID" -and $properties -contains "Assessed By" -and $properties -contains "Assessment Date" -and $properties -contains "Assessment Objectives" -and $properties -contains "Assessment Status" -and $properties -contains "AssessmentObjectiveID" -and $properties -contains "Authorization Package" -and $properties -contains "Comments" -and $properties -contains "Control Implementation Status" -and $properties -contains "Control Name" -and $properties -contains "Control Number" -and $properties -contains "Impact Code" -and $properties -contains "Implementation Details" -and $properties -contains "Methods Used") | Should Be $true
        }

    }
}
