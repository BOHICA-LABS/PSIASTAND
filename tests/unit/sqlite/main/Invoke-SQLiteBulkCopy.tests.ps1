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

$DataTable = 1..1000 | %{
                New-Object -TypeName PSObject -property @{
                    fullname = "Name $_"
                    surname = "Name"
                    givenname = "$_"
                    BirthDate = (Get-Date).Adddays(-$_)
                } | Select fullname, surname, givenname, birthdate
            } | Out-DataTable @Verbose

Describe -tag 'Invoke-SQLiteBulkCopy' "Invoke-SQLiteBulkCopy (Requires Out-DataTable) PS: $PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should insert data' {
            Invoke-SQLiteBulkCopy @Verbose -DataTable $Script:DataTable -DataSource $SQLiteFile -Table Names -NotifyAfter 100 -force

            @( Invoke-SQLiteQuery @Verbose -Database $SQLiteFile -Query "SELECT fullname FROM NAMES WHERE surname = 'Name'" ).count | Should Be 1000
        }
        It "should adhere to ConflictCause" {

            #Basic set of tests, need more...

            #Try adding same data
            { Invoke-SQLiteBulkCopy @Verbose -DataTable $Script:DataTable -DataSource $SQLiteFile -Table Names -NotifyAfter 100 -force } | Should Throw

            #Change a known row's prop we can test to ensure it does or does not change
            $Script:DataTable.Rows[0].surname = "Name 1"
            { Invoke-SQLiteBulkCopy @Verbose -DataTable $Script:DataTable -DataSource $SQLiteFile -Table Names -NotifyAfter 100 -force } | Should Throw

            $Result = @( Invoke-SQLiteQuery @Verbose -Database $SQLiteFile -Query "SELECT surname FROM NAMES WHERE fullname = 'Name 1'")
            $Result[0].surname | Should Be 'Name'

            { Invoke-SQLiteBulkCopy @Verbose -DataTable $Script:DataTable -DataSource $SQLiteFile -Table Names -NotifyAfter 100 -ConflictClause Rollback -Force } | Should Throw

            $Result = @( Invoke-SQLiteQuery @Verbose -Database $SQLiteFile -Query "SELECT surname FROM NAMES WHERE fullname = 'Name 1'")
            $Result[0].surname | Should Be 'Name'

            Invoke-SQLiteBulkCopy @Verbose -DataTable $Script:DataTable -DataSource $SQLiteFile -Table Names -NotifyAfter 100 -ConflictClause Replace -Force

            $Result = @( Invoke-SQLiteQuery @Verbose -Database $SQLiteFile -Query "SELECT surname FROM NAMES WHERE fullname = 'Name 1'")
            $Result[0].surname | Should Be 'Name 1'


        }
    }
}

#Remove-Module $moduleName
Remove-Item $SQLiteFile -force -ErrorAction SilentlyContinue
