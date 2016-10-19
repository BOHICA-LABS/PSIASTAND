function Update-Controls {
<#
.SYNOPSIS

.PARAMETER path

.PARAMETER CKL

.PARAMETER Output

.PARAMETER name

.PARAMETER diacap

.PARAMETER rmf

.PARAMETER recursive

.EXAMPLE

.LINK

.VERSION
1.0.0 (02.16.2016)
    -Intial Release
#>

    [CmdletBinding()]
    Param(
        [string]$path = $(Throw "No path Provided"),
        [string]$ckl = $(Throw "No CKL Path Provided"),
        [string]$output = $(Throw "No Output folder provided"),
        [String]$name = $(Throw "No Name provided"),
        [switch]$diacap,
        [switch]$rmf,
        [switch]$recursive
    )

    BEGIN {
        if (!$DIACAP -and !$RMF) {Throw "No report type selected"}
        if ($DIACAP -and $RMF) {Throw "Both DIACAP and RMF Selected"}
        if ($recursive) {
            if(!(Test-Path -Path $ckl)) {Throw "CKL Path not found"}
            $cfiles = Get-ChildItem -Path $ckl -Filter "*.ckl" -Recurse
            if ($cfiles.count -lt 1) {Throw "No CKL files found"}
        }
        else {
            if(!(Test-Path -Path $ckl)) {Throw "CKL Path not found"}
            $cfiles = Get-ChildItem -Path $ckl -Filter "*.ckl"
            if ($cfiles.count -lt 1) {Throw "No CKL files found"}
        }
        if ($DIACAP) {
            $controlfile = Get-Item -Path $path
            if ($controlfile.count -lt 1) {Throw "No DIACAP files found"}
        }
        if ($RMF) {
            $controlfile = Get-Item -Path $path
            if ($controlfile.count -lt 1) {Throw "No RMF files found"}
        }
    }
    PROCESS {
        Try {
            $compiledCKLObj = @()
            foreach ($file in $cfiles) { # Process CKL Files
                $xml = Import-XML -fileobj $file
                $cklfile = Import-CKL -doc $xml
                $compiledCKLObj += $cklfile
            } # End For loop
            $filteredcompiledCKLObj = $compiledCKLObj | Where-Object{$_.Status -match "Open"}
            $compressedcompiledCKLObj = $filteredcompiledCKLObj
            #$compressedcompiledCKLObj = Compress-Report -report $filteredcompiledCKLObj -ckl
        }
        Catch{
            Throw "$($file.name) CKL failed to process"
        }
        if ($DIACAP) { # If DIACAP
            Try {
                $IAControlXLSX = Import-XLSX -Path $($controlfile.FullName)
                $IAControl = Import-DIACAP -doc $IAControlXLSX
                $finalControl = Join-Controls -controls $IAControl -ckl $compressedcompiledCKLObj -DIACAP
            }
            Catch {
                Throw "$($controlfile.Name) IA Controls failed to process"
            }
        } # end if DIACAP

        if ($RMF) { # If RMF
            Try {
            }
            Catch {
            }
        } # end if RMF
    }
    END {
        if ($DIACAP) {
            Export-XLSX -Path "$($output)\$($name)_8500.2_Controls.xlsx" -InputObject $finalControl
        }
        else {
            Export-XLSX -Path "$($output)\$($name)_RMF_Controls.xlsx" -InputObject $finalControl
        }
    }
}
