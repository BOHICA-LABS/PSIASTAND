$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -Tag "FlowRisk" "Flow Risk Assesment: $PSVersion" {

    Setup -Dir "nessus"

    Setup -File "nessus\Nessus_Sample.nessus"
    Set-Content -Path TestDrive:\nessus\Nessus_Sample.nessus -Value @'
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
    setup -Dir "Trackers"
    Setup -Dir "controls"
    Copy-Item -Path "$Global:testData\Trackers\Sample04_Win2008R2MS.csv" -Destination "TestDrive:\trackers\Sample_Win2008R2MS1.csv"
    Copy-Item -Path "$Global:testData\Trackers\Sample05_Win2008R2MS.xlsx" -Destination "TestDrive:\trackers\Sample_Win2008R2MS2.xlsx"
    Copy-Item "$Global:testData\Controls\Sample_DODI_8500_2_Controls.xlsx" -Destination "TestDrive:\Controls\Sample_DODI_8500_2_Controls.xlsx"

    Setup -Dir "results"
    Setup -Dir "results\ckl"
    Setup -Dir "results\nessus"
    Setup -Dir "results\combinedreports"
    Setup -Dir "results\testplan"

    $dateObject = new-object system.globalization.datetimeformatinfo
    $date = Get-Date


    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Invoke-NessusOpenPorts Should create a nessus Listen Ports CSV Report" {
            Invoke-NessusOpenPorts -Nessus "TestDrive:\nessus\Nessus_Sample.nessus" -packagename "Test" -output "TestDrive:\results\nessus"
            $report = Get-Item -Path "TestDrive:\results\nessus\Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
            $report.name | Should Be "Test_OpenPorts_$($date.Day)$($dateObject.GetMonthName($date.Month))$($date.Year).csv"
        }

        It "Export-CKL Should create 2 CKLv2 files" {
            Export-CKL -Path "$($TestDrive)\trackers" -Out "$($TestDrive)\results\ckl" -version 2
            $files = Get-ChildItem -Path "TestDrive:\results\ckl\" -Filter "*.ckl"
            $files.count | Should be 2
        }

        It "Export-CombinedReports should create 2 xls" {
            Export-CombinedReports -CKLFILES "$($TestDrive)\results\ckl" -Nessus "$($TestDrive)\nessus\Nessus_Sample.nessus" -output "$($TestDrive)\results\combinedreports" -name "Test" -xlsx
            $reportfile = Get-ChildItem -Path 'TestDrive:\results\combinedreports'
            $reportfile.count | Should Be 2
            $reportfile[0].extension | should be '.xlsx'
        }

        It "Update-Controls" {
            Update-Controls -path "$($testDrive)\controls\Sample_DODI_8500_2_Controls.xlsx" -ckl "$($testDrive)\results\ckl" -output "$($testDrive)\results" -name "APP_OWNER" -diacap

        }

        It "Update-TestPlan" {
            #Update-TestPlan -ckl "$($TestDrive)\results\ckl" -testplan "C:\testplan\testplan.xlsx" -output "C:\results\testplan" -name "Test" -version 2

        }
        write-host "test"
    }

}