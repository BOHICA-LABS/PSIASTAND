function Import-NessusOpenPortsPlugin {
<#
.SYNOPSIS
Imports a nessus scan file into an object

.PARAMETER Path
Path to look for

.EXAMPLE

.LINK

.VERSION
1.0.0 (01.05.2016)
    -Intial Release

#>
    [CmdletBinding()]
    Param(
        [ValidateNotNull()]
        [Object]$file = $(Throw "No File Object Provided")
    )

    Try {
        $ErrorActionPreference = 'Stop'
        $Private:doc = New-Object System.Xml.XmlDataDocument # This creates a xlm document object
        $Private:doc.Load($file.fullname)
    }
    Catch {
        Throw "$($file.name) Not an XML Document"
    }
    $ErrorActionPreference = 'Continue'
    if(!($Private:doc.NessusClientData_v2)){ # This checks to see if this is a Nessus xml file
        Throw "$($file.name) Not a Nessus File"
    }
    $Private:results = @()
    $Private:noPorts = @()
    foreach($Private:ReportHost in $Private:doc.NessusClientData_v2.Report.ReportHost){
        if($($Private:ReportHost.HostProperties.tag | Where-Object{$_.name -eq "Credentialed_Scan"} | select -ExpandProperty "#text") -eq "false"){
            Throw "$($file.name) Not a credentialed Scan"
        }
        $Private:Ports = $Private:ReportHost.ReportItem | Where-Object{$_.pluginID -eq 34252}
        if(!($Private:Ports) -or $Private:Ports.length -lt 1){
            $Private:Ports = $Private:ReportHost.ReportItem | Where-Object{$_.pluginID -eq 25221}
            if(!($Private:Ports) -or $Private:Ports.length -lt 1){
                $Private:noPorts += $($Private:ReportHost.HostProperties.tag | Where-Object{$_.name -eq "host-ip"})
                continue
            }
        }

        foreach($Private:Port in $Private:Ports){
            $Private:entry = ($Private:entry = " " | select-object Hostname, FGDN, IP, Port, Service, Protocal, Description, Plugin)
            $Private:entry.Hostname = $($Private:ReportHost.HostProperties.tag | Where-Object{$_.name -eq "netbios-name"} | select -ExpandProperty "#text")
            $Private:entry.FGDN = $($Private:ReportHost.HostProperties.tag | Where-Object{$_.name -eq "host-fqdn"} | select -ExpandProperty "#text")
            $Private:entry.IP = $($Private:ReportHost.HostProperties.tag | Where-Object{$_.name -eq "host-ip"} | select -ExpandProperty "#text")
            $Private:entry.Port = $Private:Port.port
            $Private:entry.Service = $Private:Port.svc_name
            $Private:entry.Protocal = $Private:Port.protocol
            $Private:entry.Description = $Private:Port.plugin_output.trim("`r`n")
            $Private:entry.Plugin = $Private:Port.pluginID
            $Private:results += $Private:entry
        }
    }

    return $Private:results, $Private:noPorts
}
