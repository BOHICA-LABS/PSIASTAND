$here = Split-Path -Parent $MyInvocation.MyCommand.Path
#$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\main\$sut"

$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

$moduleName = "PSIASTAND"

$PSVersion = $PSVersionTable.PSVersion.Major

#Import-Module "$here\..\..\..\..\$($moduleName)"

$SQLiteFile = "$here\Working.SQLite"
Remove-Item $SQLiteFile  -force -ErrorAction SilentlyContinue
Copy-Item $here\Names.SQLite $here\Working.SQLite -force

Describe "Out-DataTable PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should create a DataTable' {

            $DataTable = 1..1000 | %{
                New-Object -TypeName PSObject -property @{
                    fullname = "Name $_"
                    surname = "Name"
                    givenname = "$_"
                    BirthDate = (Get-Date).Adddays(-$_)
                } | Select fullname, surname, givenname, birthdate
            } | Out-DataTable @Verbose

            $DataTable.GetType().Fullname | Should Be 'System.Data.DataTable'
            @($DataTable.Rows).Count | Should Be 1000
            $Columns = $DataTable.Columns | Select -ExpandProperty ColumnName
            $Columns[0] | Should Be 'fullname'
            $Columns[3] | Should Be 'BirthDate'
            $DataTable.columns[3].datatype.fullname | Should Be 'System.DateTime'

        }
    }
}

#Remove-Module $moduleName
Remove-Item $SQLiteFile -force -ErrorAction SilentlyContinue
