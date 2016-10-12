$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"


#Import-Module "$here\..\..\..\..\$($moduleName)"
#InModuleScope nessusOpenPorts {
    Describe -tag 'Import-NessusOpenPortsPlugin' "Import-NessusOpenPortsPlugin" {
        Setup -File sample.nessus
        Setup -File anothersample.txt
        Setup -File sample2.nessus
        Setup -File sample3.nessus
        Setup -File sample4.nessus

        Set-Content -Path TestDrive:\sample.nessus -Value @'
<?xml version="1.0" ?>
<NessusClientData_v2>
	<Policy>
		<policyName>
		</policyName>
		<Preferences>
		</Preferences>
		<FamilySelection>
		</FamilySelection>
		<IndividualPluginSelection>
		</IndividualPluginSelection>
	</Policy>
	<Report name="Test Scan" xmlns:cm="http://wwww.nessus.org/cm">
		<ReportHost name="192.168.1.1">
			<HostProperties>
				<tag name="Credentialed_Scan">true</tag>
				<tag name="host-ip">192.168.1.1</tag>
				<tag name="host-fq">randomhost1.randomsubdomain.randomdomain</tag>
			</HostProperties>
			<ReportItem port="2868" svc_name="npep-messaging?" protocol="tcp" severity="0" pluginID="25221" pluginName="Remote listeners enumeration (Linux / AIX)" pluginFamily="Service detection">

				<agent>unix</agent>

				<description>Remote listeners enumeration (Sample Description)</description>

				<fname>process_on_port.nasl</fname>

				<plugin_modification_date>2015/06/02</plugin_modification_date>

				<plugin_name>Remote listeners enumeration (Linux / AIX)</plugin_name>

				<plugin_publication_date>2007/05/16</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>1.17</script_version>

				<solution>n/a</solution>

				<synopsis>Using the supplied credentials, it is possible to identify the process listening on the remote port.</synopsis>

				<plugin_output>
  Process id   : 2544
  Executable   : /opt/vmware/sbin/vami-lighttpd
  Command line : /opt/vmware/sbin/vami-lighttpd -f /opt/vmware/etc/lighttpd/lighttpd.conf </plugin_output>

			</ReportItem>
			<ReportItem port="514" svc_name="syslog?" protocol="udp" severity="0" pluginID="25221" pluginName="Remote listeners enumeration (Linux / AIX)" pluginFamily="Service detection">

				<agent>unix</agent>

				<description>Remote listeners enumeration (Sample Description)</description>

				<fname>process_on_port.nasl</fname>

				<plugin_modification_date>2015/06/02</plugin_modification_date>

				<plugin_name>Remote listeners enumeration (Linux / AIX)</plugin_name>

				<plugin_publication_date>2007/05/16</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>1.17</script_version>

				<solution>n/a</solution>

				<synopsis>Using the supplied credentials, it is possible to identify the process listening on the remote port.</synopsis>

				<plugin_output>  Process id   : 2118
  Executable   : /sbin/syslog-ng
  Command line : /sbin/syslog-ng </plugin_output>

			</ReportItem>
		</ReportHost>
		<ReportHost name="192.168.1.2">
			<HostProperties>
				<tag name="Credentialed_Scan">true</tag>
				<tag name="host-ip">192.168.1.2</tag>
				<tag name="host-fq">randomhost2.randomsubdomain.randomdomain</tag>
			</HostProperties>
			<ReportItem port="445" svc_name="cifs" protocol="tcp" severity="0" pluginID="34252" pluginName="Microsoft Windows Remote Listeners Enumeration (WMI)" pluginFamily="Windows">

				<description>WMI (Sample Description)</description>

				<fname>wmi_process_on_port.nbin</fname>

				<plugin_modification_date>2015/08/24</plugin_modification_date>

				<plugin_name>Microsoft Windows Remote Listeners Enumeration (WMI)</plugin_name>

				<plugin_publication_date>2008/09/23</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>$Revision: 1.32 $</script_version>

				<solution>n/a</solution>

				<synopsis>It is possible to obtain the names of processes listening on the remote UDP and TCP ports.</synopsis>

				<plugin_output>
The Win32 process &apos;System&apos; is listening on this port (pid 4).</plugin_output>
			</ReportItem>

			<ReportItem port="49152" svc_name="dce-rpc" protocol="tcp" severity="0" pluginID="34252" pluginName="Microsoft Windows Remote Listeners Enumeration (WMI)" pluginFamily="Windows">

				<description>WMI (Sample Description)</description>

				<fname>wmi_process_on_port.nbin</fname>

				<plugin_modification_date>2015/08/24</plugin_modification_date>

				<plugin_name>Microsoft Windows Remote Listeners Enumeration (WMI)</plugin_name>

				<plugin_publication_date>2008/09/23</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>$Revision: 1.32 $</script_version>

				<solution>n/a</solution>

				<synopsis>It is possible to obtain the names of processes listening on the remote UDP and TCP ports.</synopsis>

				<plugin_output>
The Win32 process &apos;wininit.exe&apos; is listening on this port (pid 488).</plugin_output>

			</ReportItem>

		</ReportHost>
	</Report>
</NessusClientData_v2>
'@
        Set-Content -Path TestDrive:\sample2.nessus -Value @'
<?xml version="1.0" encoding="UTF-8"?>
<note>
	<to>Tove</to>
	<from>Jani</from>
	<heading>Reminder</heading>
	<body>Don't forget me this weekend!</body>
</note>
'@

        Set-Content -Path TestDrive:\sample3.nessus -Value @'
<?xml version="1.0" ?>
<NessusClientData_v2>
	<Policy>
		<policyName>
		</policyName>
		<Preferences>
		</Preferences>
		<FamilySelection>
		</FamilySelection>
		<IndividualPluginSelection>
		</IndividualPluginSelection>
	</Policy>
	<Report name="Test Scan" xmlns:cm="http://wwww.nessus.org/cm">
		<ReportHost name="192.168.1.1">
			<HostProperties>
				<tag name="Credentialed_Scan">true</tag>
				<tag name="host-ip">192.168.1.1</tag>
				<tag name="host-fq">randomhost1.randomsubdomain.randomdomain</tag>
			</HostProperties>
			<ReportItem port="2868" svc_name="npep-messaging?" protocol="tcp" severity="0" pluginID="34252" pluginName="Remote listeners enumeration (Linux / AIX)" pluginFamily="Service detection">

				<agent>unix</agent>

				<description>Remote listeners enumeration (Sample Description)</description>

				<fname>process_on_port.nasl</fname>

				<plugin_modification_date>2015/06/02</plugin_modification_date>

				<plugin_name>Remote listeners enumeration (Linux / AIX)</plugin_name>

				<plugin_publication_date>2007/05/16</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>1.17</script_version>

				<solution>n/a</solution>

				<synopsis>Using the supplied credentials, it is possible to identify the process listening on the remote port.</synopsis>

				<plugin_output>
  Process id   : 2544
  Executable   : /opt/vmware/sbin/vami-lighttpd
  Command line : /opt/vmware/sbin/vami-lighttpd -f /opt/vmware/etc/lighttpd/lighttpd.conf </plugin_output>

			</ReportItem>
			<ReportItem port="514" svc_name="syslog?" protocol="udp" severity="0" pluginID="34252" pluginName="Remote listeners enumeration (Linux / AIX)" pluginFamily="Service detection">

				<agent>unix</agent>

				<description>Remote listeners enumeration (Sample Description)</description>

				<fname>process_on_port.nasl</fname>

				<plugin_modification_date>2015/06/02</plugin_modification_date>

				<plugin_name>Remote listeners enumeration (Linux / AIX)</plugin_name>

				<plugin_publication_date>2007/05/16</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>1.17</script_version>

				<solution>n/a</solution>

				<synopsis>Using the supplied credentials, it is possible to identify the process listening on the remote port.</synopsis>

				<plugin_output>  Process id   : 2118
  Executable   : /sbin/syslog-ng
  Command line : /sbin/syslog-ng </plugin_output>

			</ReportItem>
		</ReportHost>
		<ReportHost name="192.168.1.2">
			<HostProperties>
				<tag name="Credentialed_Scan">true</tag>
				<tag name="host-ip">192.168.1.2</tag>
				<tag name="host-fq">randomhost2.randomsubdomain.randomdomain</tag>
			</HostProperties>
			<ReportItem port="445" svc_name="cifs" protocol="tcp" severity="0" pluginID="11111" pluginName="Microsoft Windows Remote Listeners Enumeration (WMI)" pluginFamily="Windows">

				<description>WMI (Sample Description)</description>

				<fname>wmi_process_on_port.nbin</fname>

				<plugin_modification_date>2015/08/24</plugin_modification_date>

				<plugin_name>Microsoft Windows Remote Listeners Enumeration (WMI)</plugin_name>

				<plugin_publication_date>2008/09/23</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>$Revision: 1.32 $</script_version>

				<solution>n/a</solution>

				<synopsis>It is possible to obtain the names of processes listening on the remote UDP and TCP ports.</synopsis>

				<plugin_output>
The Win32 process &apos;System&apos; is listening on this port (pid 4).</plugin_output>
			</ReportItem>

			<ReportItem port="49152" svc_name="dce-rpc" protocol="tcp" severity="0" pluginID="11111" pluginName="Microsoft Windows Remote Listeners Enumeration (WMI)" pluginFamily="Windows">

				<description>WMI (Sample Description)</description>

				<fname>wmi_process_on_port.nbin</fname>

				<plugin_modification_date>2015/08/24</plugin_modification_date>

				<plugin_name>Microsoft Windows Remote Listeners Enumeration (WMI)</plugin_name>

				<plugin_publication_date>2008/09/23</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>$Revision: 1.32 $</script_version>

				<solution>n/a</solution>

				<synopsis>It is possible to obtain the names of processes listening on the remote UDP and TCP ports.</synopsis>

				<plugin_output>
The Win32 process &apos;wininit.exe&apos; is listening on this port (pid 488).</plugin_output>

			</ReportItem>

		</ReportHost>
	</Report>
</NessusClientData_v2>
'@

        Set-Content -Path TestDrive:\sample4.nessus -Value  @'
<?xml version="1.0" ?>
<NessusClientData_v2>
	<Policy>
		<policyName>
		</policyName>
		<Preferences>
		</Preferences>
		<FamilySelection>
		</FamilySelection>
		<IndividualPluginSelection>
		</IndividualPluginSelection>
	</Policy>
	<Report name="Test Scan" xmlns:cm="http://wwww.nessus.org/cm">
		<ReportHost name="192.168.1.1">
			<HostProperties>
				<tag name="Credentialed_Scan">true</tag>
				<tag name="host-ip">192.168.1.1</tag>
				<tag name="host-fq">randomhost1.randomsubdomain.randomdomain</tag>
			</HostProperties>
			<ReportItem port="2868" svc_name="npep-messaging?" protocol="tcp" severity="0" pluginID="25221" pluginName="Remote listeners enumeration (Linux / AIX)" pluginFamily="Service detection">

				<agent>unix</agent>

				<description>Remote listeners enumeration (Sample Description)</description>

				<fname>process_on_port.nasl</fname>

				<plugin_modification_date>2015/06/02</plugin_modification_date>

				<plugin_name>Remote listeners enumeration (Linux / AIX)</plugin_name>

				<plugin_publication_date>2007/05/16</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>1.17</script_version>

				<solution>n/a</solution>

				<synopsis>Using the supplied credentials, it is possible to identify the process listening on the remote port.</synopsis>

				<plugin_output>
  Process id   : 2544
  Executable   : /opt/vmware/sbin/vami-lighttpd
  Command line : /opt/vmware/sbin/vami-lighttpd -f /opt/vmware/etc/lighttpd/lighttpd.conf </plugin_output>

			</ReportItem>
			<ReportItem port="514" svc_name="syslog?" protocol="udp" severity="0" pluginID="25221" pluginName="Remote listeners enumeration (Linux / AIX)" pluginFamily="Service detection">

				<agent>unix</agent>

				<description>Remote listeners enumeration (Sample Description)</description>

				<fname>process_on_port.nasl</fname>

				<plugin_modification_date>2015/06/02</plugin_modification_date>

				<plugin_name>Remote listeners enumeration (Linux / AIX)</plugin_name>

				<plugin_publication_date>2007/05/16</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>1.17</script_version>

				<solution>n/a</solution>

				<synopsis>Using the supplied credentials, it is possible to identify the process listening on the remote port.</synopsis>

				<plugin_output>  Process id   : 2118
  Executable   : /sbin/syslog-ng
  Command line : /sbin/syslog-ng </plugin_output>

			</ReportItem>
		</ReportHost>
		<ReportHost name="192.168.1.2">
			<HostProperties>
				<tag name="Credentialed_Scan">false</tag>
				<tag name="host-ip">192.168.1.2</tag>
				<tag name="host-fq">randomhost2.randomsubdomain.randomdomain</tag>
			</HostProperties>
			<ReportItem port="445" svc_name="cifs" protocol="tcp" severity="0" pluginID="34252" pluginName="Microsoft Windows Remote Listeners Enumeration (WMI)" pluginFamily="Windows">

				<description>WMI (Sample Description)</description>

				<fname>wmi_process_on_port.nbin</fname>

				<plugin_modification_date>2015/08/24</plugin_modification_date>

				<plugin_name>Microsoft Windows Remote Listeners Enumeration (WMI)</plugin_name>

				<plugin_publication_date>2008/09/23</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>$Revision: 1.32 $</script_version>

				<solution>n/a</solution>

				<synopsis>It is possible to obtain the names of processes listening on the remote UDP and TCP ports.</synopsis>

				<plugin_output>
The Win32 process &apos;System&apos; is listening on this port (pid 4).</plugin_output>
			</ReportItem>

			<ReportItem port="49152" svc_name="dce-rpc" protocol="tcp" severity="0" pluginID="34252" pluginName="Microsoft Windows Remote Listeners Enumeration (WMI)" pluginFamily="Windows">

				<description>WMI (Sample Description)</description>

				<fname>wmi_process_on_port.nbin</fname>

				<plugin_modification_date>2015/08/24</plugin_modification_date>

				<plugin_name>Microsoft Windows Remote Listeners Enumeration (WMI)</plugin_name>

				<plugin_publication_date>2008/09/23</plugin_publication_date>

				<plugin_type>local</plugin_type>

				<risk_factor>None</risk_factor>

				<script_version>$Revision: 1.32 $</script_version>

				<solution>n/a</solution>

				<synopsis>It is possible to obtain the names of processes listening on the remote UDP and TCP ports.</synopsis>

				<plugin_output>
The Win32 process &apos;wininit.exe&apos; is listening on this port (pid 488).</plugin_output>

			</ReportItem>

		</ReportHost>
	</Report>
</NessusClientData_v2>
'@

        It "should find 4 total ports" {
            $result = Import-NessusOpenPortsPlugin -file (Get-Item TestDrive:\sample.nessus)
            $result[0].Count | Should Be 4
        }

        It "should find 2 plugins with ID 25221 (linux)" {
            $result = Import-NessusOpenPortsPlugin -file (Get-Item TestDrive:\sample.nessus)
            $test = $($result[0] | Where-Object{$_.Plugin -eq 25221})
            $test.Count | Should Be 2
        }

        It "should find 2 plugins with ID 34252 (windows)" {
            $result = Import-NessusOpenPortsPlugin -file (Get-Item TestDrive:\sample.nessus)
            $test = $($result[0] | Where-Object{$_.Plugin -eq 34252})
            $test.Count | Should Be 2
        }

        It "should find 1 system with no open ports" {
            $result = Import-NessusOpenPortsPlugin -file (Get-Item TestDrive:\sample3.nessus)
            $result[1].Count | Should Be 1
        }

        It "should throw No Path Provided" {
            {Import-NessusOpenPortsPlugin} | Should Throw "No File Object Provided"
        }

        It "should throw Not an XML Document" {
            {Import-NessusOpenPortsPlugin -file (Get-Item TestDrive:\anothersample.txt)} | Should Throw "$((Get-Item TestDrive:\anothersample.txt).name) Not an XML Document"
        }

        It "should throw Not a Nessus File" {
            {Import-NessusOpenPortsPlugin -file (Get-Item TestDrive:\sample2.nessus)} | Should Throw "$((Get-Item TestDrive:\sample2.nessus).name) Not a Nessus File"
        }

        It "should throw not a credentialed scan" {
            {Import-NessusOpenPortsPlugin -file (Get-Item TestDrive:\sample4.nessus)} | Should Throw "$((Get-Item TestDrive:\sample4.nessus).name) Not a credentialed Scan"
        }
    }
#}
#Remove-Module $moduleName
