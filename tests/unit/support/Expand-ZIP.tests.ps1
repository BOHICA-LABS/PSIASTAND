$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Expand-ZIP PS: $PSVersion" {

    Setup -Dir results
    #Setup -Dir expand
    Setup -File results\sample.txt
    Setup -File results\sample1.txt
    Setup -File results\sample2.txt
    Setup -File results\sample3.txt

    Compress-ZIP -source $("$TestDrive\results") -destination $("$TestDrive\test.zip")


    Context "Strict mode" {

        it "Should Throw 'No Source Provided'" {
            {Expand-ZIP} | Should Throw "No Source Provided"
        }

        it "Should Throw 'No destination Provided'" {
            {Expand-ZIP -source $("$TestDrive\test.zip")} | Should Throw "No destination Provided"
        }

        it "Should extract a Zip File (Requires Compress-ZIP)" {
            Expand-ZIP -source $("$TestDrive\test.zip") -destination $("$TestDrive\expand")
            $file = Get-ChildItem -Path "$TestDrive\expand"
            $file.count | Should Be 4
        }

        It "Should Throw 'Already Exist'" {
            {Expand-ZIP -source $("$TestDrive\test.zip") -destination $("$TestDrive\expand")} | Should Throw "$($TestDrive)\expand Already Exist"
        }
    }
}
