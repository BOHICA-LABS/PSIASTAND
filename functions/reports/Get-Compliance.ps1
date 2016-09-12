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
1.0.0.1 (09.09.2016)
    -Modified to work with CKLv2
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
        $StigViewerVersion = $compiledCKLObj | Select StigViewer_Version -Unique
        switch($StigViewerVersion.StigViewer_Version) {

            1{
                $stiglist = $($compiledCKLObj | Select STIG_Title -Unique | ForEach-Object{$($_.STIG_Title).trim()})
                $complianceReport = @()
                foreach ($stig in $stiglist) {
                    $current = $($compiledCKLObj | Where-Object {$_.STIG_Title -eq $stig})
                    $Private:entry = ($Private:entry = " " | select-object STIG, Systems, System_Count, High_Count_Finding, MED_Count_Finding, LOW_Count_Finding, High_Total, MED_Total, LOW_Total, Total_Checks, Total_Points, Lost_Points, Compliance_Percentage, Compliant)
                    $Private:entry.STIG = $stig
                    $Private:entry.Systems = $((($current | Select AssetName -Unique).AssetName) -Join "`n`r")
                    $Private:entry.System_Count = $((($current | Select AssetName -Unique).AssetName).count)
                    $Private:entry.High_Count_Finding = $((($current | Where-Object {$_.Severity -eq "High" -and $_.Status -eq "Open" }).Status).count)
                    $Private:entry.MED_Count_Finding = $((($current | Where-Object {$_.Severity -eq "Medium" -and $_.Status -eq "Open" }).Status).count)
                    $Private:entry.LOW_Count_Finding = $((($current | Where-Object {$_.Severity -eq "Low" -and $_.Status -eq "Open" }).Status).count)
                    $Private:entry.High_Total = $((($current | Where-Object {$_.Severity -eq "High"}).Severity).count)
                    $Private:entry.MED_Total = $((($current | Where-Object {$_.Severity -eq "Medium"}).Severity).count)
                    $Private:entry.LOW_Total = $((($current | Where-Object {$_.Severity -eq "Low"}).Severity).count)
                    $Private:entry.Total_Checks = $(($current).count)
                    $Private:entry.Total_Points = ($Private:entry.High_Total * $highweight) + ($Private:entry.MED_Total * $medweight) + ($Private:entry.LOW_Total * $lowweight)
                    $Private:entry.Lost_Points = ($Private:entry.High_Count_Finding * $highweight) + ($Private:entry.MED_Count_Finding * $medweight) + ($Private:entry.LOW_Count_Finding * $lowweight)
                    $Private:entry.Compliance_Percentage = $((($Private:entry.Total_Points) - ($Private:entry.Lost_Points)) / ($Private:entry.Total_Points))
                    if ($Private:entry.Compliance_Percentage -lt .75 -or $Private:entry.High_Count_Finding -gt 0) {
                        $Private:entry.Compliant = "FALSE"
                    }
                    else {
                        $Private:entry.Compliant = "TRUE"
                    }
                    $complianceReport += $Private:entry
                }

            }

            2{
                $stiglist = $($compiledCKLObj | Select stigid -Unique | ForEach-Object{$($_.stigid).trim()})
                $complianceReport = @()
                foreach ($stig in $stiglist) {
                    $current = $($compiledCKLObj | Where-Object {$_.stigid -eq $stig})
                    $Private:entry = ($Private:entry = " " | select-object STIG, Systems, System_Count, High_Count_Finding, MED_Count_Finding, LOW_Count_Finding, High_Total, MED_Total, LOW_Total, Total_Checks, Total_Points, Lost_Points, Compliance_Percentage, Compliant)
                    $Private:entry.STIG = $stig
                    $Private:entry.Systems = $((($current | Select AssetName -Unique).AssetName) -Join "`n`r")
                    $Private:entry.System_Count = $((($current | Select AssetName -Unique).AssetName).count)
                    $Private:entry.High_Count_Finding = $((($current | Where-Object {$_.Severity -eq "High" -and $_.Status -eq "Open" }).Status).count)
                    $Private:entry.MED_Count_Finding = $((($current | Where-Object {$_.Severity -eq "Medium" -and $_.Status -eq "Open" }).Status).count)
                    $Private:entry.LOW_Count_Finding = $((($current | Where-Object {$_.Severity -eq "Low" -and $_.Status -eq "Open" }).Status).count)
                    $Private:entry.High_Total = $((($current | Where-Object {$_.Severity -eq "High"}).Severity).count)
                    $Private:entry.MED_Total = $((($current | Where-Object {$_.Severity -eq "Medium"}).Severity).count)
                    $Private:entry.LOW_Total = $((($current | Where-Object {$_.Severity -eq "Low"}).Severity).count)
                    $Private:entry.Total_Checks = $(($current).count)
                    $Private:entry.Total_Points = ($Private:entry.High_Total * $highweight) + ($Private:entry.MED_Total * $medweight) + ($Private:entry.LOW_Total * $lowweight)
                    $Private:entry.Lost_Points = ($Private:entry.High_Count_Finding * $highweight) + ($Private:entry.MED_Count_Finding * $medweight) + ($Private:entry.LOW_Count_Finding * $lowweight)
                    $Private:entry.Compliance_Percentage = $((($Private:entry.Total_Points) - ($Private:entry.Lost_Points)) / ($Private:entry.Total_Points))
                    if ($Private:entry.Compliance_Percentage -lt .75 -or $Private:entry.High_Count_Finding -gt 0) {
                        $Private:entry.Compliant = "FALSE"
                    }
                    else {
                        $Private:entry.Compliant = "TRUE"
                    }
                    $complianceReport += $Private:entry
                }
            }
            default {
                throw "CKL file version is invalid."
            }
        }
    }
    END {
        $complianceReport | Export-XLSX -Path "$($output)\$($name)_STIG_Compliance_Report.xlsx"
    }
}
#$($ness.NessusClientData_v2.Policy.Preferences.ServerPreferences.preference | Where-Object {$_.Name -eq "Plugin_Set"}).value
#Get-Compliance -ckl .\tests\data\CKL\CKLv2 -output .\ -name test
