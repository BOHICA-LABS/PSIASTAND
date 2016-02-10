$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\functions\support\$sut"

$moduleName = "PSIASTAND"

#Import-Module "$here\..\..\..\$($moduleName)"
#InModuleScope nessusOpenPorts {
    Describe "Get-OutPutDir" {
        Setup -Dir Temp

        It "should return Path Exsists" {
            Get-OutPutDir -Path TestDrive:\Temp | Should Be 'Path Exsists'
        }

        It "should return Created Path" {
            Get-OutPutDir -Path TestDrive:\Test | Should Be 'Created Path'
        }

        It "Should Throw No Path Provided" {
            {Get-OutPutDir} | Should Throw "No Path Provided"
        }

        It "should throw unable to create at provided path" {
            {Get-OutPutDir -Path TempDrive:\Test} | Should Throw "unable to create at provided path: TempDrive:\Test"
        }
    }
#}
#Remove-Module $moduleName
