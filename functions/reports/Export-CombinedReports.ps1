function Export-CombinedReports {
<#
.SYNOPSIS
This function loads Nessus and CKL files and outputs a combined CKL report and a nessus report in human readable form

.PARAMETER CKLFILES
Path to the CKL Files. We process from the CKL files
because they are in a standard format. We can import both v1 and v2
CKL files

.PARAMETER NESSUS
Path to the nessus Files.

.PARAMETER Output
This is the path where we output the reports

.PARAMETER name
This is the name/project/package that is being processed

.PARAMETER xlsx
This is a switch that allows you to output to xlsx instead of csv

.PARAMETER Recursive
Recursively find CKL and Nessus files


.EXAMPLE

.LINK

.VERSION
1.0.0 (02.10.2016)
    -Intial Release
1.0.0.1 (08.31.2016)
    -Corrected issue when xlsx was not specified the script would output
    a csv that did not contain the correct data.

#>

    [CmdletBinding(DefaultparameterSetName="None")]
    Param(
        [Parameter(Mandatory=$false,Position=0,HelpMessage="You must provide the folder path to the CKL files to process")]
        [Alias('Folder', 'location', 'CKL')]
        [string]$CKLFILES,

        [Parameter(Mandatory=$false,Position=1,HelpMessage="You must provide the location of the .nessus files to process")]
        [ValidateNotNull()]
        [Alias('A', 'SCAN','ACAS')]
        [string]$NESSUS,

        [Parameter(Mandatory=$false,Position=2,HelpMessage="You must provide the folder path to be used for the output. If the location provided does not exsist it will be created")]
        [ValidateNotNull()]
        [Alias('OUT', 'outlocation', 'O')]
        [string]$Output = $(Throw "No output path given"),

        [Parameter(Mandatory=$false,Position=3,HelpMessage="You must provide a name for the report that will be created.")]
        [ValidateNotNull()]
        [Alias('Report','N')]
        [string]$name,

        [Parameter(Mandatory=$false,Position=4,HelpMessage="Switch to designate output in excel. defualts to csv")]
        [switch]$xlsx,

        [Parameter(Mandatory=$false,Position=5,HelpMessage="Switch for recursive look for files")]
        [Alias('R')]
        [switch]$Recursive
    )

    BEGIN {
        if (!$CKLFILES -and !$NESSUS) { # Check to see if ckl or nessus paths where defined. if neither are defined throw an error
            Throw "No paths defined"
        }

        if ($CKLFILES) { # Check for CKL file(s) path
            if ((Test-Path -Path $CKLFILES)) { # Check path
                if ($Recursive) { # check for recursion
                    $Private:cfiles = Get-ChildItem -Path $CKLFILES -Filter "*.ckl" -Recurse
                }
                else {
                    $Private:cfiles = Get-ChildItem -Path $CKLFILES -Filter "*.ckl"
                }
                if (!$Private:cfiles) { # check to see if files are returned
                    Throw "No CKL Files Found"
                }
            }
            else { # path does not exist
                Throw "CKL path does not exist"
            }
        }

        if ($NESSUS) { # Check for Nessus file(s) path
            if ((Test-Path -Path $NESSUS)) { # Check path
                if ($Recursive) { # check for recursion
                    $Private:nessusfiles = Get-ChildItem -Path $NESSUS -Filter "*.nessus" -Recurse
                }
                else {
                    $Private:nessusfiles = Get-ChildItem -Path $NESSUS -Filter "*.nessus"
                }
                if (!$Private:nessusfiles) { # check to see if files are returned
                    Throw "No Nessus Files Found"
                }
            }
            else { # path does not exist
                Throw "NESSUS path does not exist"
            }
        }
    }
    PROCESS {
        if ($CKLFILES) { # if ckl path provided
            $Private:compiledCKLReport = @() # Compiled CKL
            $Private:cklversioncheck = 0 # Version check mismatched CKL version files will not work correctly
            foreach ($Private:file in $Private:cfiles) {
                Try {
                    $Private:xml = Import-XML -fileobj $Private:file -erroraction stop # Import XML
                    $Private:ckl = import-ckl -doc $Private:xml -erroraction stop # Import CKL from XML
                    if ($Private:cklversioncheck -eq 0) { # Set CKL Version Level
                        $Private:cklversioncheck = $Private:ckl[0].StigViewer_Version
                    }
                    elseif ($Private:ckl[0].StigViewer_Version -ne $Private:cklversioncheck) { # Check returned CKL version against approved CKL Version
                        Throw "$($Private:file.name) CKL Version mismatch error"
                    }
                    $Private:compiledCKLReport += $Private:ckl
                }
                Catch {
                    Throw "$($Private:file.name) CKL file failed to process"
                }
            }
        }
        if ($NESSUS) { # if Nessus path provided
            $Private:compilednessusreport = @() # Compiled Nessus
            foreach ($Private:file in $Private:nessusfiles) {
                $Private:xml = Import-XML -fileobj $Private:file -erroraction stop # Import XML
                $Private:nessusobj = Import-Nessus -doc $Private:xml # Import Nessus from XML
                $Private:compilednessusreport += $Private:nessusobj
            }
            foreach($Private:nobj in $Private:compilednessusreport) {
                $Private:nobj.description = $(if($($Private:nobj.description).length -gt 32768){$($Private:nobj.description).SubString(0,1000)}else{$Private:nobj.description})
                $Private:nobj.solution = $(if($($Private:nobj.solution).length -gt 32768){$($Private:nobj.solution).SubString(0,1000)}else{$Private:nobj.solution})
                $Private:nobj.synopsis = $(if($($Private:nobj.synopsis).length -gt 32768){$($Private:nobj.synopsis).SubString(0,1000)}else{$Private:nobj.synopsis})
                $Private:nobj.plugin_output = $(if($($Private:nobj.plugin_output).length -gt 32768){$($Private:nobj.plugin_output).SubString(0,1000)}else{$Private:nobj.plugin_output})
            }
        }
    }
    END {
        if ($xlsx) {
            if ($Private:compiledCKLReport) {
                Export-XLSX -Path "$($Output)\$($name)_CKL.xlsx" -InputObject $Private:compiledCKLReport
            }
            if ($Private:compilednessusreport) {
                Export-XLSX -Path "$($Output)\$($name)_Nessus.xlsx" -InputObject $Private:compilednessusreport
            }
        }
        else {
            if ($Private:compiledCKLReport) {
                $Private:compiledCKLReport | Export-Csv -Path "$($Output)\$($name)_CKL.csv" -NoTypeInformation
            }
            if ($Private:compilednessusreport) {
                $Private:compilednessusreport | Export-Csv -Path "$($Output)\$($name)_Nessus.csv"
            }
        }
    }
}

