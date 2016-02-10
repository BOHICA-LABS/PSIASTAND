$here = Split-Path -Parent $MyInvocation.MyCommand.Path
#$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\main\$sut"

$moduleName = "PSIASTAND"

$PSVersion = $PSVersionTable.PSVersion.Major

#Import-Module "$here\..\..\..\..\$($moduleName)"

#Set up some data we will use in testing
    $ExistingXLSXFile = "$here\Working.xlsx"
    Remove-Item $ExistingXLSXFile  -force -ErrorAction SilentlyContinue
    Copy-Item $here\Test.xlsx $ExistingXLSXFile -force

    $NewXLSXFile = "$here\New.xlsx"
    Remove-Item $NewXLSXFile  -force -ErrorAction SilentlyContinue

    $Files = Get-ChildItem $PSScriptRoot | Where {-not $_.PSIsContainer}


Describe "Export-XLSX PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should create a file' {
            $Files | Export-XLSX -Path $NewXLSXFile
            Test-Path $NewXLSXFile | Should Be $True
        }

        It 'should add the correct number of rows' {
            $ExportedData = Import-XLSX -Path $NewXLSXFile
            $Files.Count | Should be $ExportedData.count
        }

        It 'should append to a file' {
            $Files | Export-XLSX -Path $NewXLSXFile -Append
            Test-Path $NewXLSXFile | Should Be $True
        }

        It 'should append the correct number of rows' {
            $ExportedData = Import-XLSX -Path $NewXLSXFile
            ( $Files.Count * 2 ) | Should be $ExportedData.count
        }

        It 'should build pivot tables' {

            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force

            Get-ChildItem C:\Windows |
                Where {-not $_.PSIsContainer} |
                Export-XLSX -Path $NewXLSXFile -PivotRows Extension -PivotValues Length

            $Excel = New-Excel -Path $NewXLSXFile
            $WorkSheet = @( $Excel | Get-Worksheet -Name PivotTable1 )
            $worksheet[0].PivotTables[0].RowFields[0].Name | Should be Extension

            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force

        }

        It 'should build pivot charts' {

            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force

            Get-ChildItem C:\Windows |
                Where {-not $_.PSIsContainer} |
                Export-XLSX -Path $NewXLSXFile -PivotRows Extension -PivotValues Length -ChartType Pie

            $Excel = New-Excel -Path $NewXLSXFile
            $WorkSheet = @( $Excel | Get-Worksheet -Name PivotTable1 )
            $WorkSheet[0].Drawings[0].ChartType.ToString() | Should be 'Pie'

            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force
        }
    }
}
#Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
