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

Import-Module "$here\..\..\..\..\$($moduleName)"

$SQLiteFile = "$here\Working.SQLite"
Remove-Item $SQLiteFile  -force -ErrorAction SilentlyContinue
Copy-Item $here\Names.SQLite $here\Working.SQLite -force
$Script:Connection = New-SQLiteConnection @Verbose -DataSource :MEMORY:

Describe "Invoke-SQLiteQuery (Requires New-SQLiteConnection) PS$PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should take file input' {
            $Out = @( Invoke-SqliteQuery @Verbose -DataSource $SQLiteFile -InputFile $PSScriptRoot\Test.SQL )
            $Out.count | Should be 2
            $Out[1].OrderID | Should be 500
        }

        It 'should take query input' {
            $Out = @( Invoke-SQLiteQuery @Verbose -Database $SQLiteFile -Query "PRAGMA table_info(NAMES)" -ErrorAction Stop )
            $Out.count | Should Be 4
            $Out[0].Name | SHould Be "fullname"
        }

        It 'should support parameterized queries' {

            $Out = @( Invoke-SQLiteQuery @Verbose -Database $SQLiteFile -Query "SELECT * FROM NAMES WHERE BirthDate >= @Date" -SqlParameters @{
                Date = (Get-Date 3/13/2012)
            } -ErrorAction Stop )
            $Out.count | Should Be 1
            $Out[0].fullname | Should Be "Cookie Monster"

            $Out = @( Invoke-SQLiteQuery @Verbose -Database $SQLiteFile -Query "SELECT * FROM NAMES WHERE BirthDate >= @Date" -SqlParameters @{
                Date = (Get-Date 3/15/2012)
            } -ErrorAction Stop )
            $Out.count | Should Be 0
        }

        It 'should use existing SQLiteConnections' {
            Invoke-SqliteQuery @Verbose -SQLiteConnection $Script:Connection -Query "CREATE TABLE OrdersToNames (OrderID INT PRIMARY KEY, fullname TEXT);"
            Invoke-SqliteQuery @Verbose -SQLiteConnection $Script:Connection -Query "INSERT INTO OrdersToNames (OrderID, fullname) VALUES (1,'Cookie Monster');"
            @( Invoke-SqliteQuery @Verbose -SQLiteConnection $Script:Connection -Query "PRAGMA STATS" ) |
                Select -first 1 -ExpandProperty table |
                Should be 'OrdersToNames'

            $Script:COnnection.State | Should Be Open

            $Script:Connection.close()
        }

        It 'should respect PowerShell expectations for null' {

            #The SQL folks out there might be annoyed by this, but we want to treat DBNulls as null to allow expected PowerShell operator behavior.

            $Connection = New-SQLiteConnection -DataSource :MEMORY:
            Invoke-SqliteQuery @Verbose -SQLiteConnection $Connection -Query "CREATE TABLE OrdersToNames (OrderID INT PRIMARY KEY, fullname TEXT);"
            Invoke-SqliteQuery @Verbose -SQLiteConnection $Connection -Query "INSERT INTO OrdersToNames (OrderID, fullname) VALUES (1,'Cookie Monster');"
            Invoke-SqliteQuery @Verbose -SQLiteConnection $Connection -Query "INSERT INTO OrdersToNames (OrderID) VALUES (2);"

            @( Invoke-SqliteQuery @Verbose -SQLiteConnection $Connection -Query "SELECT * FROM OrdersToNames" -As DataRow | Where{$_.fullname}).count |
                Should Be 2

            @( Invoke-SqliteQuery @Verbose -SQLiteConnection $Connection -Query "SELECT * FROM OrdersToNames" | Where{$_.fullname} ).count |
                Should Be 1
            $Connection.close()
        }
    }
}

Remove-Module $moduleName
Remove-Item $SQLiteFile -force -ErrorAction SilentlyContinue
