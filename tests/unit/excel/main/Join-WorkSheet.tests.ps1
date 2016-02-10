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

Describe "Join-Worksheet PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'Should join worksheets' {

            #Get the worksheets to join:
                $JoinPath = "$PSScriptRoot\JoinTest.xlsx"
                $Excel = New-Excel -Path $JoinPath
                $LeftWorksheet = Get-Worksheet -Excel $Excel -Name 'Left'
                $RightWorksheet = Get-WorkSheet -Excel $Excel -Name 'Right'

            #We have the data - join it where Left.Name = Right.Manager
                Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force
                Join-Worksheet -Path $NewXLSXFile -LeftWorksheet $LeftWorksheet -RightWorksheet $RightWorksheet -LeftJoinColumn Name -RightJoinColumn Manager
                $Excel | Close-Excel

            #Verify the output:
                $Result = @( Import-XLSX -Path $NewXLSXFile )

                $Result.count | Should Be 5
                $Names = $Result | Select -ExpandProperty Name
                $ExpectedNames = echo jsmith1, jsmith2, jsmith3, 'Department 4', 'Department 5'

                @(Compare-Object $Names $ExpectedNames).count | Should Be 0
                @($Result | ?{$_.Name -eq 'jsmith2'})[0].Manager -like $null | Should Be $true
        }
    }
}
#Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
