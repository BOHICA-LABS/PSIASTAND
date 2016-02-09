$here = Split-Path -Parent $MyInvocation.MyCommand.Path
#$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\main\$sut"

$moduleName = "PSIASTAND"

$PSVersion = $PSVersionTable.PSVersion.Major

Import-Module "$here\..\..\..\..\$($moduleName)"

#Set up some data we will use in testing
    $ExistingXLSXFile = "$here\Working.xlsx"
    Remove-Item $ExistingXLSXFile  -force -ErrorAction SilentlyContinue
    Copy-Item $here\Test.xlsx $ExistingXLSXFile -force

    $NewXLSXFile = "$here\New.xlsx"
    Remove-Item $NewXLSXFile  -force -ErrorAction SilentlyContinue

    $Files = Get-ChildItem $PSScriptRoot | Where {-not $_.PSIsContainer}

Describe "Add-PivotTable PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'Should add a pivot table to an existing xlsx' {
            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force

            Get-ChildItem C:\Windows |
                Where {-not $_.PSIsContainer} |
                Export-XLSX -Path $NewXLSXFile

            Add-PivotTable -Path $NewXLSXFile -WorkSheetName 'Worksheet1' -PivotTableWorksheetName 'PivotTable2' -PivotRows Extension -PivotValues Length

            $Excel = New-Excel -Path $NewXLSXFile
            $WorkSheet = @( $Excel | Get-Worksheet -Name PivotTable2 )

            $worksheet[0].PivotTables[0].RowFields[0].Name | Should be Extension

            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force
        }
        It 'Should add a pivot chart if specified' {
            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force

            Get-ChildItem C:\Windows |
                Where {-not $_.PSIsContainer} |
                Export-XLSX -Path $NewXLSXFile

            Add-PivotTable -Path $NewXLSXFile -WorkSheetName 'Worksheet1' -PivotTableWorksheetName 'PivotTable2' -PivotRows Extension -PivotValues Length -ChartType Area3D

            $Excel = New-Excel -Path $NewXLSXFile
            $WorkSheet = @( $Excel | Get-Worksheet -Name PivotTable2 )

            $WorkSheet[0].Drawings[0].ChartType.ToString() | Should be 'Area3D'

            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force
        }
    }
}
Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
