function Get-Timediff {
<#
.SYNOPSIS
This function looks in the provided directory(s) and returns all files that end in .nessus

.PARAMETER Path
The location of the nessus file(s)

.PARAMETER recurse
This is a switch and tells the function if it should traverse the path that it was given looking for all
nessus files

.EXAMPLE

.LINK

.VERSION
1.0.0 (01.05.2016)
    -Intial Release

#>

    [CmdletBinding()]
    Param(
        [ValidateNotNull()]
        [DateTime]$start= $(Throw "No Start Time Provided"),

        [ValidateNotNull()]
        [DateTime]$end = $(Throw "No End Time Provided")
    )

    $Private:diff = & $SafeCommands['New-TimeSpan'] -Start $start -End $end
    return "$($Private:diff.hours):$($Private:diff.minutes):$($Private:diff.seconds)"
}
