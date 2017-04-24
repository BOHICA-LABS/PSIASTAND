function New-STIGObject () {
  <#
    .SYNOPSIS

    .PARAMETER

    .EXAMPLE
    $STIG = New-STIGObject

    .LINK

    .VERSION
        1.0.0.1 (06APR2017)
            -Initial

#>
    $STIG = @{}

    #Create the SCAP object array
    $STIG.Data = @{}

    #Creates the error handling return array
    $STIG.error = @{}

    Add-Member -InputObject $STIG -MemberType ScriptMethod -name 'ImportFromFile' -value {
        Param(
            [Parameter(Mandatory=$true)]
            [string]$file
        )

        #Validate the presence of the file provided
        if (!(Test-Path $file)){
            $this.error = @{ Success = $false; errorType = "File Not Found"}
            return
        }else{
            Write-Verbose "File $file located"
        }

        #Import the CKL file into an XML struct
        ### TODO: Need to validate if the file is XML before loading it to prevent errors
        [XML]$STIGFile = (Get-Content $file)
        Write-Verbose "XML $file loaded into memory"

        #Validate that the file is in SCAP format
        if(!($STIG)){
            $this.Error = @{ Success = $false; errorType = "Invalid Nessus file."}
        }



    }

    return $STIG
}