function Import-XML {
<#
.SYNOPSIS
This function loads an XML into an XML object. Can take a string path, a string xml, or a file object

.PARAMETER Path
Path to the XML file

.PARAMETER string
A string Variable version of the XML

.PARAMETER fileobj
A file object Variable version of the XML


.EXAMPLE

.LINK

.VERSION
1.0.0 (02.9.2016)
    -Intial Release

#>

    [CmdletBinding()]
    Param(
        [string]$Path = $null,
        [string]$string = $null,
        [object]$fileobj = $null
    )

    $Private:doc = New-Object System.Xml.XmlDataDocument # This creates a xlm document object

    if($Path){ # Test Path variable
        Try {
            $ErrorActionPreference = 'Stop'
            $Private:doc.Load($Path)
            $ErrorActionPreference = 'Continue'
            return $Private:doc
        }
        Catch {
            $ErrorActionPreference = 'Continue'
            Throw "$($Path) Not an XML Document"
        }
    }

    if($string){ # test string variable
        Try {
            $ErrorActionPreference = 'Stop'
            $Private:doc.LoadXML($string)
            $ErrorActionPreference = 'Continue'
            return $Private:doc
        }
        Catch {
            $ErrorActionPreference = 'Continue'
            Throw "Not an XML Document"
        }
    }

    if($fileobj){ # test string variable
        Try {
            $ErrorActionPreference = 'Stop'
            $Private:doc.Load($fileobj.fullname)
            $ErrorActionPreference = 'Continue'
            return $Private:doc
        }
        Catch {
            $ErrorActionPreference = 'Continue'
            Throw "$($fileobj.name) Not an XML Document"
        }
    }
    Throw "no path, string, or fileobj provided"
}
