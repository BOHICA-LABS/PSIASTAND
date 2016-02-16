$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Import-CKL PS: $PSVersion" {

    Copy-Item "$Global:testData\CKL\CKLv1\sample.ckl" "TestDrive:\sample.ckl"
    Copy-Item "$Global:testData\CKL\CKLv2\sampleV2.ckl" "TestDrive:\sampleV2.ckl"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should Return an Object v1 (Requires Import-XML)" {
            #$file = Get-Item "TestDrive:\sample.ckl"
            $file = Get-Item $(Join-Path $TestDrive "sample.ckl")
            $xml = Import-XML -fileobj $file
            $Script:ckl = import-ckl -doc $xml
            $Script:ckl -is [object] | Should Be $True
        }

        It "Should have used Stig Viewer Version 1 Format (Requires Import-XML)" {
            $Script:ckl[0].StigViewer_Version | Should Be 1
        }

        It "Should have 331 items v1 (Requires Import-XML)" {
            $Script:ckl.count | Should Be 331
        }

        It "Should have 5 failed items v1 (Requires Import-XML)" {
            $($Script:ckl | Where-Object{$_.status -eq "open"}).count | Should be 5
        }

        It "Should Return an Object v2 (Requires Import-XML)" {
            $file = Get-Item "TestDrive:\sampleV2.ckl"
            $xml = Import-XML -fileobj $file
            $Script:ckl = import-ckl -doc $xml
            $Script:ckl -is [object] | Should Be $True
        }

        It "Should have used Stig Viewer Version 2 Format (Requires Import-XML)" {
            $Script:ckl[0].StigViewer_Version | Should Be 2
        }

        It "Should have 306 items v2 (Requires Import-XML)" {
            $Script:ckl.count | Should Be 306
        }

        It "Should have 0 failed items v2 (Requires Import-XML)" {
            $($Script:ckl | Where-Object{$_.status -eq "open"}) | Should be $null
        }

    }
}
