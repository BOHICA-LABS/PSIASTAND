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

Describe -tag 'Get-CellValue' "Get-CellValue PS: $PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'Should get a value from an Excel object' {
            Copy-Item -Path $ExistingXLSXFile -Destination $NewXLSXFile -Force

            $Excel = New-Excel -Path $NewXLSXFile

            $Result = @($Excel | Get-CellValue -Coordinates "A2:A3")
            $Result[0].Name | Should be 'Prop1'
            $Result[1].Name | Should be 'Prop2'
            $Result.Count | Should be 2
        }
        It 'Should get a value from an Excel file' {
            Copy-Item -Path $ExistingXLSXFile -Destination $NewXLSXFile -Force

            $Result = @( Get-CellValue -Path $NewXLSXFile -Coordinates "B2:B2" )
            $Result[0].Val | Should be 944041859
            $Result.Count | Should be 1
        }
    }
}
#Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
