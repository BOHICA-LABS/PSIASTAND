function Compress-ZIP {
<#
.SYNOPSIS
This function takes a folder path and then a destination and will create zip archive

.PARAMETER source
This is the source folder

.PARAMETER destination
This is the destiniation for the zip


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
    [io.compression.zipfile]::CreateFromDirectory($source, $destination)
}
