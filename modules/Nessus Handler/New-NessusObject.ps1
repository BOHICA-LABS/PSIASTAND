function New-NessusObject () {
  <#
    .SYNOPSIS

    .PARAMETER

    .EXAMPLE
    $Nessus = New-NessusObject

    .LINK

    .VERSION
        1.0.0.1 (07MAR2017)
            -Initial

#>

    $Nessus = @{}

    #Create the Nessus object array
    $Nessus.Data = @{}

    #Creates the Error handling return array
    $Nessus.Error = @{}

    Add-Member -InputObject $Nessus -MemberType ScriptMethod -name 'ImportFromFile' -value {
        Param(
            [Parameter(Mandatory=$true)]
            [string]$file
        )

        #Validate the presence of the file provided
        if (!(Test-Path $file)){
            $this.Error = @{ Success = $false; errorType = "File Not Found"}
            return
        }else{
            Write-Verbose "File $file located"
        }

        #Import the Nessus file into an XML struct
        ### TODO: Need to validate if the file is XML before loading it to prevent errors
        [XML]$nessusFile = (Get-Content $file)
        Write-Verbose "XML $file loaded into memory"

        #Validate that the file is in Nessus format
        if(!($nessusFile.NessusClientData_v2)){
            $this.Error = @{ Success = $false; errorType = "Invalid Nessus file."}
        }

        $results = @()
        $PolicyResults = @{}
        $PolicyResults.PluginsRan = $($nessusFile.NessusClientData_v2.Policy.Preferences.ServerPreferences.preference | Where-Object{$_.name -eq "plugin_set"} | Select -ExpandProperty "value").split(";")
        $PolicyResults.PluginsRanCount = $($PolicyResults.PluginsRan).Count
        $PolicyResults.FamilySelection = $nessusFile.NessusClientData_v2.Policy.FamilySelection.FamilyItem

        $returnPrefs = @{}
        ForEach($preference in $nessusFile.NessusClientData_v2.Policy.Preferences.ServerPreferences.preference.name){
            $returnPrefs.$preference = $($nessusFile.NessusClientData_v2.Policy.Preferences.ServerPreferences.preference | Where-Object{$_.name -eq $($preference)} | Select -ExpandProperty "value")
        }

        $PolicyResults.Preferences = $returnPrefs

        ForEach($ReportHost in $nessusFile.NessusClientData_v2.Report.ReportHost){

            #Collects host identifiable information
            $HostResult = @{}
            $HostResult.HostName = $($ReportHost.HostProperties.tag | Where-Object{$_.name -eq "hostname"} | Select -ExpandProperty "#text")
            $HostResult.HostNetBIOSName = $($ReportHost.HostProperties.tag | Where-Object{$_.name -eq "netbios-name"} | Select -ExpandProperty "#text")
            $HostResult.HostFQDN = $($ReportHost.HostProperties.tag | Where-Object{$_.name -eq "host-fqdn"} | select -ExpandProperty "#text")
            $HostResult.HostIP = $($ReportHost.HostProperties.tag | Where-Object{$_.name -eq "host-ip"} | select -ExpandProperty "#text")
            $HostResult.HostOS = $($ReportHost.HostProperties.tag | Where-Object{$_.name -eq "operating-system"} | select -ExpandProperty "#text")
            $HostResult.HostCredentialedScan = $($ReportHost.HostProperties.tag | Where-Object{$_.name -eq "Credentialed_Scan"} | select -ExpandProperty "#text")
            $HostResult.HostMACAddress = $($ReportHost.HostProperties.tag | Where-Object{$_.name -eq "mac-address"} | Select -ExpandProperty "#text")

            #Locates the plugins specific to open ports
            $HostOpenPorts = @()
            $HostNoPorts = @()
            $Ports = $ReportHost.ReportItem | Where-Object{$_.pluginID -eq 34252}
            if(!($Ports) -or $Ports.length -lt 1){
                $Ports = $ReportHost.ReportItem | Where-Object{$_.pluginID -eq 25221}
                if(!($Ports) -or $Ports.length -lt 1){
                    $noPorts += $($ReportHost.HostProperties.tag | Where-Object{$_.name -eq "host-ip"})
                    continue
                }
            }

            #Loops through all the found ports
            foreach($Port in $Ports){
                $entry = @{}
                $entry.Port = $Port.port
                $entry.Service = $Port.svc_name
                $entry.Protocal = $Port.protocol
                $entry.Description = $Port.plugin_output.trim("`r`n")
                $entry.Plugin = $Port.pluginID
                $HostOpenPorts += $entry
            }

            #Loops through all plugins and adds to report
            $HostPlugins = @()
            $HostEntry = @()
            ForEach($ReportItemsingle in $ReportHost.ReportItem){
                $entry = [Ordered]@{}
                $fieldNames = @()
                $fieldNames = $ReportItemsingle.Attributes | foreach { $_.LocalName }
                $fieldNames += $ReportItemsingle.ChildNodes | foreach { $_.LocalName }
                ForEach($item in $fieldNames){
                    $entry.$item = $ReportItemsingle.$item
                }
                $HostEntry += $entry
            }

            $HostResult.HostPorts = $HostOpenPorts
            $HostResult.HostPluginList = $HostEntry | Select -Unique PluginID, Name | Sort ID, Name
            $HostResult.HostPluginCount = ($HostResult.HostPluginList).Count
            $HostResult.HostReport = $HostEntry
            $results += $HostResult
        }


        $this.Data = @{
            Success = $true
            Hosts = $results
            ScanPolicy = $PolicyResults
        }

    }

    return $Nessus

}