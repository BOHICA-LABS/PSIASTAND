function Get-Compliance {
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
        [string]$ckl = $(Throw "No CKL Path Provided"),
        [string]$output = $(Throw "No Output folder provided"),
        [String]$name = $(Throw "No Name provided"),
        [switch]$recursive
    )

    BEGIN {
        #weighted Values
        $highweight = 0.6
        $medweight = 0.35
        $lowweight = 0.05

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
    }
    PROCESS {
        Try {
            $compiledCKLObj = @()
            foreach ($file in $cfiles) { # Process CKL Files
                $xml = Import-XML -fileobj $file
                $cklfile = Import-CKL -doc $xml
                $compiledCKLObj += $cklfile
            } # End For loop
        }
        Catch{
            Throw "$($file.name) CKL failed to process"
        }
        $stiglist = $($compiledCKLObj | Select STIGRef -Unique | ForEach-Object{$($_.STIGRef).trim()})
        $complianceReport = @()
        foreach ($stig in $stiglist) {
            $current = $($compiledCKLObj | Where-Object {$_.STIGRef -eq $stig})
            $Private:entry = ($Private:entry = " " | select-object STIG, Systems, System_Count, High_Count_Finding, MED_Count_Finding, LOW_Count_Finding, High_Total, MED_Total, LOW_Total, Total_Checks, Compliance_Percentage, Compliant)
            $Private:entry.STIG = $stig
            $Private:entry.Systems = $((($current | Select AssetName -Unique).AssetName) -Join "`n`r")
            $Private:entry.System_Count = $(($current | Select AssetName -Unique).count)
            $Private:entry.High_Count_Finding = $(($current | Where-Object {$_.Severity -eq "High" -and $_.Status -eq "Open" }).count)
            $Private:entry.MED_Count_Finding = $(($current | Where-Object {$_.Severity -eq "Medium" -and $_.Status -eq "Open" }).count)
            $Private:entry.LOW_Count_Finding = $(($current | Where-Object {$_.Severity -eq "Low" -and $_.Status -eq "Open" }).count)
            $Private:entry.High_Total = $(($current | Where-Object {$_.Severity -eq "High"}).count)
            $Private:entry.MED_Total = $(($current | Where-Object {$_.Severity -eq "Medium"}).count)
            $Private:entry.LOW_Total = $(($current | Where-Object {$_.Severity -eq "Low"}).count)
            $Private:entry.Total_Checks = $(($current).count)
            $totalLostPoints = ($Private:entry.High_Count_Finding * $highweight) + ($Private:entry.MED_Count_Finding * $medweight) + ($Private:entry.LOW_Count_Finding * $lowweight)
            $totalPoints = ($Private:entry.High_Total * $highweight) + ($Private:entry.Medium_Total * $medweight) + ($Private:entry.LOW_Total * $lowweight)
            $Private:entry.Compliance_Percentage = ($totalPoints - $totalLostPoints) / $totalPoints
            if ($Private:entry.Compliance_Percentage -lt .75 -or $Private:entry.High_Count_Finding -gt 0) {
                $Private:entry.Compliant = "FALSE"
            }
            else {
                $Private:entry.Compliant = "TRUE"
            }
            $complianceReport += $Private:entry
        }

    }
    END {
        Export-XLSX -Path "$($output)\$($name)_STIG_Compliance_Report.xlsx" -InputObject $complianceReport
    }
}
#$($ness.NessusClientData_v2.Policy.Preferences.ServerPreferences.preference | Where-Object {$_.Name -eq "Plugin_Set"}).value
