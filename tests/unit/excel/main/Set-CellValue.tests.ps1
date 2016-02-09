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

Describe "Set-CellValue PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'Should set a value based on CellRange' {
            Copy-Item -Path $ExistingXLSXFile -Destination $NewXLSXFile -Force

            $Excel = New-Excel -Path $NewXLSXFile

            $Excel | Search-CellValue {$_ -eq "Prop2"} -As Passthru | Set-CellValue -Value "REDACTED"
            $Excel | Save-Excel

            $Result = @( Import-XLSX -Path $NewXLSXFile )
            $Result[1].Name | Should be 'REDACTED'
        }
        It 'Should set a value based on Path' {
            Copy-Item -Path $ExistingXLSXFile -Destination $NewXLSXFile -Force

            Set-CellValue -Coordinates "A2:A3" -Path $NewXLSXFile -Value "REDACTED"
            $Result = @( Import-XLSX -Path $NewXLSXFile )
            $Result[0].Name | Should be 'REDACTED'
            $Result[1].Name | Should be 'REDACTED'
        }

    }
}
Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
