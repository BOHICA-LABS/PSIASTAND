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
        [int]$version,
        [string]$hostn = "HOST",
        [string]$ip = "IP",
        [string]$mac = "MAC",
        [string]$type = "Computing",
        [Object]$map,
        [Parameter(Mandatory=$true)]
        [string]$ofile
    )
    switch ($version){
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
            $params = "version=""1.0"" encoding=""UTF-8"" standalone=""yes"""
            $XmlWriter = New-Object system.xml.xmltextwriter($ofile, $null)
            $XmlWriter.Formatting = "Indented"
            $XmlWriter.Indentation = 1
            $XmlWriter.IndentChar = "`t"
            $XmlWriter.WriteProcessingInstruction("xml", $params) # Starts XML Document
            # Start or XML Data
            $XmlWriter.WriteStartElement("CHECKLIST") # Root Element Checklist
                $XmlWriter.WriteStartElement("ASSET") # ASSET Element
                    $XmlWriter.WriteStartElement("ASSET_TYPE") # Asset Type Element
                        $XmlWriter.WriteString($type) # Sets Asset type element data
                    $XmlWriter.WriteEndElement() # End of ASSET_TYPE Element HOST_NAME
                    $XmlWriter.WriteStartElement("HOST_NAME") # HOST_NAME Element
                        $XmlWriter.WriteString($hostn) # Sets host_name elemnt data
                    $XmlWriter.WriteEndElement() # End Host_Name Element HOST_IP
                    $XmlWriter.WriteStartElement("HOST_IP") # Host_IP Element
                        $XmlWriter.WriteString($ip) # Sets HOST_IP Data
                    $XmlWriter.WriteEndElement() # End HOST_IP Element
                    $XmlWriter.WriteStartElement("HOST_MAC") # HOST_MAC Element
                        $XmlWriter.WriteString($mac) # HOST_MAC Data
                    $XmlWriter.WriteEndElement() # End HOST_MAC Element
                    $XmlWriter.WriteStartElement("HOST_GUID") # HOST_GUID Element
                    $XmlWriter.WriteEndElement() # End HOST_GUID Elemen
                    $XmlWriter.WriteStartElement("HOST_FQDN") # HOST_FQDN Element
                    $XmlWriter.WriteEndElement() # End HOST_FQDN Element
                    $XmlWriter.WriteStartElement("TECH_AREA") # TECH_AREA Element
                    $XmlWriter.WriteEndElement() # End TECH_AREA Element
                    $XmlWriter.WriteStartElement("TARGET_KEY") # TARGET_KEY Element
                    $XmlWriter.WriteEndElement() # end TARGET_KEY Element
                $XmlWriter.WriteEndElement() # end ASSET Element
                $XmlWriter.WriteStartElement("STIGS") # STIGS Element
                $stigProperties = @("version","classification","stigid","description","filename","releaseinfo","title","uuid","notice","source")
                foreach($stig in ($obj | Select-Object -Unique -Property $stigProperties)){
                    $XmlWriter.WriteStartElement("iSTIG") # iSTIG Element
                        $XmlWriter.WriteStartElement("STIG_INFO") # STIG_INFO Element

                        #This loops through all $stigProperties and builds them into the xml
                        foreach($property in $stigProperties ){
                            $XmlWriter.WriteStartElement("SI_DATA") # SI_DATA Element
                                $XmlWriter.WriteStartElement("SID_NAME") # SID_NAME Element
                                    $XmlWriter.WriteString($property) # Sets element name for current Property
                                $XmlWriter.WriteEndElement() # end SID_NAME Element
                                $XmlWriter.WriteStartElement("SID_DATA") # SSID_DATA Element
                                    $XmlWriter.WriteString($($stig.$($property))) # Sets elemnt data for current Property
                                $XmlWriter.WriteEndElement() # end SID_DATA Element
                            $XmlWriter.WriteEndElement() # end SI_DATA Element
                        }

                        $XmlWriter.WriteEndElement() # end STIG_INFO Element
                        $vulnProperties = @("Vuln_Num","Severity","Group_Title","Rule_ID","Rule_Ver","Rule_Title","Vuln_Discuss","IA_Controls","Check_Content","Fix_Text",
                            "False_Positives","False_Negatives","Documentable","Mitigations","Potential_Impact","Third_Party_Tools","Mitigation_Control","Responsibility",
                            "Security_Override_Guidance","Check_Content_Ref","Class","STIGRef","TargetKey","CCI_REF")
                        foreach($Private:row in $Obj | Where-Object { $stig.stigid -eq $_.stigid }){
                            $XmlWriter.WriteStartElement("VULN") # VULN Element

                            #This loops through all $vulnProperties and builds them into the xml
                            foreach($property in $vulnProperties ){
                                $XmlWriter.WriteStartElement("STIG_DATA") # STIG_DATA Element
                                    $XmlWriter.WriteStartElement("VULN_ATTRIBUTE") # VULN_ATTRIBUTE Element
                                        $XmlWriter.WriteString($property) # Sets element name for current Property
                                    $XmlWriter.WriteEndElement() # end VULN_ATTRIBUTE Element
                                    $XmlWriter.WriteStartElement("ATTRIBUTE_DATA") # ATTRIBUTE_DATA Element
                                        $XmlWriter.WriteString($($row.$($property)))# Sets element data for current Property
                                    $XmlWriter.WriteEndElement() # end ATTRIBUTE_DATA Element
                                $XmlWriter.WriteEndElement() # end STIG_DATA Element
                            }

                            $statusProperties = @("STATUS","FINDING_DETAILS","COMMENTS","SEVERITY_OVERRIDE","SEVERITY_JUSTIFICATION")
                            foreach($property in $statusProperties ){

                                #This loops through all $statusProperties and builds them into the xml
                                $XmlWriter.WriteStartElement($property) # Sets element name for current Property
                                    $XmlWriter.WriteString($($row.$($property))) # Sets element data for current Property
                                $XmlWriter.WriteEndElement() # end element for current Property
                            }

                            $XmlWriter.WriteEndElement() # end VULN Element
                        }
                    $XmlWriter.WriteEndElement() # end iSTIG Element
                }
                $XmlWriter.WriteEndElement() # end STIGS Element
            $XmlWriter.WriteEndElement() # end CHECKLIST Element
            # Finish Document
            $XmlWriter.Flush()
            $XmlWriter.Close()
        }
    }
}
