function Import-Nessus {
<#
.SYNOPSIS
Imports a nessus file into an object

.PARAMETER doc
The XML file to parse

.EXAMPLE

.LINK

.VERSION
1.0.0 (02.10.2016)
    -Intial Release
1.0.0 (02.16.2016)
    -Added in fields from Nessus for CVSSv2 and CVSSv3
#>
    [CmdletBinding(DefaultparameterSetName="None")]
    Param (
        [Parameter(Mandatory=$true,Position=0,HelpMessage="XML Object to parse")]
        [ValidateNotNull()]
        [System.Xml.XmlDataDocument]$doc
    )
    if(!($doc.NessusClientData_v2)){
        Throw "$($file.name) is not a nessus file"
    }
    $Private:results = @()
    foreach($Private:ReportHost in $doc.NessusClientData_v2.Report.ReportHost){

        foreach($Private:ReportItemsingle in $Private:ReportHost.ReportItem){
            $Private:entry = ($Private:entry = " " | select-object "host-ip", "host-fqdn", "netbios-name", port, svc_name, protocol, severity, pluginID, pluginName, pluginFamily, description, fname, plugin_modification_date, plugin_name, plugin_publication_date, plugin_type, risk_factor, script_version, solution, synopsis, plugin_output, Credentialed_Scan, cvss_base_score, cvss_temporal_score, cvss_temporal_vector, cvss_vector, cvss3_base_score, cvss3_temporal_score, cvss3_temporal_vector, cvss3_vector)
            $Private:entry.'host-ip' = $($Private:ReportHost.HostProperties.tag | Where-Object{$_.name -eq "host-ip"} | select -ExpandProperty "#text")
            $Private:entry.'host-fqdn' = $($Private:ReportHost.HostProperties.tag | Where-Object{$_.name -eq "host-fqdn"} | select -ExpandProperty "#text")
            $Private:entry.'netbios-name' = $($Private:ReportHost.HostProperties.tag | Where-Object{$_.name -eq "netbios-name"} | select -ExpandProperty "#text")
            $Private:entry.port = $Private:ReportItemsingle.port
            $Private:entry.svc_name = $Private:ReportItemsingle.svc_name
            $Private:entry.protocol = $Private:ReportItemsingle.protocol
            $Private:entry.severity = $Private:ReportItemsingle.severity
            $Private:entry.pluginID = $Private:ReportItemsingle.pluginID
            $Private:entry.pluginName = $Private:ReportItemsingle.pluginName
            $Private:entry.pluginFamily = $Private:ReportItemsingle.pluginFamily
            $Private:entry.description = $Private:ReportItemsingle.description
            $Private:entry.fname = $Private:ReportItemsingle.fname
            $Private:entry.plugin_modification_date = $Private:ReportItemsingle.plugin_modification_date
            $Private:entry.plugin_name = $Private:ReportItemsingle.plugin_name
            $Private:entry.plugin_publication_date = $Private:ReportItemsingle.plugin_publication_date
            $Private:entry.plugin_type = $Private:ReportItemsingle.plugin_type
            #$Private:entry.cvss_vector = if($Private:ReportItemsingle.cvss_vector){$Private:ReportItemsingle.cvss_vector}else{'N/A'}
            $Private:entry.risk_factor = $Private:ReportItemsingle.risk_factor
            $Private:entry.script_version = $Private:ReportItemsingle.script_version
            $Private:entry.solution = $Private:ReportItemsingle.solution
            $Private:entry.synopsis = $Private:ReportItemsingle.synopsis
            $Private:entry.plugin_output = $Private:ReportItemsingle.plugin_output
            $Private:entry.cvss_base_score = $Private:ReportItemsingle.cvss_base_score
            $Private:entry.cvss_temporal_score = $Private:ReportItemsingle.cvss_temporal_score
            $Private:entry.cvss_temporal_vector = $Private:ReportItemsingle.cvss_temporal_vector
            if($Private:ReportItemsingle.cvss_vector -ne $null){
                $Private:entry.cvss_vector = ($Private:ReportItemsingle.cvss_vector).replace("2#",":2.0/") # this is to provide forward compatibility with CVSSv3
            }else{
                $Private:entry.cvss_vector = $Private:ReportItemsingle.cvss_vector
            }
            $Private:entry.cvss3_base_score = $Private:ReportItemsingle.cvss3_base_score
            $Private:entry.cvss3_temporal_score = $Private:ReportItemsingle.cvss3_temporal_score
            $Private:entry.cvss3_temporal_vector = $Private:ReportItemsingle.cvss3_temporal_vector
            $Private:entry.cvss3_vector = $Private:ReportItemsingle.cvss3_vector
            $Private:entry.Credentialed_Scan = $($Private:ReportHost.HostProperties.tag | Where-Object{$_.name -eq "Credentialed_Scan"} | select -ExpandProperty "#text")
            $Private:results += $Private:entry
        }
    }
    return $Private:results
}
