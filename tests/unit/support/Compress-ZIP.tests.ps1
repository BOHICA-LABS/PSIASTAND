$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\openports\$sut"

$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major

Describe "Compress-ZIP PS: $PSVersion" {

    Setup -Dir results
    Setup -File results\sample.txt
    Setup -File results\sample1.txt
    Setup -File results\sample2.txt
    Setup -File results\sample3.txt


    Context "Strict mode" {

        it "Should Throw 'No Source Provided'" {
            {Compress-ZIP} | Should Throw "No Source Provided"
        }

        it "Should Throw 'No destination Provided'" {
            {Compress-ZIP -source TestDrive:\results} | Should Throw "No destination Provided"
        }

        it "Should create a Zip File" {
            Compress-ZIP -source $("$TestDrive\results") -destination $("$TestDrive\test.zip")
            $file = Get-ChildItem -Path "$TestDrive\test.zip"
            $file.name | Should Be "test.zip"
        }

        It "Should Throw 'Already Exist'" {
            {Compress-ZIP -source $("$TestDrive\results") -destination $("$TestDrive\test.zip")} | Should Throw "$($TestDrive)\test.zip Already Exist"
        }
    }
}
