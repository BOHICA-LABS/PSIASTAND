$moduleName = "PSIASTAND"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module "$here\..\$($moduleName)"
Invoke-Pester
Remove-Module $moduleName
