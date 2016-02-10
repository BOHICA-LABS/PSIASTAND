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

Describe "Import-XLSX PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should import data with expected results' {
            $ExcelData = Import-XLSX -Path $ExistingXLSXFile
            $Props = $ExcelData[0].PSObject.Properties | Select -ExpandProperty Name

            $ExcelData.count | Should be 10
            $Props[0] | Should be 'Name'
            $Props[1] | Should be 'Val'

            $Exceldata[0].val | Should be '944041859'
            $Exceldata[0].name | Should be 'Prop1'

        }
        It 'should parse numberformat for dates' {
            $ExcelData = Import-XLSX -Path $ExistingXLSXFile

            $Exceldata[0].Date -is [datetime] | Should be $True
            $Exceldata[0].Date.Month | Should be 1
            $Exceldata[0].Date.Year | Should be 2015
            $Exceldata[0].Date.Hour | Should be 4
        }

        It 'should replace headers' {
            $ExcelData = Import-XLSX -Path $ExistingXLSXFile -Header one, two, three
            $Props = $ExcelData[0].PSObject.Properties | Select -ExpandProperty Name

            $Props[0] | Should be 'one'
            $Props[1] | Should be 'two'
            $Props[2] | Should be 'three'
        }

        It 'should handle alternate row and column starts' {
            $ExcelData = Import-XLSX -Path $PSScriptRoot\DataPlacementTest.xlsx -RowStart 3 -ColumnStart 2
            $Props = $ExcelData[0].PSObject.Properties | Select -ExpandProperty Name

            $ExcelData.count | Should be 10
            $Props[0] | Should be 'Name'
            $Props[1] | Should be 'Val'

            $Exceldata[0].val | Should be '944041859'
            $Exceldata[0].name | Should be 'Prop1'
        }
    }
}
#Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
