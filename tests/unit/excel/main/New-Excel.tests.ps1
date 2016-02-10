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


Describe "New-Excel PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should create an ExcelPackage' {
            $Excel = New-Excel
            $Excel -is [OfficeOpenXml.ExcelPackage] | Should Be $True
            $Excel.Dispose()
            $Excel = $Null

            $Excel = New-Excel -Path $NewXLSXFile
            $Excel -is [OfficeOpenXml.ExcelPackage] | Should Be $True
            $Excel.Dispose()
            $Excel = $Null

        }

        It 'should reflect the correct path' {
            Remove-Item $NewXLSXFile -force -ErrorAction silentlycontinue
            $Excel = New-Excel -Path $NewXLSXFile
            $Excel.File | Should be $NewXLSXFile
            $Excel.Dispose()
            $Excel = $Null
        }

        It 'should not create a file' {
            Test-Path $NewXLSXFile | Should Be $False
        }
    }
}
#Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
