$moduleName = "PSIASTAND"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Global:testData = "$here\data"
Import-Module "$here\..\$($moduleName)"
Get-ChildItem "$here" -Filter "Pester*.csv" | Remove-Item
$Results = Invoke-Pester -PassThru
$results.TestResult | Export-Csv "$here\PesterResults_T-$($results.TotalCount)_P-$($results.PassedCount)_F-$($results.FailedCount)_S-$($results.SkippedCount).csv" -NoTypeInformation
Remove-Module $moduleName
