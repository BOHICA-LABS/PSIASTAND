function Update-Controls {
<#
.SYNOPSIS

.PARAMETER report

.PARAMETER diacap

.PARAMETER rmf

.EXAMPLE

.LINK

.VERSION
1.0.0 (02.16.2016)
    -Intial Release
#>

    [CmdletBinding()]
    Param(
        [Object]$report = $(Throw "No report Provided"),
        [switch]$diacap,
        [switch]$rmf
    )
}
