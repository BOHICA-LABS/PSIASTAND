function Get-NessusFile {
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
        [string]$Path = $(Throw "No Path Provided"),

        [Parameter(Mandatory = $false)]
        [switch]$recursive
    )

    if($recursive){
        Try {
            $Private:listing = & $SafeCommands['Get-ChildItem'] -Path $Path -Filter "*.nessus" -Recurse -ErrorAction Stop -ErrorVariable GETITEM
        }
        Catch {
            if($GETITEM) {
                Throw "path not found"
            }
        }
    }
    else {
        Try {
            $Private:listing = & $SafeCommands['Get-ChildItem'] -Path $Path -Filter "*.nessus" -ErrorAction Stop -ErrorVariable GETITEM
        }
        Catch {
            if($GETITEM) {
                Throw "path not found"
            }
        }
    }
    if(!($Private:listing)){
        Throw "No Nessus Files Found"
    }
    else {
        return $Private:listing
    }
}
