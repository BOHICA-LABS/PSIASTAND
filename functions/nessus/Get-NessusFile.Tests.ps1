$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$moduleName = "nessusOpenPorts"

#Import-Module "..\$($moduleName)"
#InModuleScope nessusOpenPorts {
    Describe "Get-NessusFile" {
        Setup -File somefile.nessus
        Setup -File somefile.test.nessus
        Setup -File somefile.text
        Setup -File somefile.test.txt
        Setup -Dir Temp
        setup -Dir Recur
        Setup -File Recur\filesome.nessus
        Setup -File Recur\filesomemore.txt

        It "should find nessus files none-recursive" {
            $files = Get-NessusFile -Path TestDrive:\
            $files.Count | Should Be 2
        }

        It "should find nessus files recursive" {
            $files = Get-NessusFile -Path TestDrive:\ -recursive
            $files.Count | Should Be 3
        }

        It "should throw No Nessus Files Found" {
            {Get-NessusFile -Path TestDrive:\Temp} | Should Throw "No Nessus Files Found"
        }

        It "should throw path not found" {
            {Get-NessusFile -Path TempDrive:\Temp} | Should Throw "path not found"
        }

        IT "should throw No Path Provided" {
            {Get-NessusFile} | Should Throw "No Path Provided"
        }
    }
#}
#Remove-Module $moduleName
