<#
    .Description
    Test CVSS v2 Powershell.
    .NOTES
    Test Still need to be built to insure input validation is working
    .Version
    1.0.0.0
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$modroot = "..\..\..\..\PSIASTAND.psd1"

$moduleName = 'PSIASTAND'
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -tag 'New-CVSS2' "New-CVSS2 PS: $PSVersion"{
  Context 'Strict Mode'{
    # Enable Strict Mode in Powershell
    Set-StrictMode -Version latest

    # Create the CVSSv2 Object
    $CVSSobj = New-CVSS2

    it "CVE-2002-0392 Vector String 'CVSS:2.0/AV:N/AC:L/AU:N/C:N/I:N/A:C/E:F/RL:OF/RC:C/CDP:H/TD:H/CR:M/IR:M/AR:H' tested Correctly"{
      $response = $CVSSobj.calculateCVSSFromVector("CVSS:2.0/AV:N/AC:L/AU:N/C:N/I:N/A:C/E:F/RL:OF/RC:C/CDP:H/TD:H/CR:M/IR:M/AR:H")
      $response.baseSeverity | Should be "High"
      $response.baseMetricScore | Should be 7.8
      $response.temporalSeverity | Should be "Medium"
      $response.temporalMetricScore | Should be 6.4
      $response.environmentalSeverity | Should be "Critical"
      $response.environmentalMetricScore | Should be 9.2
    }

    it "CVE-2003-0818 Vector String 'CVSS:2.0/AV:N/AC:L/AU:N/C:C/I:C/A:C/E:F/RL:OF/RC:C/CDP:H/TD:H/CR:M/IR:M/AR:M' tested Correctly"{
      $response = $CVSSobj.calculateCVSSFromVector("CVSS:2.0/AV:N/AC:L/AU:N/C:C/I:C/A:C/E:F/RL:OF/RC:C/CDP:H/TD:H/CR:M/IR:M/AR:M")
      $response.baseSeverity | Should be "Critical"
      $response.baseMetricScore | Should be 10.0
      $response.temporalSeverity | Should be "High"
      $response.temporalMetricScore | Should be 8.3
      $response.environmentalSeverity | Should be "Critical"
      $response.environmentalMetricScore | Should be 9.2
    }

    it "CVE-2003-0062 Vector String 'CVSS:2.0/AV:L/AC:H/AU:N/C:C/I:C/A:C/E:POC/RL:OF/RC:C/CDP:L/TD:L/CR:M/IR:M/AR:M' tested Correctly"{
      $response = $CVSSobj.calculateCVSSFromVector("CVSS:2.0/AV:L/AC:H/AU:N/C:C/I:C/A:C/E:POC/RL:OF/RC:C/CDP:L/TD:L/CR:M/IR:M/AR:M")
      $response.baseSeverity | Should be "Medium"
      $response.baseMetricScore | Should be 6.2
      $response.temporalSeverity | Should be "Medium"
      $response.temporalMetricScore | Should be 4.9
      $response.environmentalSeverity | Should be "Low"
      $response.environmentalMetricScore | Should be 1.4
    }
  }
}
