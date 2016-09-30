<#
    .Description
    If this test fails, it could be a timing issue. Try changing the delay and run times
    .Version
    1.0.0.0
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$modroot = "..\..\..\..\PSIASTAND.psd1"

$moduleName = 'PSIASTAND'
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "New-CVSS2 PS: $PSVersion"{
  Context 'Strict Mode'{
    # Enable Strict Mode in Powershell
    Set-StrictMode -Version latest
    
    # Create the CVSSv2 Object
    $CVSSobj = New-CVSS2
    
    it "Vector String 'CVSS:2.0/AV:N/AC:L/AU:N/C:N/I:N/A:N/E:F/RL:OF/RC:C/CDP:H/TD:H/CR:M/IR:M/AR:H' tested Correctly"{
      $response = $CVSSobj.calculateCVSSFromVector("CVSS:2.0/AV:N/AC:L/AU:N/C:N/I:N/A:N/E:F/RL:OF/RC:C/CDP:H/TD:H/CR:M/IR:M/AR:H")
                                                    #CVSS:2.0/AV:N/AC:L/AU:N/C:N/I:N/A:C/E:F/RL:OF/RC:C/CDP:H/TD:H/CR:M/IR:M/AR:H
      $response.baseSeverity | Should be "High"
      $response.baseMetricScore | Should be 7.8
      $response.temporalSeverity | Should be "Medium"
      $response.temporalMetricScore | Should be 6.4
      $response.environmentalSeverity | Should be "Critical"
      $response.environmentalMetricScore | Should be 9.2
    }
    
    
  }
}