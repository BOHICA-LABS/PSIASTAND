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

Describe "Save-Excel PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should save an xlsx file' {

            Remove-Item $NewXLSXFile -Force -ErrorAction SilentlyContinue

            $Excel = New-Excel -Path $NewXLSXFile
            [void]$Excel.Workbook.Worksheets.Add(1)
            $Excel | Save-Excel

            Test-Path $NewXLSXFile | Should be $True
        }

        It 'should close an excelpackage when specified' {

            Remove-Item $NewXLSXFile -Force -ErrorAction SilentlyContinue

            $Excel = New-Excel -Path $NewXLSXFile
            [void]$Excel.Workbook.Worksheets.Add(1)
            $File = $Excel.File
            $Excel | Save-Excel -Close

            $Excel.File -like $File | Should be $False
        }

        It 'should save as a specified path' {

            Remove-Item "$NewXLSXFile`2" -Force -ErrorAction SilentlyContinue
            Remove-Item "$NewXLSXFile" -Force -ErrorAction SilentlyContinue

            $Excel = New-Excel -Path $NewXLSXFile
            [void]$Excel.Workbook.Worksheets.Add(1)
            $Excel | Save-Excel -Path "$NewXLSXFile`2"

            Test-Path "$NewXLSXFile`2" | Should be $True
            Remove-Item "$NewXLSXFile`2" -Force -ErrorAction SilentlyContinue
        }

        It 'should return a fresh excelpackage when passthru is specified' {

            #If you want to save twice, you need to pull the excel package back in, otherwise, it bombs out.

            Remove-Item "$NewXLSXFile" -Force -ErrorAction SilentlyContinue

            $Excel = New-Excel -Path $NewXLSXFile
            [void]$Excel.Workbook.Worksheets.Add(1)
            $Excel = $Excel | Save-Excel -Passthru

            $Excel -is [OfficeOpenXml.ExcelPackage] | Should Be $True

            [void]$Excel.Workbook.Worksheets.Add(2)
            @($Excel.Workbook.Worksheets).count | Should be 2
            $Excel | Save-Excel

            $Excel = New-Excel -Path $NewXLSXFile
            @($Excel.Workbook.Worksheets).count | Should be 2

            Remove-Item "$NewXLSXFile" -Force -ErrorAction SilentlyContinue
        }
    }
}

#Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
