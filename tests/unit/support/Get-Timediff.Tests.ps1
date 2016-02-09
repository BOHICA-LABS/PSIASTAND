$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\functions\support\$sut"

$moduleName = "PSIASTAND"

Import-Module "$here\..\..\..\$($moduleName)"
#InModuleScope nessusOpenPorts {
    Describe "Get-Timediff" {
        It "should return 1 hour difference" {
            Get-Timediff -Start $(Get-Date -Hour 1 -Minute 1 -Second 1 -Format HH:mm:ss) -End $(Get-Date -Hour 2 -Minute 1 -Second 1 -Format HH:mm:ss) | Should Be "1:0:0"
        }

        It "should return 1 minute difference" {
            Get-Timediff -Start $(Get-Date -Hour 1 -Minute 1 -Second 1 -Format HH:mm:ss) -End $(Get-Date -Hour 1 -Minute 2 -Second 1 -Format HH:mm:ss) | Should Be "0:1:0"
        }

        It "should return 1 second difference" {
            Get-Timediff -Start $(Get-Date -Hour 1 -Minute 1 -Second 1 -Format HH:mm:ss) -End $(Get-Date -Hour 1 -Minute 1 -Second 2 -Format HH:mm:ss) | Should Be "0:0:1"
        }

        It "should throw No Start Time Provided" {
            {Get-Timediff} | Should Throw "No Start Time Provided"
        }

        It "should throw No End Time Provided" {
            {Get-Timediff -Start $(Get-Date -Hour 1 -Minute 1 -Second 1 -Format HH:mm:ss)} | Should Throw "No End Time Provided"
        }
    }
#}
Remove-Module $moduleName
