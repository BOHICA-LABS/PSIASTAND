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

Describe "Search-CellValue PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'Should find cells' {

            $Result = @( Search-CellValue -Path $ExistingXLSXFile -FilterScript {$_ -eq "Prop2" -or ($_ -is [datetime] -and $_.day -like 7)} )
            $Result.Count | Should be 2
            $Result[0].Row | Should be 3
            $Result[0].Match | Should be 'Prop2'

        }

        It 'Should return raw when specified' {
            $Result = @( Search-CellValue -Path $ExistingXLSXFile -FilterScript {$_ -eq 'Prop3'} -as Raw )
            $Result.count | Should be 1
            $Result[0] -is [string] | Should be $True
        }

        It 'Should return ExcelRange if specified' {
            $Result = @( Search-CellValue -Path $ExistingXLSXFile -FilterScript {$_ -is [string]} -as Passthru )
            $Result.count | Should be 13
            $Result[0] -is [OfficeOpenXml.ExcelRangeBase] | Should be $True
        }
    }
}
Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
