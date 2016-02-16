function Expand-ZIP {
<#
.SYNOPSIS
This function takes a zip archive and extracts to a folder

.PARAMETER source
This is the Zip Archive

.PARAMETER destination
This is the destiniation


.EXAMPLE

.LINK

.VERSION
1.0.0 (02.14.2016)
    -Intial Release

#>


    Param(
        [string]$source = $(Throw "No Source Provided"),
        [string]$destination = $(Throw "No destination Provided")
    )

    if (Test-Path -Path $destination) {
        Throw "$($destination) Already Exist"
    }

    Add-Type -AssemblyName "system.io.compression.filesystem"
    [io.compression.zipfile]::ExtractToDirectory($source, $destination)

}
