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

Describe "Close-Excel PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should close an excelpackage' {
            $Excel = New-Excel -Path $NewXLSXFile
            $File = $Excel.File
            $Excel | Close-Excel
            $Excel.File -like $File | Should be $False
        }

        It 'should save when requested' {
            Remove-Item $NewXLSXFile -Force -ErrorAction SilentlyContinue
            $Excel = New-Excel -Path $NewXLSXFile
            [void]$Excel.Workbook.Worksheets.Add(1)
            $Excel | Close-Excel -Save
            Test-Path $NewXLSXFile | Should be $True
        }

        It 'should save as a specified path' {
            $Excel = New-Excel -Path $NewXLSXFile
            $Excel | Close-Excel -Path "$NewXLSXFile`2"
            Test-Path "$NewXLSXFile`2" | Should be $True
            Remove-Item "$NewXLSXFile`2" -Force -ErrorAction SilentlyContinue
        }
    }
}



Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
