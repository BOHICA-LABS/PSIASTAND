function ConvertTo-CKL { # Builds XML Document
<#
.SYNOPSIS
Imports csv or xlsx file and converts it to a CKLv1 file (Requires CKL v1 export)

.PARAMETER Path
Path to look for

.EXAMPLE

.LINK

.VERSION
1.0.0 (02.09.2016)
    -Intial Release

1.0.1 (08.24.2016)
    -Added support for ckl v2

#>
    Param(
        [Object]$Obj,
        [Parameter(Madatory=$true)]
        [int]$version,
        [string]$hostn = "HOST",
        [string]$ip = "IP",
        [string]$mac = "MAC",
        [string]$type = "Computing",
        [Object]$map,
        [Parameter(Madatory=$true)]
        [string]$ofile
    )
    switch ($private:version){
        1 {
            $Private:params = "version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`""
            $Private:w = New-Object system.xml.xmltextwriter($ofile, $null)
            $Private:w.Formatting = [System.xml.formatting]::Indented # sets the fomrating option for the writter
            $Private:w.WriteProcessingInstruction("xml", $Private:params) # Starts XML Document
            # Start or XML Data
            $Private:w.WriteStartElement("CHECKLIST") # Root Element Checklist
            $Private:w.WriteStartElement("SV_VERSION") # Stig Viewer Version Element
            $Private:w.WriteString("DISA STIG Viewer : 1.2.0") # Writes the version string into the SV_Version element
            $Private:w.WriteEndElement() # End SV_Version Element
            $Private:w.WriteStartElement("ASSET") # ASSET Element
            $Private:w.WriteStartElement("ASSET_TYPE") # Asset Type Element
            $Private:w.WriteString($type) # Sets Asset type element data
            $Private:w.WriteEndElement() # End of ASSET_TYPE Element HOST_NAME
            $Private:w.WriteStartElement("HOST_NAME") # HOST_NAME Element
            $Private:w.WriteString($hostn) # Sets host_name elemnt data
            $Private:w.WriteEndElement() # End Host_Name Element HOST_IP
            $Private:w.WriteStartElement("HOST_IP") # Host_IP Element
            $Private:w.WriteString($ip) # Sets HOST_IP Data
            $Private:w.WriteEndElement() # End HOST_IP Element HOST_MAC
            $Private:w.WriteStartElement("HOST_MAC") # HOST_MAC Element
            $Private:w.WriteString($mac) # HOST_MAC Data
            $Private:w.WriteEndElement() # End HOST_MAC Element HOST_GUID
            $Private:w.WriteStartElement("HOST_GUID") # HOST_GUID Element
            $Private:w.WriteEndElement() # End HOST_GUID Element TARGET_KEY
            $Private:w.WriteStartElement("TARGET_KEY") # TARGET_KEY Element
            $Private:w.WriteEndElement() # end TARGET_KEY Element ASSET_VAL
            $Private:w.WriteStartElement("ASSET_VAL") # ASSET_VAL Element
            $Private:w.WriteStartElement("AV_NAME") # AV_NAME Element
            $Private:w.WriteAttributeString("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance") # Write AV_NAME Element Atribute
            $Private:w.WriteAttributeString("xmlns:xs","http://www.w3.org/2001/XMLSchema") # Write AV_NAME Element Atribute
            $Private:w.WriteAttributeString("xsi:type","xs:string") # Write AV_NAME Element Atribute
            $Private:w.WriteString("Role") # AV_NAME DATA
            $Private:w.WriteEndElement() # End AV_NAME Element
            $Private:w.WriteStartElement("AV_DATA") # AV_DATA Element
            $Private:w.WriteAttributeString("xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance") # Write AV_DATA Element Atribute
            $Private:w.WriteAttributeString("xmlns:xs","http://www.w3.org/2001/XMLSchema") # Write AV_DATA Element Atribute
            $Private:w.WriteAttributeString("xsi:type","xs:string")# Write AV_DATA Element Atribute
            $Private:w.WriteString("Role") # AV_DATA DATA
            $Private:w.WriteEndElement() # End AV_DATA Element
            $Private:w.WriteEndElement() # End ASSET_VAL Element
            $Private:w.WriteEndElement() # End ASSET Element STIG_INFO
            $Private:w.WriteStartElement("STIG_INFO") # STIG_INFO Element STIG_TITLE
            $Private:w.WriteStartElement("STIG_TITLE") # STIG_TITLE Element
            $Private:w.WriteString($($Obj[0].("STIG"))) # STIG_TITLE Data
            $Private:w.WriteEndElement() # End STIG_TITLE Element
            $Private:w.WriteEndElement() # End STIG_INFO Element
            foreach($Private:row in $Obj){
                $Private:w.WriteStartElement("VULN") # Start of VULN Element

                # STIG DATA  Not_Applicable
                foreach($Private:key in $map.Keys){ # Loop through the Mapping hashtable
                    if($Private:key -eq "Status" -or $Private:key -eq "FINDING_DETAILS" -or $Private:key -eq "COMMENTS" -or $Private:key -eq "SEVERITY_OVERRIDE" -or $Private:key -eq "SEVERITY_JUSTIFICATION"){
                        $Private:w.WriteStartElement($Private:key) # Write Element
                        if($Private:key -eq "Status"){
                            if($Private:row.($($map.$Private:key)).tolower() -like "NotAFinding"){
                                $Private:row.($($map.$Private:key)) = "NotAFinding"
                            }
                            elseif($Private:row.($($map.$Private:key)).tolower() -like "Not_Reviewed"){
                                $Private:row.($($map.$Private:key)) = "Not_Reviewed"
                            }
                            elseif($Private:row.($($map.$Private:key)).tolower() -like "Open"){
                                $Private:row.($($map.$Private:key)) = "Open"
                            }
                            elseif($Private:row.($($map.$Private:key)).tolower() -like "pass" -or $Private:row.($($map.$Private:key)).tolower() -like "passed"){ #if Status eq pass or passed
                                $Private:row.($($map.$Private:key)) = "NotAFinding"
                            }
                            elseif($Private:row.($($map.$Private:key)).tolower() -like "fail" -or $Private:row.($($map.$Private:key)).tolower() -like "failed"){ # if Status eq fail or failed
                                $Private:row.($($map.$Private:key)) = "Open"
                            }
                            elseif($Private:row.($($map.$Private:key)).tolower() -like "na" -or $Private:row.($($map.$Private:key)).tolower() -like "n/a" -or $Private:row.($($map.$Private:key)).tolower() -like "n\a" -or $Private:row.($($map.$Private:key)).tolower() -like "not applicable"){ # if status eq not applicable
                                $Private:row.($($map.$Private:key)) = "Not_Applicable"
                            }
                        }
                        if($Private:row.($($map.$Private:key))){ # if Has Data
                            $Private:w.WriteString($($Private:row.($($map.$Private:key)))) # Write Data
                            $Private:w.WriteEndElement() # Write End Element
                        }
                        else{ # if no datae
                            $Private:w.WriteEndElement() # Write End Element
                        } # End Data Check
                        continue
                    } # End if checking for keys that dont belong under STIG_DATA Elements

                    $Private:w.WriteStartElement("STIG_DATA") # Start of STIG Data Element

                    $Private:w.WriteStartElement("VULN_ATTRIBUTE") # Start of VULN_ATTRIBUTE Element
                    $Private:w.WriteString($Private:key) # Write VULN_ATTRIBUTE Data
                    $Private:w.WriteEndElement() # End VULN_ATTRIBUTE Element

                    $Private:w.WriteStartElement("ATTRIBUTE_DATA") # Start of ATTRIBUTE_DATA Element
                    if($Private:key -eq "Documentable"){
                        $Private:w.WriteString($($Private:row.($($map.$Private:key)))) # write ATTRIBUTE_DATA Data
                        $Private:w.WriteEndElement() # End ATTRIBUTE_DATA Element
                        $Private:w.WriteEndElement() # End of STIG DATA Element
                        continue
                    }
                    if($Private:row.($($map.$Private:key))){ # if ATTRIBUTE_DATA Has Data
                        $Private:w.WriteString($($Private:row.($($map.$Private:key)))) # write ATTRIBUTE_DATA Data
                        $Private:w.WriteEndElement() # End ATTRIBUTE_DATA Element
                    }
                    else{ # if ATTRIBUTE_DATA does not have Data
                        $Private:w.WriteEndElement() # End ATTRIBUTE_DATA Element
                    }
                    $Private:w.WriteEndElement() # End of STIG DATA Element

                } # End for Each key in mapping

                $Private:w.WriteEndElement() # End of VULN Element
            } # End of Foreach row in obj
            # Finish Document
            $Private:w.Flush()
            $Private:w.Close()
            #return $Private:sw # Return XML string
        }
        2 {
            $Private:params = "version=`"1.0`" encoding=`"UTF-8`" standalone=`"yes`""
            $Private:w = New-Object system.xml.xmltextwriter($ofile, $null)
            $Private:w.Formatting = [System.xml.formatting]::Indented # sets the fomrating option for the writter
            $Private:w.WriteProcessingInstruction("xml", $Private:params) # Starts XML Document
            # Start or XML Data
            $Private:w.WriteStartElement("CHECKLIST") # Root Element Checklist
                $Private:w.WriteStartElement("ASSET") # ASSET Element
                    $Private:w.WriteStartElement("ASSET_TYPE") # Asset Type Element
                        $Private:w.WriteString($type) # Sets Asset type element data
                    $Private:w.WriteEndElement() # End of ASSET_TYPE Element HOST_NAME
                    $Private:w.WriteStartElement("HOST_NAME") # HOST_NAME Element
                        $Private:w.WriteString($hostn) # Sets host_name elemnt data
                    $Private:w.WriteEndElement() # End Host_Name Element HOST_IP
                    $Private:w.WriteStartElement("HOST_IP") # Host_IP Element
                        $Private:w.WriteString($ip) # Sets HOST_IP Data
                    $Private:w.WriteEndElement() # End HOST_IP Element
                    $Private:w.WriteStartElement("HOST_MAC") # HOST_MAC Element
                        $Private:w.WriteString($mac) # HOST_MAC Data
                    $Private:w.WriteEndElement() # End HOST_MAC Element
                    $Private:w.WriteStartElement("HOST_GUID") # HOST_GUID Element
                    $Private:w.WriteEndElement() # End HOST_GUID Elemen
                    $Private:w.WriteStartElement("HOST_FQDN") # HOST_FQDN Element
                    $Private:w.WriteEndElement() # End HOST_FQDN Element
                    $Private:w.WriteStartElement("TECH_AREA") # TECH_AREA Element
                    $Private:w.WriteEndElement() # End TECH_AREA Element
                    $Private:w.WriteStartElement("TARGET_KEY") # TARGET_KEY Element
                    $Private:w.WriteEndElement() # end TARGET_KEY Element
                $Private:w.WriteEndElement() # end ASSET Element
                $Private:w.WriteStartElement("STIGS") # STIGS Element
                foreach($stig in ($obj.stigid | Select-Object -Unique -Property version,classification,stigid,description,filename,releaseinfo,title,uuid,notice,source)){
                    $Private:w.WriteStartElement("iSTIG") # iSTIG Element
                        $Private:w.WriteStartElement("STIG_INFO") # STIG_INFO Element

                            #version
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("version") # Sets version elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString("$obj.version") # Sets version elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                            #classification
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("classification") # Sets classification elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString($($stig.classification)) # Sets classification elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Elemen
                            $Private:w.WriteEndElement() # end SI_DATA Elemen

                            #customname
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("customname") # Sets customname elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                            #stigid
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("stigid") # Sets stigid elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString($($stig.stigid)) # Sets stigid elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                            #description
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("description") # Sets description elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString($($stig.description)) # Sets description elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                            #filename
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("filename") # Sets filename elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString($($stig.filename)) # Sets filename elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                            #releaseinfo
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("releaseinfo") # Sets releaseinfo elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString($($stig.releaseinfo)) # Sets releaseinfo elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                            #title
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("title") # Sets title elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString($($stig.title)) # Sets title elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                            #uuid
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("uuid") # Sets uuid elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString($($stig.uuid)) # Sets uuid elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                            #notice
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("notice") # Sets notice elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString($($stig.notice)) # Sets notice elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                            #source
                            $Private:w.WriteStartElement("SI_DATA") # SI_DATA Element
                                $Private:w.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $Private:w.WriteString("source") # Sets source elemnt data
                                $Private:w.WriteEndElement() # end SID_NAME Element
                                $Private:w.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $Private:w.WriteString($($stig.source)) # Sets source elemnt data
                                $Private:w.WriteEndElement() # end SID_DATA Element
                            $Private:w.WriteEndElement() # end SI_DATA Element

                        $Private:w.WriteEndElement() # end STIG_INFO Element
                        $Private:w.WriteStartElement("VULN") # VULN Element
                        foreach($Private:row in $Obj | Where-Object { $stig.stigid -eq $_.stigid }){

                            #Vuln_Num
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Vuln_Num") # Sets Vuln_Num elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Vuln_Num)) # Sets Vuln_Num elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Severity
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Severity") # Sets Severity elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Severity)) # Sets Severity elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Group_Title
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Group_Title") # Sets Group_Title elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Group_Title)) # Sets Group_Title elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Rule_ID
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Rule_ID") # Sets Rule_ID elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Rule_ID)) # Sets Rule_ID elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Rule_Ver
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Rule_Ver") # Sets Rule_Ver elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Rule_Ver)) # Sets Rule_Ver elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Rule_Title
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Rule_Title") # Sets Rule_Title elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Rule_Title)) # Sets Rule_Title elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Vuln_Discuss
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Vuln_Discuss") # Sets Vuln_Discuss elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Vuln_Discuss)) # Sets Vuln_Discuss elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #IA_Controls
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("IA_Controls") # Sets IA_Controls elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.IA_Controls)) # Sets IA_Controls elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Check_Content
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Check_Content") # Sets Check_Content elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Check_Content)) # Sets Check_Content elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Fix_Text
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Fix_Text") # Sets Fix_Text elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Fix_Text)) # Sets Fix_Text elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #False_Positives
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("False_Positives") # Sets False_Positives elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.False_Positives)) # Sets False_Positives elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #False_Negatives
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("False_Negatives") # Sets False_Negatives elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.False_Negatives)) # Sets False_Negatives elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Documentable
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Documentable") # Sets Documentable elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Documentable)) # Sets Documentable elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Mitigations
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Mitigations") # Sets Mitigations elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Mitigations)) # Sets Mitigations elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Potential_Impact
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Potential_Impact") # Sets Potential_Impact elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Potential_Impact)) # Sets Potential_Impact elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Third_Party_Tools
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Third_Party_Tools") # Sets Third_Party_Tools elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Third_Party_Tools)) # Sets Third_Party_Tools elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Mitigation_Control
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Third_Party_Tools") # Sets Mitigation_Control elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Third_Party_Tools)) # Sets Third_Party_Tools elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Responsibility
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Responsibility") # Sets Responsibility elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Responsibility)) # Sets Responsibility elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Security_Override_Guidance
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Security_Override_Guidance") # Sets Security_Override_Guidance elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Security_Override_Guidance)) # Sets Security_Override_Guidance elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Check_Content_Ref
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Check_Content_Ref") # Sets Check_Content_Ref elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Check_Content_Ref)) # Sets Check_Content_Ref elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #Class
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("Class") # Sets Class elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.Class)) # Sets Class elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #STIGRef
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("STIGRef") # Sets STIGRef elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.STIGRef)) # Sets STIGRef elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #TargetKey
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("TargetKey") # Sets TargetKey elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.TargetKey)) # Sets TargetKey elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #CCI_REF
                            $Private:w.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                $Private:w.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                    $Private:w.WriteString("CCI_REF") # Sets CCI_REF elemnt data
                                $Private:w.WriteEndElement() # end VULN_ATTRIBUTE Element
                                $Private:w.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                    $Private:w.WriteString($($row.CCI_REF)) # Sets CCI_REF elemnt data
                                $Private:w.WriteEndElement() # end ATTRIBUTE_DATA Element
                            $Private:w.WriteEndElement() # end STIG_DATA Element

                            #STATUS
                            $Private:w.WriteStartElement("STATUS") # STATUS Element
                                #$Private:w.WriteString("CCI_REF") # Sets STATUS elemnt data
                            $Private:w.WriteEndElement() # end STATUS Element


                        }
                        $Private:w.WriteEndElement() # end VULN Element
                    $Private:w.WriteEndElement() # end iSTIG Element
                }
                $Private:w.WriteEndElement() # end STIGS Element
            $Private:w.WriteEndElement() # end CHECKLIST Element
        }
    }
}

$testckl | Select-Object -Unique -Property version,classification,stigid,description,filename,releaseinfo,title,uuid,notice,source