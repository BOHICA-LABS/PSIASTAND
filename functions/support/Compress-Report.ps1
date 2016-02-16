function Compress-Report {
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
    PROCESS{
        if(!$ckl -and !$nessus -and !$diacap -and !$rmf){Throw "Report Type not selected"}
        if ($ckl) {
            Try{
                $Private:results = @()
                foreach($Private:reportObj in $report){
                    $Private:reportObjHolding = $Private:results | Where-Object{$_.STIG_Title -eq $Private:reportObj.STIG_Title -and $_.Group_Title -eq $Private:reportObj.Group_Title -and $_.Vuln_Num -eq $Private:reportObj.Vuln_Num}
                    # Check if the object has already been created
                    if($Private:reportObjHolding){
                        if(!($Private:reportObjHolding.AssetName.split(",") -contains $Private:reportObj.AssetName)){
                            $Private:reportObjHolding.AssetName += ","+$Private:reportObj.AssetName
                            $Private:reportObjHolding.vuln_count ++
                            #$Private:reportObjHolding.AssetName = $($Private:reportObjHolding.AssetName -join ",")
                            if(!($Private:reportObjHolding.Finding_Details)){
                                $Private:reportObjHolding.Finding_Details = $Private:reportObj.Finding_Details
                            }
                        }
                    } # IF Obj
                    else{
                        $Private:entry = ($Private:entry = " " | select-object STIG_Title, AssetName, Vuln_Num, Severity, Group_Title, Rule_ID, Rule_Ver, Rule_Title, Vuln_Discuss, IA_Controls, Check_Content, Fix_Text, False_Positives, False_Negatives, Documentable, Mitigations, Potential_Impact, Third_Party_Tools, Mitigation_Control, Responsibility, Security_Override_Guidance, Check_Content_Ref, Class, STIGRef, TargetKey, Status, Finding_Details, Comments, Severity_Override, Severity_Justification, vuln_count)
                        $Private:entry.STIG_Title = $($Private:reportObj.STIG_Title).trim()
                        $Private:entry.AssetName = $($Private:reportObj.AssetName).trim()
                        $Private:entry.Vuln_Num = $($Private:reportObj.Vuln_Num).trim()
                        $Private:entry.Severity = $($Private:reportObj.Severity).trim()
                        $Private:entry.Group_Title = $($Private:reportObj.Group_Title).trim()
                        $Private:entry.Rule_ID = $($Private:reportObj.Rule_ID).trim()
                        $Private:entry.Rule_Ver = $($Private:reportObj.Rule_Ver).trim()
                        $Private:entry.Rule_Title = $($Private:reportObj.Rule_Title).trim()
                        $Private:entry.Vuln_Discuss = $($Private:reportObj.Vuln_Discuss).trim()
                        $Private:entry.IA_Controls = $($Private:reportObj.IA_Controls).trim()
                        $Private:entry.Check_Content = $($Private:reportObj.Check_Content).trim()
                        $Private:entry.Fix_Text = $($Private:reportObj.Fix_Text).trim()
                        $Private:entry.False_Positives = $($Private:reportObj.False_Positives).trim()
                        $Private:entry.False_Negatives = $($Private:reportObj.False_Negatives).trim()
                        $Private:entry.Documentable = $($Private:reportObj.Documentable).trim()
                        $Private:entry.Mitigations = $($Private:reportObj.Mitigations).trim()
                        $Private:entry.Potential_Impact = $($Private:reportObj.Potential_Impact).trim()
                        $Private:entry.Third_Party_Tools = $($Private:reportObj.Third_Party_Tools).trim()
                        $Private:entry.Mitigation_Control = $($Private:reportObj.Mitigation_Control).trim()
                        $Private:entry.Responsibility = $($Private:reportObj.Responsibility).trim()
                        $Private:entry.Security_Override_Guidance = $($Private:reportObj.Security_Override_Guidance).trim()
                        $Private:entry.Check_Content_Ref = $($Private:reportObj.Check_Content_Ref).trim()
                        $Private:entry.Class = $($Private:reportObj.Class).trim()
                        $Private:entry.STIGRef = $($Private:reportObj.STIGRef).trim()
                        $Private:entry.TargetKey = $($Private:reportObj.TargetKey).trim()
                        $Private:entry.Status = $($Private:reportObj.Status).trim()
                        $Private:entry.Finding_Details = $($Private:reportObj.Finding_Details).trim()
                        $Private:entry.Comments = $($Private:reportObj.Comments).trim()
                        $Private:entry.Severity_Override = $($Private:reportObj.Severity_Override).trim()
                        $Private:entry.Severity_Justification = $($Private:reportObj.Severity_Justification).trim()
                        $Private:entry.vuln_count = 1
                        $Private:results += $Private:entry
                    }
                }  # For Loop
                return $Private:results
            }
            CATCH{
                Throw "Error processing CKL"
            }
        } # CKL Report

        if ($nessus) { # START NESSUS
            TRY { # TRY
                $Private:results = @()
                foreach($Private:reportObj in $report){
                    $Private:reportObjHolding = $Private:results | Where-Object{$_.pluginID -eq $Private:reportObj.pluginID -and $_.pluginName -eq $Private:reportObj.pluginName}
                    if($Private:reportObj.'netbios-name'){
                        $Private:AssignedHostname = $Private:reportObj.'netbios-name'
                    } # if
                    elseif($Private:reportObj.'host-fqdn'){
                        $Private:AssignedHostname = $($Private:reportObj.'host-fqdn'.split(".")[0])
                    } # Elseif
                    else{
                        $Private:AssignedHostname = $Private:reportObj.'host-ip'
                    } # Else
                    if($Private:reportObjHolding){
                        if(!($Private:reportObjHolding.AssetName.split(",") -contains $Private:AssignedHostname)){
                            $Private:reportObjHolding.AssetName += ","+$Private:AssignedHostname
                            $Private:reportObjHolding.vuln_count ++
                        }
                    } # IF
                    else{
                        $Private:entry = ($Private:entry = " " | select-object AssetName, port, svc_name, protocol, severity, pluginID, pluginName, pluginFamily, description, fname, plugin_modification_date, plugin_name, plugin_publication_date, plugin_type, risk_factor, script_version, solution, synopsis, plugin_output, vuln_count)
                        $Private:entry.AssetName = $($Private:AssignedHostname).trim()
                        $Private:entry.Port = $($Private:reportObj.Port).trim()
                        $Private:entry.svc_name = $($Private:reportObj.svc_name).trim()
                        $Private:entry.protocol = $($Private:reportObj.protocol).trim()
                        $Private:entry.severity = $($Private:reportObj.severity).trim()
                        $Private:entry.pluginID = $($Private:reportObj.pluginID).trim()
                        $Private:entry.pluginName = $($Private:reportObj.pluginName).trim()
                        $Private:entry.pluginFamily = $($Private:reportObj.pluginFamily).trim()
                        $Private:entry.description = $($Private:reportObj.description).trim()
                        $Private:entry.fname = $($Private:reportObj.fname).trim()
                        $Private:entry.plugin_modification_date = $($Private:reportObj.plugin_modification_date).trim()
                        $Private:entry.plugin_name = $($Private:reportObj.plugin_name).trim()
                        $Private:entry.plugin_publication_date = $($Private:reportObj.plugin_publication_date).trim()
                        $Private:entry.plugin_type = $($Private:reportObj.plugin_type).trim()
                        $Private:entry.risk_factor = $($Private:reportObj.risk_factor).trim()
                        $Private:entry.script_version = $($Private:reportObj.script_version).trim()
                        $Private:entry.solution = $($Private:reportObj.solution).trim()
                        $Private:entry.synopsis = $(if($Private:reportObj.synopsis){$($Private:reportObj.synopsis).trim()})
                        $Private:entry.plugin_output = $(if($Private:reportObj.plugin_output){$($Private:reportObj.plugin_output).trim()})
                        $private:entry.vuln_count = 1
                        $Private:results += $Private:entry
                    } # else
                } # foreach
                return $Private:results
            } # END TRY
            CATCH { # CATCH
                Throw "Error processing Nessus"
            } # END CATCH
        } # END IF NESSUS

        if ($diacap) { # START DIACAP
            TRY{ # TRY
            } # END TRY
            CATCH{ # CATCH
            } # END CATCH
        } # END IF DIACAP

        if ($rmf) { # Start RMF
            TRY { # TRY
            } # END TRY
            CATCH { # CATCH
            } # END CATCH
        } # END IF RMF

    } # End Process block
} # end function
