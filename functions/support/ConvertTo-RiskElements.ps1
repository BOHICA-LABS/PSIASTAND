function ConvertTo-RiskElements {
<#
.SYNOPSIS

.PARAMETER report

.PARAMETER Identifer

.PARAMETER ckl

.PARAMETER nessus

.PARAMETER diacap

.PARAMETER rmf

.EXAMPLE

.LINK

.VERSION
1.0.0 (02.15.2016)
    -Intial Release
#>

    [CmdletBinding()]
    Param(
        [Object]$report = $(Throw "No report Provided"),
        [switch]$ckl,
        [switch]$nessus,
        [switch]$diacap,
        [switch]$rmf
    )

    PROCESS {
        if(!$ckl -and !$nessus -and !$diacap -and !$rmf){Throw "Report Type not selected"}
        if ($ckl) {
                $Private:results = @()
                $cklversion = $($($report.StigViewer_Version) | Select-Object -Unique)
                foreach($Private:reportObj in $report){
                #$Private:entry = ($Private:entry = " " | select-object Name, Weaknesses, Cat, "IA Control", Count, "Assessed Risk Level", "Quantitative Values") Previous to CVSS implementation
                $Private:entry = ($Private:entry = " " | select-object Source, Name, ID, Weaknesses, Cat, "IA Control", Count, CVSS, "Assessed Risk Level")
                $Private:entry.Source = "STIG"
                switch($cklversion){
                    1{
                        if($Private:reportObj.Vuln_Num){
                            $Private:entry.name = "$($Private:reportObj.STIG_Title) - ID: $($Private:reportObj.Vuln_Num) - $($Private:reportObj.Rule_Title)"
                            $Private:entry.ID = "$($Private:reportObj.Rule_ID) :: $($Private:reportObj.Vuln_Num)"
                        }
                        else{
                            $Private:entry.name = "$($Private:reportObj.STIG_Title) - $($Private:reportObj.Rule_Title)"
                            $Private:entry.ID = "$($Private:reportObj.Rule_ID)"
                        }
                    }
                    2{
                        if($Private:reportObj.Vuln_Num){
                            $Private:entry.name = "$($Private:reportObj.STIGRef) - ID: $($Private:reportObj.Vuln_Num) - $($Private:reportObj.Rule_Title)"
                            $Private:entry.ID = "$($Private:reportObj.Rule_ID) ID:: $($Private:reportObj.Vuln_Num)"
                        }
                        else{
                            $Private:entry.name = "$($Private:reportObj.STIGRef) - $($Private:reportObj.Rule_Title)"
                            $Private:entry.ID = "$($Private:reportObj.Rule_ID)"
                        }
                    }
                }
                if($Private:reportObj.Vuln_Discuss){
                    $Private:entry.Weaknesses = "Description:" + "`r`n" + $($Private:reportObj.Vuln_Discuss) + "`r`n" + "Affected System:" + "`r`n" + $($Private:reportObj.AssetName -split "," -join "`r`n")
                }
                else{
                    Throw $ERRORCREATEPOAM = "No Vuln Description for $($Private:reportObj.Vuln_Num) STIG $($Private:reportObj.STIG_Title)"
                }
                if($Private:reportObj.Severity){
                    if($Private:reportObj.Severity -eq 'low'){
                        $Private:entry.Cat = "III"
                    }
                    elseif($Private:reportObj.Severity -eq 'medium'){
                        $Private:entry.Cat = "II"
                    }
                    elseif($Private:reportObj.Severity -eq 'high'){
                        $Private:entry.Cat = "I"
                    }
                    else{
                        Throw $ERRORCREATEPOAM = "No Severity Assigned to $($Private:reportObj.Vuln_Num) STIG $($Private:reportObj.STIG_Title)"
                    }
                }
                else{
                    Throw $ERRORCREATEPOAM = "No Severity Assigned to $($Private:reportObj.Vuln_Num) STIG $($Private:reportObj.STIG_Title)"
                }
                $Private:entry.'IA Control' = $Private:reportObj.IA_Controls
                $Private:entry.Count = $Private:reportObj.vuln_count
                $Private:entry.'Assessed Risk Level' = $null
                $Private:results += $Private:entry
            }
            return $Private:results
        }
        if ($nessus) {
            $Private:results = @()
            foreach($Private:reportObj in $report){
                #$Private:entry = ($Private:entry = " " | select-object Name, Weaknesses, Cat, "IA Control", Count, "Assessed Risk Level", "Quantitative Values") Previous to CVSS implementation
                $Private:entry = ($Private:entry = " " | select-object Source, Name, ID, Weaknesses, Cat, "IA Control", Count, CVSS, "Assessed Risk Level")
                $Private:entry.Name = "ACAS - Plugin ID: $($Private:reportObj.pluginID) - $($Private:reportObj.pluginName)"
                $Private:entry.ID = "$($Private:reportObj.pluginID)"
                $Private:entry.Weaknesses = "Description:" + "`r`n" + $($Private:reportObj.description) + "`r`n" + "Affected System:" + "`r`n" + $($Private:reportObj.AssetName -split "," -join "`r`n")
                $Private:entry.Source = "NESSUS"
                if($Private:reportObj.Severity){
                    if($Private:reportObj.risk_factor -eq 'low'){
                        $Private:entry.Cat = "III"
                    } # if
                    elseif($Private:reportObj.risk_factor -eq 'medium'){
                        $Private:entry.Cat = "II"
                    } # elseif
                    elseif($Private:reportObj.risk_factor -eq 'high'){
                        $Private:entry.Cat = "I"
                    } # elseif
                    elseif($Private:reportObj.risk_factor -eq 'Critical'){
                        $Private:entry.Cat = "I"
                    } # Elseif
                    else{
                        Throw $ERRORCREATEPOAM = "No Severity Assigned to $($Private:reportObj.pluginID) Name $($Private:reportObj.pluginName)"
                    } # Else
                } # if
                else{
                    Throw $ERRORCREATEPOAM = "No Severity Assigned to $($Private:reportObj.pluginID) Name $($Private:reportObj.pluginName)"
                } # else
                $Private:entry.'IA Control' = $null
                $Private:entry.Count = $Private:reportObj.vuln_count
                $Private:entry.'Assessed Risk Level' = $null
                $Private:results += $Private:entry
            }
        }
        if ($diacap) {
            $Private:results = @()
            foreach($Private:reportObj in $report){
                #$Private:entry = ($Private:entry = " " | select-object Name, Weaknesses, Cat, "IA Control", Count, "Assessed Risk Level", "Quantitative Values") Previous to CVSS implementation
                $Private:entry = ($Private:entry = " " | select-object Source, Name, ID, Weaknesses, Cat, "IA Control", Count, CVSS, "Assessed Risk Level")
                $Private:entry.Name = "8500.2 - ID: $($Private:reportObj.AssessmentObjectiveID) - $($Private:reportObj.'Control Name')"
                $Private:entry.ID = "$($Private:reportObj.AssessmentObjectiveID)"
                $Private:entry.Source = "DIACAP"
                $Private:entry.Weaknesses = "Description:" + "`r`n" + $($Private:reportObj.'Assessment Objectives') + "`r`n" + "Affected System:" + "`r`n" + "Site"
                if($Private:reportObj.'Impact Code' -eq 'low'){
                    $Private:entry.Cat = "III"
                } # if
                elseif($Private:reportObj.'Impact Code' -eq 'medium'){
                    $Private:entry.Cat = "II"
                } # elseif
                elseif($Private:reportObj.'Impact Code' -eq 'high'){
                    $Private:entry.Cat = "I"
                } # elseif
                else{
                    Throw $ERRORCREATEPOAM = "No Severity Assigned to $($Private:reportObj.pluginID) Name $($Private:reportObj.pluginName)"
                } # Else
                $Private:entry.'IA Control' = $Private:reportObj.'Control Number'
                $Private:entry.Count = 1
                $Private:entry.'Assessed Risk Level' = $null
                $Private:results += $Private:entry
            }
        }
        if ($rmf) { # Place Holder
        }
        return $Private:results
    }
}
