function Invoke-NessusOpenPorts {
<#
.SYNOPSIS
This module consumes nessus files and output the open ports detected on the host

.PARAMETER Nessu
The location of the nessus file(s)

.PARAMETER packagename
The Name of the package

.PARAMETER outPut
The location you want the output

.EXAMPLE

.LINK

.VERSION
2.0.0 (01.05.2016)
    -Refactor the code to include better functions, unit testing, and modulized the code base
1.0.0 ()
    -Intial Release

#>

    [CmdletBinding(DefaultparameterSetName="None")]
    Param(
        [Parameter(Mandatory=$true,Position=0,HelpMessage="Location of Nessus File")]
        [ValidateNotNull()]
        [string]$Nessus,

        [Parameter(Mandatory=$true,Position=2,HelpMessage="Provide the name of the package for report generation")]
        [ValidateNotNull()]
        [string]$packagename,

        [Parameter(Mandatory=$true,Position=1,HelpMessage="You must provide the folder path for the report")]
        [ValidateNotNull()]
        [string]$outPut,

        [Parameter(Mandatory=$false,Position=1,HelpMessage="Recursive switch for get nessus files")]
        [switch]$recursive


    )

    BEGIN {
        # initialize global variables
        $script:start = & $script:SafeCommands['Get-Date']
        $script:dateObject = & $script:SafeCommands['new-object'] system.globalization.datetimeformatinfo
        $script:_output = $outPut.Trim('"').Trim("'")
        $script:reportName = "$($packagename)_OpenPorts_$($script:start.Day)$($script:dateObject.GetMonthName($script:start.Month))$($script:start.Year).csv"
        $script:reportNoPortName = "$($packagename)_NoOpenPorts_$($script:start.Day)$($script:dateObject.GetMonthName($script:start.Month))$($script:start.Year).csv"

        Try {
            & $script:SafeCommands['Write-Verbose'] -Message "BEGIN BLOCK - Start Time: $($script:start)"
            & $script:SafeCommands['Write-Verbose'] -Message "BEGIN BLOCK - Creating Output Directory: $($script:_output)"
            $null = Get-OutPutDir -Path $script:_output -ErrorAction Stop -ErrorVariable ERRORBEGINCHECKOUTPUTDIR
            & $script:SafeCommands['Write-Verbose'] -Message "BEGIN BLOCK - Looking for Nessus Files"
            if($recursive) {
                $script:nessusFileList = GET-NessusFile -Path $NESSUS -recursive -ErrorAction Stop -ErrorVariable ERRORBEGINGETNESSUSFILES
            }
            else {
                $script:nessusFileList = GET-NessusFile -Path $NESSUS -ErrorAction Stop -ErrorVariable ERRORBEGINGETNESSUSFILES
            }
            & $script:SafeCommands['Write-Verbose'] -Message "Found $($script:nessusFileList.Count) Nesssus File(s)"
            & $script:SafeCommands['Write-Verbose'] -Message "BEGIN BLOCK - End time: $(& $script:SafeCommands['Get-Date'])"
        }
        Catch {
            & $script:SafeCommands['Write-Verbose'] -Message "BEGIN BLOCK - Something has gone wrong"
            if($ERRORBEGINCHECKOUTPUTDIR) {
                & $script:SafeCommands['Write-Verbose'] -Message "BEGIN BLOCK - Could not create output directory at $($script:_output)"
                & $script:SafeCommands['Write-Verbose'] -Message "BEGIN BLOCK - Running Time Before Error: $(Get-Timediff -start $script:start -end $(& $script:SafeCommands['Get-Date']))"
                Throw $ERRORBEGINCHECKOUTPUTDIR[1]
            }
            if($ERRORBEGINGETNESSUSFILES) {
                & $script:SafeCommands['Write-Verbose'] -Message "BEGIN BLOCK - Cannot find $($Nessus)"
                & $script:SafeCommands['Write-Verbose'] -Message "BEGIN BLOCK - Running Time Before Error: $(Get-Timediff -start $script:start -end $(& $script:SafeCommands['Get-Date']))"
                Throw $ERRORBEGINGETNESSUSFILES
            }
        }
    }
    Process {
        Try {
            & $script:SafeCommands['Write-Verbose'] -Message "PROCESS BLOCK - Start Time: $(& $script:SafeCommands['Get-Date'])"
            & $script:SafeCommands['Write-Verbose'] -Message "PROCESS BLOCK - Starting to process Nessus Files"
            $Script:compiledNessusObjReal = @()
            $Script:noportsDetectedReal = @()
            foreach($script:file in $script:nessusFileList) {
                & $script:SafeCommands['Write-Verbose'] -Message "PROCESS BLOCK - Processing: $($script:file.Name)"
                $Script:compiledNessusObj, $Script:noportsDetected = $(Import-NessusOpenPortsPlugin -file $script:file -ErrorAction Stop -ErrorVariable ERRORPROCESSPROCESSNESSUSFILE)
                $Script:compiledNessusObjReal += $Script:compiledNessusObj
                $Script:noportsDetectedReal += $Script:noportsDetected
            }
            & $script:SafeCommands['Write-Verbose'] -Message "PROCESS BLOCK - End Time: $(& $script:SafeCommands['Get-Date'])"
        }
        Catch{
            & $script:SafeCommands['Write-Verbose'] -Message "PROCESS BLOCK - Something has gone wrong"
            if($ERRORPROCESSPROCESSNESSUSFILE) {
                & $script:SafeCommands['Write-Verbose'] -Message "PROCESS BLOCK - $($script:file.FullName) did not validate as a proper Nessus File"
                & $script:SafeCommands['Write-Verbose'] -Message "PROCESS BLOCK - Running Time Before Error: $(Get-Timediff -start $script:start -end $(& $script:SafeCommands['Get-Date']))"
                Throw $ERRORPROCESSPROCESSNESSUSFILE[1]
            }
        }
    }
    END {
        $Script:end = & $script:SafeCommands['Get-Date']
        Try{
            & $script:SafeCommands['Write-Verbose'] -Message "END BLOCK - Start Time: $(& $script:SafeCommands['Get-Date'])"
            & $script:SafeCommands['Write-Verbose'] -Message "END BLOCK - Exporting Open Ports to: $($script:_output)\$script:reportName"
            $Script:compiledNessusObjReal | Export-Csv -Path "$($script:_output)\$script:reportName" -NoTypeInformation -ErrorAction Stop -ErrorVariable ERRORENDCREATECSVREPORT
            if($Script:noportsDetectedReal) {
                $Script:noportsDetectedReal | Export-Csv -Path "$($script:_output)\$script:reportNoPortName" -NoTypeInformation -ErrorAction Stop -ErrorVariable ERRORENDCREATECSVREPORT
            }
            & $script:SafeCommands['Write-Verbose'] -Message "END BLOCK - End Time: $(& $script:SafeCommands['Get-Date'])"
            & $script:SafeCommands['Write-Verbose'] -Message "END BLOCK - Total Script Run Time: $(Get-Timediff -start $script:start -end $Script:end)"
        }
        Catch{
            & $script:SafeCommands['Write-Verbose'] -Message  "END BLOCK - Something has gone wrong"
            if($ERRORENDCREATECSVREPORT) {
                & $script:SafeCommands['Write-Verbose'] -Message "END BLOCK - Could not create Report"
                & $script:SafeCommands['Write-Verbose'] -Message "PROCESS BLOCK - Running Time Before Error: $(Get-Timediff -start $script:start -end $Script:end))"
                Throw $ERRORENDCREATECSVREPORT
            }
        }
    }
}
