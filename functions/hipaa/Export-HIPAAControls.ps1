function Export-HIPAAControls {
<#
.SYNOPSIS

.PARAMETER CKL

.PARAMETER Output

.PARAMETER name

.PARAMETER recursive

.EXAMPLE

.LINK

.VERSION
1.0.0 (02.16.2016)
    -Intial Release
#>
    [CmdletBinding()]
    Param(
        [object]$file = $(Throw "No CKL Path Provided")#,
        #[string]$output = $(Throw "No Output folder provided")
    )

    $matchObject = @()
    $lines = [System.IO.File]::ReadAllLines($file.FullName)
    foreach($line in $lines) {
        if ($line -match '^\s*$') {
            continue
        }
        else {
            $Private:entry = ($Private:entry = " " | select-object Control, Subcontrol, Check)
        }
        if ($line -match '^\d{3}\.\d{3}\s' -and $line -notmatch '^\d{3}\.\d{3}\(') {
            $Private:entry.Control = $($line.Trim())
            $controlholder = $($line.Trim())
        }
        else {
            $Private:entry.Control = $controlholder
        }
        if ($line -match '\d{3}\.\d{3}\(.+' -and $line -notmatch '\d{3}\.\d{3}\s\w+.+') {
            $Private:entry.Subcontrol = $($line.Trim())
            $subcontrolholder = $($line.Trim())
        }
        else {
            $Private:entry.Subcontrol = $subcontrolholder
        }
        if ($line -match '^Q:') {
            if ($line -notmatch '\?$') {
                Write-Host "Warning"
            }
            $Private:entry.Check = $($line.Trim())
        }
        if ($Private:entry.Check){
            $matchObject +=  $Private:entry
        }
    }


    #$matchObject | Export-Csv -Path "$($output)\HIPAA_Controls.csv" -NoTypeInformation
    return $matchObject
}