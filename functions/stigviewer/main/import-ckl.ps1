function import-ckl {
<#
.SYNOPSIS
Imports a  STIG Viewer cklv2 file into an object

.PARAMETER doc
The file to look for

.EXAMPLE

.LINK

.VERSION
1.0.0 (01.23.2016)
    -Intial Release
1.0.0.1 (09.07.2016)
    -Bug fix Fix_Text and IA_Controls were not populating data.
#>
    [CmdletBinding(DefaultparameterSetName="None")]
    Param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage="XML Object to parse")]
        [ValidateNotNull()]
        [System.Xml.XmlDataDocument]$doc
    )

    if ($doc.CHECKLIST) { # Perform verious checks to determin if its a ckl file and what type it is
        if ($doc.CHECKLIST.VULN) {
            $Private:cklversion = 1
        }
        elseif ($doc.CHECKLIST.STIGS) {
            $Private:cklversion = 2
        }
        else{
            Throw "unable to determin CKL file version"
        }
    }
    else {
        Throw "Not a CKL formated file"
    }

    $Private:results = @() # list of entries we will be returning

    # Decide how we will process this CKL file
    if ($Private:cklversion -eq 1) {
        if(!($doc.CHECKLIST.ASSET.HOST_NAME)){
            Throw "$($file.name) no hostname"
        }
        foreach($Private:vuln in $doc.CHECKLIST.VULN){
            $Private:entry = ($Private:entry = " " | select-object STIG_Title, AssetName, Vuln_Num, Severity, Group_Title, Rule_ID, Rule_Ver, Rule_Title, Vuln_Discuss, IA_Controls, Check_Content, Fix_Text, False_Positives, False_Negatives, Documentable, Mitigations, Potential_Impact, Third_Party_Tools, Mitigation_Control, Responsibility, Security_Override_Guidance, Check_Content_Ref, Class, STIGRef, TargetKey, Status, Finding_Details, Comments, Severity_Override, Severity_Justification, StigViewer_Version)
            $Private:entry.STIG_Title = $doc.CHECKLIST.STIG_INFO.STIG_TITLE
            $Private:entry.AssetName = $doc.CHECKLIST.ASSET.HOST_NAME
            $Private:entry.Vuln_Num = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Vuln_Num"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Severity = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Severity"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Group_Title = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Group_Title"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Rule_ID = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Rule_ID"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Rule_Ver = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Rule_Ver"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Rule_Title = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Rule_Title"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Vuln_Discuss = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Vuln_Discuss"} | Select -ExpandProperty Attribute_Data
            $Private:entry.IA_Controls = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "IA_Controls"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Check_Content = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Check_Content"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Fix_Text = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Fix_Text"} | Select -ExpandProperty Attribute_Data
            $Private:entry.False_Positives = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "False_Positives"} | Select -ExpandProperty Attribute_Data
            $Private:entry.False_Negatives = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "False_Negatives"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Documentable = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Documentable"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Mitigations = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Mitigations"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Potential_Impact = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Potential_Impact"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Third_Party_Tools = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Third_Party_Tools"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Mitigation_Control = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Mitigation_Control"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Responsibility = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Responsibility"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Security_Override_Guidance = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Security_Override_Guidance"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Check_Content_Ref = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Check_Content_Ref"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Class = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "Class"} | Select -ExpandProperty Attribute_Data
            $Private:entry.STIGRef = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "STIGRef"} | Select -ExpandProperty Attribute_Data
            $Private:entry.TargetKey = $Private:vuln.STIG_DATA | Where-Object{$_.VULN_ATTRIBUTE -eq "TargetKey"} | Select -ExpandProperty Attribute_Data
            $Private:entry.Status = $Private:vuln.STATUS
            $Private:entry.Finding_Details = $Private:vuln.FINDING_DETAILS
            $Private:entry.Comments = $Private:vuln.COMMENTS
            $Private:entry.Severity_Override = $Private:vuln.SEVERITY_OVERRIDE
            $Private:entry.Severity_Justification = $Private:vuln.SEVERITY_JUSTIFICATION
            $Private:entry.StigViewer_Version = $Private:cklversion
            $Private:results += $Private:entry
        } # Foreach
    return $Private:results
    }
    elseif ($Private:cklversion -eq 2) {
        if (!($doc.CHECKLIST.ASSET.HOST_NAME)) { # Check for a hostname, if not fail.
            Throw "$($file.name) no hostname"
        }

        foreach ($Private:stig in $doc.CHECKLIST.STIGS.ISTIG) { # Run through each STIG contained in the CKL

            foreach ($Private:vuln in $Private:stig.VULN) {
                $Private:entry = ($Private:entry = " " | select-object ASSET_TYPE, HOST_NAME, HOST_IP, HOST_MAC, HOST_GUID, HOST_FQDN, TECH_AREA, TARGET_KEY, version, classification, stigid, description, filename, releaseinfo, title, uuid, notice, source, Vuln_Num, Severity, Group_Title, Rule_ID, Rule_Ver, Rule_Title, Vuln_Discuss, IA_Controls, Check_Content, Fix_Text, False_Positives, False_Negatives, Documentable, Mitigations, Potential_Impact, Third_Party_Tools, Mitigation_Control, Responsibility, Security_Override_Guidance, Check_Content_Ref, Class, STIGRef, TargetKey, CCI_REF, Status, Finding_Details, Comments, Severity_Override, Severity_Justification, StigViewer_Version) # Setup the entry object
                $Private:entry.ASSET_TYPE = $Private:doc.CHECKLIST.ASSET.ASSET_TYPE
                $Private:entry.HOST_NAME = $Private:doc.CHECKLIST.ASSET.HOST_NAME
                $Private:entry.HOST_IP = $Private:doc.CHECKLIST.ASSET.HOST_IP
                $Private:entry.HOST_MAC = $Private:doc.CHECKLIST.ASSET.HOST_MAC
                $Private:entry.HOST_GUID = $Private:doc.CHECKLIST.ASSET.HOST_GUID
                $Private:entry.HOST_FQDN = $Private:doc.CHECKLIST.ASSET.HOST_FQDN
                $Private:entry.TECH_AREA = $Private:doc.CHECKLIST.ASSET.TECH_AREA
                $Private:entry.TARGET_KEY = $Private:doc.CHECKLIST.ASSET.TARGET_KEY
                $Private:entry.version = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "version"}).SID_DATA
                $Private:entry.classification = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "classification"}).SID_DATA
                $Private:entry.stigid = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "stigid"}).SID_DATA
                $Private:entry.description = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "description"}).SID_DATA
                $Private:entry.filename = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "filename"}).SID_DATA
                $Private:entry.releaseinfo = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "releaseinfo"}).SID_DATA
                $Private:entry.title = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "title"}).SID_DATA
                $Private:entry.uuid = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "uuid"}).SID_DATA
                $Private:entry.notice = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "notice"}).SID_DATA
                $Private:entry.source = $($Private:stig.STIG_INFO.SI_DATA | Where-Object {$_.SID_NAME -eq "source"}).SID_DATA
                $Private:entry.Vuln_Num = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Vuln_Num"}).ATTRIBUTE_DATA
                $Private:entry.Severity = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Severity"}).ATTRIBUTE_DATA
                $Private:entry.Group_Title = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Group_Title"}).ATTRIBUTE_DATA
                $Private:entry.Rule_ID = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Rule_ID"}).ATTRIBUTE_DATA
                $Private:entry.Rule_Ver = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Rule_Ver"}).ATTRIBUTE_DATA
                $Private:entry.Rule_Title = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Rule_Title"}).ATTRIBUTE_DATA
                $Private:entry.Vuln_Discuss = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Vuln_Discuss"}).ATTRIBUTE_DATA
                $Private:entry.IA_Controls = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "IA_Controls"}).ATTRIBUTE_DATA
                $Private:entry.Check_Content = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Check_Content"}).ATTRIBUTE_DATA
                $Private:entry.Fix_Text = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Fix_Text"}).ATTRIBUTE_DATA
                $Private:entry.False_Positives = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "False_Positives"}).ATTRIBUTE_DATA
                $Private:entry.False_Negatives = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "False_Negatives"}).ATTRIBUTE_DATA
                $Private:entry.Documentable = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Documentable"}).ATTRIBUTE_DATA
                $Private:entry.Mitigations = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Mitigations"}).ATTRIBUTE_DATA
                $Private:entry.Potential_Impact = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Potential_Impact"}).ATTRIBUTE_DATA
                $Private:entry.Third_Party_Tools = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Third_Party_Tools"}).ATTRIBUTE_DATA
                $Private:entry.Mitigation_Control = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Mitigation_Control"}).ATTRIBUTE_DATA
                $Private:entry.Responsibility = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Responsibility"}).ATTRIBUTE_DATA
                $Private:entry.Security_Override_Guidance = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Security_Override_Guidance"}).ATTRIBUTE_DATA
                $Private:entry.Check_Content_Ref = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Check_Content_Ref"}).ATTRIBUTE_DATA
                $Private:entry.Class = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "Class"}).ATTRIBUTE_DATA
                $Private:entry.STIGRef = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "STIGRef"}).ATTRIBUTE_DATA
                $Private:entry.TargetKey = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "TargetKey"}).ATTRIBUTE_DATA
                $Private:entry.CCI_REF = $($Private:vuln.STIG_DATA | Where-Object {$_.VULN_ATTRIBUTE -eq "CCI_REF"}).ATTRIBUTE_DATA
                $Private:entry.Status = $Private:vuln.STATUS
                $Private:entry.Finding_Details = $Private:vuln.Finding_Details
                $Private:entry.Comments = $Private:vuln.COMMENTS
                $Private:entry.Severity_Override = $Private:vuln.Severity_Override
                $Private:entry.Severity_Justification = $Private:vuln.Severity_Justification
                $Private:entry.StigViewer_Version = $Private:cklversion
                $Private:results += $Private:entry

            }
        }

        return $Private:results
    }
    else {
        Throw "should not be here...this is weird"
    }

}

