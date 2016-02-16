$moduleName = "PSIASTAND"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Global:testData = "$here\data"
Import-Module "$here\..\$($moduleName)"
Invoke-Pester
Remove-Module $moduleName
