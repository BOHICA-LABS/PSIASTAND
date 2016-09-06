function Export-Tracker {
<#
.SYNOPSIS
This function exports a ckl object to a csv tracker  file

.PARAMETER Object
    ckl object loaded from import-ckl

.PARAMETER exportlocation
    export location for the file

.EXAMPLE
    Export-Tracker -object $ckl -version 2 -exportlocation .\test.csv

.LINK

.VERSION
1.0.0.0 (09.02.2016)
    Initial release

#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,HelpMessage="CKL formated object, either V1 or V2")]
        [object]$object,
        [Parameter(Mandatory=$true)]
        [int]$version,
        [Parameter(Mandatory=$true)]
        [string]$exportlocation
    )
    $finaloutput = @()
    foreach ($row in $object) {
        $rowoutput = "" | Select-Object Vuln_Num, Severity, Status, Notes, Validator, Date, Check_Content, Group_Title, Rule_ID, stigid, Rule_Title, Vuln_Discuss, IA_Controls, Fix_Text, False_Positives, False_Negatives,
            Documentable, Mitigations, Potential_Impact, Third_Party_Tools, Mitigation_Control, Responsibility, Security_Override_Guidance, Check_Content_Ref, Class,
            STIGRef, ASSET_TYPE, HOST_NAME, HOST_IP, HOST_MAC, HOST_GUID, HOST_FQDN, TECH_AREA, TARGET_KEY, version, classification, description, filename, releaseinfo, title, uuid, notice, source, Rule_Ver,
            TargetKey, CCI_REF, Finding_Details, Comments, Severity_Override, Severity_Justification, StigViewer_Version   
        $rowoutput.ASSET_TYPE = $row.ASSET_TYPE
        $rowoutput.HOST_NAME = $row.HOST_NAME
        $rowoutput.HOST_IP = $row.HOST_IP
        $rowoutput.HOST_MAC = $row.HOST_MAC
        $rowoutput.HOST_GUID = $row.HOST_GUID
        $rowoutput.HOST_FQDN = $row.HOST_FQDN
        $rowoutput.TECH_AREA = $row.TECH_AREA
        $rowoutput.TARGET_KEY = $row.TARGET_KEY
        $rowoutput.version = $row.version
        $rowoutput.classification = $row.classification
        $rowoutput.stigid = $row.stigid
        $rowoutput.description = $row.description
        $rowoutput.filename = $row.filename
        $rowoutput.releaseinfo = $row.releaseinfo
        $rowoutput.title = $row.title
        $rowoutput.uuid = $row.uuid
        $rowoutput.notice = $row.notice
        $rowoutput.source = $row.source
        $rowoutput.Vuln_Num = $row.Vuln_Num
        $rowoutput.Severity = $row.Severity
        $rowoutput.Group_Title = $row.Group_Title
        $rowoutput.Rule_ID = $row.Rule_ID
        $rowoutput.Rule_Ver = $row.Rule_Ver
        $rowoutput.Rule_Title = $row.Rule_Title
        $rowoutput.Vuln_Discuss = $row.Vuln_Discuss
        $rowoutput.IA_Controls = $row.IA_Controls
        $rowoutput.Check_Content = $row.Check_Content
        $rowoutput.Fix_Text = $row.Fix_Text
        $rowoutput.False_Positives = $row.False_Positives
        $rowoutput.False_Negatives = $row.False_Negatives
        $rowoutput.Documentable = $row.Documentable
        $rowoutput.Mitigations = $row.Mitigations
        $rowoutput.Potential_Impact = $row.Potential_Impact
        $rowoutput.Third_Party_Tools = $row.Third_Party_Tools
        $rowoutput.Mitigation_Control = $row.Mitigation_Control
        $rowoutput.Responsibility = $row.Responsibility
        $rowoutput.Security_Override_Guidance = $row.Security_Override_Guidance
        $rowoutput.Check_Content_Ref = $row.Check_Content_Ref
        $rowoutput.Class = $row.Class
        $rowoutput.STIGRef = $row.STIGRef
        $rowoutput.TargetKey = $row.TargetKey
        $rowoutput.CCI_REF = $row.CCI_REF
        $rowoutput.Status = $row.Status
        $rowoutput.Finding_Details = $row.Finding_Details
        $rowoutput.Comments = $row.Comments
        $rowoutput.Severity_Override = $row.Severity_Override
        $rowoutput.Severity_Justification = $row.Severity_Justification
        $rowoutput.StigViewer_Version = $row.StigViewer_Version
        $rowoutput.Notes = ""
        $rowoutput.Validator = ""
        $rowoutput.Date = ""
        $finaloutput += $rowoutput
    }
    $finaloutput | Export-Csv -Path $exportlocation -NoTypeInformation
    #$finaloutput | Export-XLSX -Path $exportlocation
}

#$file = Get-item .\tests\data\CKL\CKLv2\sampleV2.ckl
#$xml = import-xml -fileobj $file
#$ckl = import-ckl -doc $xml
#Export-Tracker -object $ckl -version 2 -exportlocation .\test.csv
