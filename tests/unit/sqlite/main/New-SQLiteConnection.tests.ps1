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

Describe -tag 'New-SQLiteConnection' "New-SQLiteConnection PS: $PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should create a connection' {
            $Connection = New-SQLiteConnection @Verbose -DataSource :MEMORY:
            $Connection.ConnectionString | Should be "Data Source=:MEMORY:;"
            $Connection.State | Should be "Open"
            $Connection.close()
        }
    }
}

#Remove-Module $moduleName
Remove-Item $SQLiteFile -force -ErrorAction SilentlyContinue
