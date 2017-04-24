function New-CKLObject () {
  <#
    .SYNOPSIS

    .PARAMETER

    .EXAMPLE
    $CKL = New-CKLObject

    .LINK

    .VERSION
        1.0.0.1 (21FEB2017)
            -Initial

#>

    $CKL = @{}

    #Create the CKL object array
    $CKL.Data = @{}

    #Creates the error handling return array
    $CKL.error = @{}
    
    #This hastable provides mapping to/from CKL objects and CKLv2 Files
    $CKL.v2Map = [Ordered]@{

        #System specific dataset
        "ASSET_TYPE" = "System_Asset_Type"
        "HOST_NAME" = "System_HOST_NAME"
        "HOST_IP" = "System_HOST_IP"
        "HOST_MAC" = "System_HOST_MAC"
        "HOST_GUID" = "System_HOST_GUID"
        "HOST_FQDN" = "System_HOST_FQDN"
        "TECH_AREA" = "System_TECH_AREA"
        "TARGET_KEY" = "System_TARGET_KEY"

        #STIG specific dataset
        "Version" = "STIG_Version"
        "Classification" = "STIG_Classification"
        "Customname" = "STIG_customname"
        "StigID" = "STIG_StigID"
        "Description" = "STIG_Description"
        "FileName" = "STIG_FileName"
        "ReleaseInfo" = "STIG_ReleaseInfo"
        "Title" = "STIG_Title"
        "UUID" = "STIG_UUID"
        "Notice" = "STIG_Notice"
        "Source" = "STIG_Source"

        #VULN specific dataset
        "Vuln_Num" = "Vuln_Num"
        "Severity" = "Vuln_Severity"
        "Group_Title" = "Vuln_Group_Title"
        "Rule_ID" = "Vuln_Rule_ID"
        "Rule_Ver" = "Vuln_Rule_Ver"
        "Rule_Title" = "Vuln_Rule_Title"
        "Vuln_Discuss" = "Vuln_Discuss"
        "IA_Controls" = "Vuln_IA_Controls"
        "Check_Content" = "Vuln_Check_Content"
        "Fix_Text" = "Vuln_Fix_Text"
        "False_Positives" = "Vuln_False_Positives"
        "False_Negatives" = "Vuln_False_Negatives"
        "Documentable" = "Vuln_Documentable"
        "Mitigations" = "Vuln_Mitigations"
        "Potential_Impact" = "Vuln_Potential_Impact"
        "Third_Party_Tools" = "Vuln_Third_Party_Tools"
        "Mitigation_Control" = "Vuln_Mitigation_Control"
        "Responsibility" = "Vuln_Responsibility"
        "Security_Override_Guidance" = "Vuln_Security_Override_Guidance"
        "Check_Content_Ref" = "Vuln_Check_Content_Ref"
        "Class" = "Vuln_Class"
        "STIGRef" = "Vuln_STIGRef"
        "TargetKey" = "Vuln_TargetKey"
        "Status" = "Vuln_Status"
        "Finding_Details" = "Vuln_Finding_Details"
        "Comments" = "Vuln_Comments"
        "Severity_Override" = "Vuln_Severity_Override"
        "Severity_Justification" = "Vuln_Severity_Justification"
    }

    Add-Member -InputObject $CKL -MemberType ScriptMethod -name 'ImportFromFile' -value {
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
        [XML]$cklFile = (Get-Content $file)
        Write-Verbose "XML $file loaded into memory"

        # Checks to see if the XML is in CKL format by validating the top level tree.
        # Then based of the second level we can determin the version.
        if ($cklFile.CHECKLIST) {
            if ($cklFile.CHECKLIST.VULN) {
                $cklVersion = 1
                Write-Verbose "CKL Version 1 detected"
            }elseif ($cklFile.CHECKLIST.STIGS) {
                $cklVersion = 2
                Write-Verbose "CKL Version 2 detected"
            }else{
                $this.error = @{ Success = $false; errorType = "Unable to determin CKL file version"}
                return
            }
        }else{
            $this.error =  @{ Success = $false; errorType = "Malformed CKL file"}
            return
        }


        switch($cklVersion) {
            #CKL v1
            1 {

            }

            #CKL v2
            2 {
                $CKLData = @{}
                $CKLData.$($this.v2Map.Asset_Type) = $cklFile.CHECKLIST.ASSET.Asset_Type
                $CKLData.$($this.v2Map.HOST_NAME) = $cklFile.CHECKLIST.ASSET.HOST_NAME
                $CKLData.$($this.v2Map.HOST_IP) = $cklFile.CHECKLIST.ASSET.HOST_IP
                $CKLData.$($this.v2Map.HOST_MAC) = $cklFile.CHECKLIST.ASSET.HOST_MAC
                $CKLData.$($this.v2Map.HOST_GUID) = $cklFile.CHECKLIST.ASSET.HOST_GUID
                $CKLData.$($this.v2Map.HOST_FQDN) = $cklFile.CHECKLIST.ASSET.HOST_FQDN
                $CKLData.$($this.v2Map.TECH_AREA) = $cklFile.CHECKLIST.ASSET.TECH_AREA
                $CKLData.$($this.v2Map.TARGET_KEY) = $cklFile.CHECKLIST.ASSET.TARGET_KEY

                #Version 2 allows for multiple stigs inside 1 ckl.  This loops through each stig group.
                $CKLStigs = @()
                ForEach ($stig in $cklFile.CHECKLIST.STIGS.ISTIG) {
                    $stigResults = [ordered]@{}
                    
                    $stigResults.$($this.v2Map.Version) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "version" }).SID_Data
                    $stigResults.$($this.v2Map.Classification) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "classification" }).SID_Data
                    $stigResults.$($this.v2Map.StigID) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "stigid" }).SID_Data
                    $stigResults.$($this.v2Map.Description) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "description" }).SID_Data
                    $stigResults.$($this.v2Map.FileName) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "filename" }).SID_Data
                    $stigResults.$($this.v2Map.ReleaseInfo) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "releaseinfo" }).SID_Data
                    $stigResults.$($this.v2Map.Title) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "title" }).SID_Data
                    $stigResults.$($this.v2Map.UUID) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "uuid" }).SID_Data
                    $stigResults.$($this.v2Map.Notice) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "notice" }).SID_Data
                    $stigResults.$($this.v2Map.Source) = ($stig.STIG_INFO.SI_DATA | Where-Object { $_.SID_Name -eq "source" }).SID_Data

                    $CKLVulns = @()
                    foreach ($vuln in $stig.VULN) {
                        $vulnResults = [ordered]@{}

                        $vulnResults.$($this.v2Map.Vuln_Num) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Vuln_Num"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Severity) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Severity"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Group_Title) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Group_Title"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Rule_ID) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Rule_ID"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Rule_Ver) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Rule_Ver"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Rule_Title) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Rule_Title"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Vuln_Discuss) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Vuln_Discuss"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.IA_Controls) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "IA_Controls"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Check_Content) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Check_Content"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Fix_Text) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Fix_Text"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.False_Positives) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "False_Positives"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.False_Negatives) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "False_Negatives"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Documentable) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Documentable"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Mitigations) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Mitigations"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Potential_Impact) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Potential_Impact"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Third_Party_Tools) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Third_Party_Tools"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Mitigation_Control) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Mitigation_Control"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Responsibility) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Responsibility"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Security_Override_Guidance) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Security_Override_Guidance"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Check_Content_Ref) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Check_Content_Ref"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Class) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Class"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.STIGRef) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "STIGRef"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.TargetKey) = $($vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "TargetKey"}).ATTRIBUTE_DATA
                        $vulnResults.$($this.v2Map.Status) = $vuln.STATUS
                        $vulnResults.$($this.v2Map.Finding_Details) = $vuln.Finding_Details
                        $vulnResults.$($this.v2Map.Comments) = $vuln.COMMENTS
                        $vulnResults.$($this.v2Map.Severity_Override) = $vuln.Severity_Override
                        $vulnResults.$($this.v2Map.Severity_Justification) = $vuln.Severity_Justification

                        $CKLVulns += $vulnResults
                    }
                    $stigResults.STIG_Vulns = $CKLVulns

                    $CKLStigs += $stigResults
                }

                $CKLData.System_STIGS = $CKLStigs
            }
        }

        $this.Data = @{
            Success = $true
            CKLVersion = $cklVersion
            CKLData = $CKLData
        }
        $this.error = @{
            Success = $true
            errorType = $null
        }
    }

    #Exports the CKL object in memory to the provided location and with the provided CKL version
    Add-Member -InputObject $CKL -MemberType ScriptMethod -name 'ExportToFile' -value {
        Param(
            [string]$file,
            [int]$CKLVersion
        )

        #Validates the file path for the export
        If (!(Test-Path(Split-Path $file))){
            $this.error = @{ Success = $false; errorType = "Invalid export path provided"}
            return
        }

        #Validates correct version has been provided for export
        If (!($CKLVersion -eq 1 -or $CKLVersion -eq 2)){
            $this.error = @{ Success = $false; errorType = "Invalid CKL version specified"}
            return
        }

        #Validates that the CKL object has been successfully populated
        If ($this.Data.Success -ne $true){
            $this.error = @{ Success = $false; errorType = "CKL data not present.  Please rerun an import method first."}
            return
        }

        #Validates the the CKL Object version and export version are the same
        If ($this.Data.CKLVersion -ne $CKLVersion) {
            $this.error = @{ Success = $false; errorType = "CKL Object and export are not it the same version.  Please try converting and try again."}
            return
        }

        switch($CKLVersion){
            1{

            }
            2{
                $params = "version=""1.0"" encoding=""UTF-8"" standalone=""yes"""
                $XmlWriter = New-Object System.Xml.XmlTextWriter($file, $null)
                $XmlWriter.Formatting = "Indented"
                $XmlWriter.Indentation = 1
                $XmlWriter.IndentChar = "`t"
                $XmlWriter.WriteProcessingInstruction("xml", $params) # Starts XML Document
                # Start or XML Data
                $XmlWriter.WriteStartElement("CHECKLIST") # Root Element Checklist
                    $XmlWriter.WriteStartElement("ASSET") # Start ASSET Element
                        $SystemProperties = @("ASSET_TYPE","HOST_NAME","HOST_IP","HOST_MAC","HOST_GUID","HOST_FQDN","TECH_AREA","TARGET_KEY")
                        foreach($SystemProperty in $SystemProperties){
                            $XmlWriter.WriteStartElement($SystemProperty) #Writes the current $SystemProperty Header
                                $XmlWriter.WriteString($ckl.Data.CKLData.$($this.v2Map.$($SystemProperty))) # Sets Asset type element data
                            $XmlWriter.WriteEndElement() #Writes the current $SystemProperty End
                        }
                    $XmlWriter.WriteEndElement() # End ASSET Element
                    $XmlWriter.WriteStartElement("STIGS") # Start iSTIG Element
                        foreach($Stig in $this.Data.CKLData.System_STIGS){
                            $XmlWriter.WriteStartElement("iSTIG") # Start iSTIG Element
                                $XmlWriter.WriteStartElement("STIG_INFO") # Start STIG_INFO Element
                                    $StigProperties = @("version","classification"."customname","stigid","description","filename","releaseinfo","title","uuid","notice","source")
                                    foreach($StigProperty in $StigProperties){
                                        $XmlWriter.WriteStartElement("SI_DATA") # Start SI_DATA Element
                                            $XmlWriter.WriteStartElement("SID_NAME") # Start SID_NAME Element
                                                $XmlWriter.WriteString($StigProperty) # Writes the current SystemProperty name
                                            $XmlWriter.WriteEndElement() # End SID_NAME Element
                                            $XmlWriter.WriteStartElement("SID_DATA") # Start SID_DATA Element
                                                $XmlWriter.WriteString($Stig.$($this.v2Map.$($StigProperty))) # Writes the current SystemProperty value
                                            $XmlWriter.WriteEndElement() # End SID_DATA Element
                                        $XmlWriter.WriteEndElement() # End SI_Data Element
                                    }
                                $XmlWriter.WriteEndElement() # Start STIG_INFO Element
                                foreach ($Vuln in $Stig.STIG_VULNS){
                                    $VulnProperties = @("Vuln_Num","Severity","Group_Title","Rule_ID","Rule_Ver","Rule_Title","Vuln_Discuss","IA_Controls","Check_Content","Fix_Text",
                                        "False_Positives","False_Negatives","Documentable","Mitigations","Potential_Impact","Third_Party_Tools","Mitigation_Control","Responsibility",
                                        "Security_Override_Guidance","Check_Content_Ref","Class","STIGRef","TargetKey")
                                    $XmlWriter.WriteStartElement("VULN") # Start VULN Element
                                        foreach($VulnProperty in $VulnProperties){
                                            $XmlWriter.WriteStartElement("STIG_DATA") # Start STIG_DATA Element
                                                $XmlWriter.WriteStartElement("VULN_ATTRIBUTE") # Start VULN_ATTRIBUTE Element
                                                    $XmlWriter.WriteString($VulnProperty) #Writes the current Vuln Property Name
                                                $XmlWriter.WriteEndElement() # End VULN_ATTRIBUTE Element
                                                $XmlWriter.WriteStartElement("ATTRIBUTE_DATA") # Start ATTRIBUTE_DATA Element
                                                    $XmlWriter.WriteString($Vuln.$($this.v2Map.$($VulnProperty))) #Writes the current Vuln Property Value
                                                $XmlWriter.WriteEndElement() # End ATTRIBUTE_DATA Element
                                            $XmlWriter.WriteEndElement() # End STIG_DATA Element
                                        }
                                        $FindingProperties = @("STATUS","FINDING_DETAILS","COMMENTS","SEVERITY_OVERRIDE","SEVERITY_JUSTIFICATION")
                                        foreach($FindingProperty in $FindingProperties){
                                            $XmlWriter.WriteStartElement($FindingProperty) # Start the current FindingProperty Element
                                                $XmlWriter.WriteString($Vuln.$($this.v2Map.$($FindingProperty))) #Writes the current Vuln Property Name
                                            $XmlWriter.WriteEndElement() # End the current FindingProperty Element
                                        }
                                    $XmlWriter.WriteEndElement() # End VULN Element
                                }
                            $XmlWriter.WriteEndElement() # End iSTIG Element
                        }
                    $XmlWriter.WriteEndElement() # End STIGS Element


                $XmlWriter.Flush()
                $XmlWriter.Close()
            }

        }

    }

    return $CKL
}