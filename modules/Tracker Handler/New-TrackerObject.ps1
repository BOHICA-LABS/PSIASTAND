function New-TrackerObject () {
  <#
    .SYNOPSIS

    .PARAMETER

    .EXAMPLE
    $Tracker = New-TrackerObject

    .LINK

    .VERSION
        1.0.0.1 (24APR2017)
            -Initial

#>

    $Tracker = @{}

    #Create the Tracker object array
    $Tracker.Data = @{}

    #Creates the error handling return array
    $Tracker.error = @{}

    Add-Member -InputObject $Tracker -MemberType ScriptMethod -name 'ImportFromFile' -value {
        Param(
            [Parameter(Mandatory=$true)]
            [string]$file`
        )

        #Validate the presence of the file provided
        if (!(Test-Path $file)){
            $this.error = @{ Success = $false; errorType = "File Not Found"}
            return
        }else{
            Write-Verbose "File $file located"
        }

        ### TODO need some validation that this was successful
        $trackerFile = Import-XLSX $file
        Write-Verbose "Excel $file loaded into memory"

        # Checks to see if the tracker is in the correct format.

        $this.Data = @{
            Success = $true
            Data = $trackerFile
        }

        #clears the error hashtable on success
        $this.error = @{
            Success = $true
            errorType = $null
        }
    }

    return $Tracker
}