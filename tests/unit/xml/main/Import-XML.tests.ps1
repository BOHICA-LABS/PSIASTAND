$here = Split-Path -Parent $MyInvocation.MyCommand.Path
#$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\main\$sut"


$moduleName = "PSIASTAND"

$PSVersion = $PSVersionTable.PSVersion.Major

#Import-Module "$here\..\..\..\..\$($moduleName)"

Describe -tag 'Import-XML' "Import-XML PS: $PSVersion"{

    Setup -File sample.xml
    Setup -File failsample.xml
    Set-Content -Path TestDrive:\sample.xml -Value @'
<?xml version="1.0" ?>
<note>
    <to>Tove</to>
    <from>Jani</from>
    <heading>Reminder</heading>
    <body>Dont forget me this weekend</body>
</note>
'@

    Set-Content -Path TestDrive:\failsample.xml -Value @'
hello
there
this
is
a
test
'@

    Context 'Strict mode' {



        Set-StrictMode -Version latest

        It "Should Throw 'no path, string, or fileobj provided'" {
            {Import-XML} | Should Throw "no path, string, or fileobj provided"
        }

        It "Should Throw 'Not an XML Document' using the Path Method" {
            {Import-XML -Path $(Get-item TestDrive:\failsample.xml).fullname} | Should Throw "$($(Get-item TestDrive:\failsample.xml).fullname) Not an XML Document"
        }

        It "Should Throw 'Not an XML Document' using the String Method" {
            {Import-XML -string $($(Get-content -path TestDrive:\failsample.xml) -join "")} | Should Throw "Not an XML Document"
        }

        It "Should Throw 'Not an XML Document' using the fileobj Method" {
            {Import-XML -fileobj $(Get-item TestDrive:\failsample.xml)} | Should Throw "$($(Get-item TestDrive:\failsample.xml).name) Not an XML Document"
        }

        It "Should return an XML Object using the Path Method" {
            $xml = Import-XML -Path $(Get-item TestDrive:\sample.xml).fullname
            $xml -is [System.Xml.XmlDataDocument] | Should Be $true
        }

        It "Should return an XML Object using the string Method" {
            $xml = Import-XML -string $($(Get-content -path TestDrive:\sample.xml) -join "")
            $xml -is [System.Xml.XmlDataDocument] | Should Be $true
        }

        It "Should return an XML Object using the fileobj Methon" {
            $xml = Import-XML -fileobj $(Get-item TestDrive:\sample.xml)
            $xml -is [System.Xml.XmlDataDocument] | Should Be $true
        }

    }
}

#Remove-Module $moduleName
