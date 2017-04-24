function New-SCAPObject () {
  <#
    .SYNOPSIS

    .PARAMETER

    .EXAMPLE
    $SCAP = New-SCAPObject

    .LINK

    .VERSION
        1.0.0.1 (06APR2017)
            -Initial

#>
    $SCAP = @{}

    #Create the SCAP object array
    $SCAP.Data = @{}

    #Creates the error handling return array
    $SCAP.error = @{}

    Add-Member -InputObject $SCAP -MemberType ScriptMethod -name 'ImportFromFile' -value {
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
        [XML]$SCAPFile = (Get-Content $file)
        Write-Verbose "XML $file loaded into memory"

        #Validate that the file is in SCAP format
        if(!($SCAPFile.Benchmark.style)){
            $this.Error = @{ Success = $false; errorType = "Invalid SCAP file."}
        }

        $this.Data = @{
            Success = $true
            SCAPVersion = $null
            SCAPData = @($SCAPFile.Benchmark)
        }

    }

    return $SCAP
}