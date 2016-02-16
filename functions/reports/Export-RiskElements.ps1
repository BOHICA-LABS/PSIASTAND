function Export-RiskElements {
<#
.SYNOPSIS
Imports files containing RISK elements and outputs a unique list of the elements

.PARAMETER CKLFILES

.PARAMETER NESSUS

.PARAMETER DIACAP

.PARAMETER RMF

.PARAMETER Name

.PARAMETER Output

.PARAMETER mergecontrol

.PARAMETER recursive

.EXAMPLE

.LINK

.VERSION
1.0.0 (02.15.2016)
    -Intial Release
#>
    [CmdletBinding(DefaultparameterSetName="None")]
    Param(
        [Parameter(Mandatory=$false,HelpMessage="Please provide the folder path to the CKL files to process")]
        [string]$CKLFILES = $null,

        [Parameter(Mandatory=$false,HelpMessage="Please provide the location of the .nessus files to process")]
        [string]$NESSUS = $null,

        [Parameter(Mandatory=$false,HelpMessage="Please provide the location of the 8500 controls file to process")]
        [string]$DIACAP = $null,

        [Parameter(Mandatory=$false,HelpMessage="Please provide the location of the RMF controls file to process")]
        [string]$RMF = $null,

        [Parameter(Mandatory=$false,HelpMessage="Please provide the name of IS (Information System) or package name")]
        [string]$Name = $(Throw "No Name was provided"),

        [Parameter(Mandatory=$false,HelpMessage="You must provide the folder path to be used for the output. If the location provided does not exsist it will be created")]
        [string]$Output = $(Throw "No output path given"),

        [Parameter(Mandatory=$false,HelpMessage="Switch to merge IA controls that fail from the CKL into the Control import")]
        [switch]$mergecontrol,

        [Parameter(Mandatory=$false,HelpMessage="Switch to recursivly look for risk element files")]
        [switch]$recursive
    )

    BEGIN {
        if (!$CKLFILES -and !$NESSUS -and !$DIACAP -and !$RMF){Throw "Nothing to process"}
        if ($DIACAP -and $RMF) { # check to see if DIACAP and RMF are specified
            Throw "Both DIACAP and RMF Specified. Please select DIACAP OR RMF"
        }

        if ($recursive) { # recursive loop for files
            if ($CKLFILES) {
                if(!(Test-Path -Path $CKLFILES)) {Throw "CKL Path not found"}
                $cfiles = Get-ChildItem -Path $CKLFILES -Filter "*.ckl" -Recurse
                if ($cfiles.count -lt 1) {Throw "No CKL files found"}
            }
            if ($NESSUS) {
                if(!(Test-Path -Path $NESSUS)) {Throw "Nessus Path not found"}
                $nFiles = Get-ChildItem -Path $NESSUS -Filter "*.nessus" -Recurse
                if ($nfiles.count -lt 1) {Throw "No NESSUS files found"}
            }
        }
        else {
            if ($CKLFILES) {
                if(!(Test-Path -Path $CKLFILES)) {Throw "CKL Path not found"}
                $cfiles = Get-ChildItem -Path $CKLFILES -Filter "*.ckl"
                if ($cfiles.count -lt 1) {Throw "No CKL files found"}
            }
            if ($NESSUS) {
                if(!(Test-Path -Path $NESSUS)) {Throw "Nessus Path not found"}
                $nFiles = Get-ChildItem -Path $NESSUS -Filter "*.nessus"
                if ($nfiles.count -lt 1) {Throw "No NESSUS files found"}
            }
        }

        if ($DIACAP) {
            $controlfile = Get-Item -Path $DIACAP
            if ($controlfile.count -lt 1) {Throw "No DIACAP files found"}
        }
        if ($RMF) {
            $controlfile = Get-Item -Path $RMF
            if ($controlfile.count -lt 1) {Throw "No RMF files found"}
        }
    }
    PROCESS {

        if($CKLFILES) { # if CKL
            Try {
                $compiledCKLObj = @()
                foreach ($file in $cfiles) { # Process CKL Files
                    $xml = Import-XML -fileobj $file
                    $ckl = Import-CKL -doc $xml
                    $compiledCKLObj += $ckl
                } # End For loop
                $filteredcompiledCKLObj = $compiledCKLObj | Where-Object{$_.Status -match "Open"}
                $compressedcompiledCKLObj = Compress-Report -report $filteredcompiledCKLObj -ckl
                $riskelementCKLObj = ConvertTo-RiskElements -report $compressedcompiledCKLObj -ckl
            }
            Catch{
                Throw "$($file.name) CKL failed to process"
            }
        } # end if CKL

        if ($NESSUS) { # If Nessus
            Try {
                $compiledNessusObj = @()
                foreach ($file in $nFiles) { # Process Nessus Files
                    $xml = Import-XML -fileobj $file
                    $nes = Import-Nessus -doc $xml
                    $compiledNessusObj += $nes
                } # end for loop
               $filteredcompiledNessusObj = $compiledNessusObj | Where-Object{$_.risk_factor -notmatch "None"}
               $compressedcompiledNessusObj = Compress-Report -report $filteredcompiledNessusObj -nessus
               $riskelementNessusObj = ConvertTo-RiskElements -report $compressedcompiledNessusObj -nessus
            }
            Catch {
                Throw "$($file.name) Nessus failed to process"
            }
        } # end if Nessus

        if ($DIACAP) { # If DIACAP
            Try {
                $IAControlXLSX = Import-XLSX -Path $($controlfile.FullName)
                $IAControl = Import-DIACAP -doc $IAControlXLSX
                if ($mergecontrol) {
                    $finalControl = Join-Controls -controls $IAControl -ckl $compressedcompiledCKLObj -DIACAP
                }
                else {
                    $finalControl = $IAControl
                }
                $filteredfinalControl = $finalControl | Where-Object{$_."Assessment Status" -match "Fail"}
                $riskelementControl = ConvertTo-RiskElements -report $filteredfinalControl -diacap
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
        $riskelements = $null
        if ($riskelementCKLObj) {
            $riskelements += $riskelementCKLObj
        }
        if ($riskelementNessusObj) {
            $riskelements += $riskelementNessusObj
        }
        if ($riskelementControl) {
            $riskelements += $riskelementControl
        }

        Export-XLSX -PATH "$($Output)\$($name)_Risk.xlsx" -InputObject $riskelements
    }
}
