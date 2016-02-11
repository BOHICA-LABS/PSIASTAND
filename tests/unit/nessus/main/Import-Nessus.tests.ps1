$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Import-Nessus PS: $PSVersion" {

    Copy-Item "$here\Nessus_Sample_Linux.nessus" "TestDrive:\Nessus_Sample_Linux.nessus"
    Copy-Item "$here\Nessus_Sample_Windows.nessus" "TestDrive:\Nessus_Sample_Windows.nessus"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Nessus File (Sample Linux) is an object (Requires Import-XML)" {
            $file = Get-ChildItem -Path "TestDrive:\Nessus_Sample_Linux.nessus"
            $xml = Import-XML -fileobj $file
            $Script:linuxnessus = Import-Nessus -doc $xml
            $Script:linuxnessus -is [Object] | Should be $true
        }

        It "Nessus File (Sample Windows) is an object (Requires Import-XML)" {
            $file = Get-ChildItem -Path "TestDrive:\Nessus_Sample_Windows.nessus"
            $xml = Import-XML -fileobj $file
            $Script:windowsnessus = Import-Nessus -doc $xml
            $Script:windowsnessus -is [Object] | Should be $true
        }

        It "Nessus File (Sample linux) has 3 hosts" {
            $nessushost = $Script:linuxnessus.'host-ip' | sort -Unique
            $nessushost.count | Should be 3
        }

        It "Nessus File (Sample linux) has 61 objects" {
            $Script:linuxnessus.count | Should be 61
        }

        It "Nessus File (Sample linux) has 3 Failed Credentialed Scans" {
            $nessuscred = $Script:linuxnessus | Select-Object 'HOST-IP', 'Credentialed_Scan' | Get-Unique -AsString
            $nessuscred.count | Should Be 3
        }

        It "Nessus File (Sample Windows) has 3 hosts" {
            $nessushost = $Script:windowsnessus.'host-ip' | sort -Unique
            $nessushost.count | Should be 3
        }

        It "Nessus File (Sample Windows) has 168 objects" {
            $Script:windowsnessus.count | Should be 168
        }

        It "Nessus File (Sample Windows) has 3 Failed Credentialed Scans" {
            $nessuscred = $Script:windowsnessus | Select-Object 'HOST-IP', 'Credentialed_Scan' | Get-Unique -AsString
            $nessuscred.count | Should Be 3
        }

    }
}
