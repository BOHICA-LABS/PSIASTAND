$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$moduleName = 'PSIASTAND'
$root = "$here\..\..\..\..\"

# Module Checks
#Import-Module "$here\..\..\..\..\$($moduleName)"
Describe -tag 'Invoke-NessusOpenPorts' "Invoke-NessusOpenPorts" {
        Setup -File sample.nessus
        Setup -File anothersample.nessus
        Setup -File sample2.nessus
        Setup -File sample3.nessus
        Setup -File sample4.nessus

        Setup -Dir Test

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
		<ReportHost name="192.168.1.3">
			<HostProperties>
				<tag name="Credentialed_Scan">true</tag>
				<tag name="host-ip">192.168.1.3</tag>
				<tag name="host-fq">randomhost3.randomsubdomain.randomdomain</tag>
			</HostProperties>
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
    $dateObject = new-object system.globalization.datetimeformatinfo
    $date = Get-Date

    It "[End Block] should create a csv export" {
        Invoke-NessusOpenPorts -Nessus TestDrive:\sample.nessus -packagename "Test" -outPut TestDrive:\
        $report = Get-Item -Path "TestDrive:\Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
        $report.name | Should Be "Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
    }

    It "[End Block] csv should have 4 total detected open ports" {
        Invoke-NessusOpenPorts -Nessus TestDrive:\sample.nessus -packagename "Test" -outPut TestDrive:\
        $report = Import-Csv -Path "TestDrive:\Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
        $report.Count | Should Be 4
    }

    It "[End Block] csv should find 2 plugins with ID 25221 (linux)" {
        Invoke-NessusOpenPorts -Nessus TestDrive:\sample.nessus -packagename "Test" -outPut TestDrive:\
        $report = Import-Csv -Path "TestDrive:\Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
        $test = $report | Where-Object{$_.Plugin -eq 25221}
        $test.Count | Should Be 2
    }

    It "[End Block] csv should find 2 plugins with ID 34252 (windows)" {
        Invoke-NessusOpenPorts -Nessus TestDrive:\sample.nessus -packagename "Test" -outPut TestDrive:\
        $report = Import-Csv -Path "TestDrive:\Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
        $test = $report | Where-Object{$_.Plugin -eq 34252}
        $test.Count | Should Be 2
    }

    It "[End Block] csv should find 2 unique hosts" {
        Invoke-NessusOpenPorts -Nessus TestDrive:\sample.nessus -packagename "Test" -outPut TestDrive:\
        $report = Import-Csv -Path "TestDrive:\Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
        $test = $report | %{$_.IP} | Get-Unique
        $test.Count | Should Be 2
    }

    It "[End Block] should create a no open ports report" {
        Invoke-NessusOpenPorts -Nessus TestDrive:\sample.nessus -packagename "Test" -outPut TestDrive:\
        $report = Get-Item -Path "TestDrive:\Test_NoOpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
        $report.name | Should Be "Test_NoOpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
    }

    It "[End Block] should have 1 system in no open ports report" {
        Invoke-NessusOpenPorts -Nessus TestDrive:\sample.nessus -packagename "Test" -outPut TestDrive:\
        $report = Import-Csv -Path "TestDrive:\Test_NoOpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
        $report.("#text") | Should Be "192.168.1.3"
    }

    It "[Begin Block] should throw unable to create at provided path" {
        {Invoke-NessusOpenPorts -Nessus TestDrive:\sample.nessus -packagename "Test" -outPut TempDrive:\} | Should Throw "unable to create at provided path: TempDrive:\"
    }

    It "[Begin Block] should throw path not found" {
        {Invoke-NessusOpenPorts -Nessus TempDrive:\sample.nessus -packagename "Test" -outPut TestDrive:\} | Should Throw "path not found"
    }

    It "[Begin Block] should throw path not found (Recursive)" {
        {Invoke-NessusOpenPorts -Nessus TempDrive:\ -packagename "Test" -outPut TestDrive:\ -recursive} | Should Throw "path not found"
    }

    It "[Begin Block] should throw No Nessus Files Found" {
        {Invoke-NessusOpenPorts -Nessus TestDrive:\Test -packagename "Test" -outPut TestDrive:\ -recursive} | Should Throw "No Nessus Files Found"
    }

    It "[Process Block] should throw Not an XML Document" {
        {Invoke-NessusOpenPorts -Nessus TestDrive:\anothersample.nessus -packagename "Test" -outPut TestDrive:\} | Should Throw "$((Get-Item TestDrive:\anothersample.nessus).name) Not an XML Document"
    }

    It "[Process Block] should throw Not a Nessus File" {
        {Invoke-NessusOpenPorts -Nessus TestDrive:\sample2.nessus -packagename "Test" -outPut TestDrive:\} | Should Throw "$((Get-Item TestDrive:\sample2.nessus).name) Not a Nessus File"
    }

    It "[Process Block] should throw Not a credentialed Scan" {
        {Invoke-NessusOpenPorts -Nessus TestDrive:\sample4.nessus -packagename "Test" -outPut TestDrive:\} | Should Throw "$((Get-Item TestDrive:\sample4.nessus).name) Not a credentialed Scan"
    }
}
#Remove-Module $moduleName

#Invoke-NessusOpenPorts
