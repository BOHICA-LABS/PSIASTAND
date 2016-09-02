function Export-Tracker {
<#
.SYNOPSIS
This function exports a ckl object to a csv tracker  file

.PARAMETER Object
    ckl object loaded  from import-ckl

.PARAMETER exportlocation
    export location for the file

.EXAMPLE

.LINK

.VERSION
1.0.0 (09.02.2016)
    Initial release

#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [object]$object,
        [Parameter(Mandatory=$false)]
        [string]$exportlocation
    )

    foreach($row in $object) {
        
        write-host $row
    }

}

Export-Tracker -object $ckl -exportlocation .\test.csv

#$file = Get-item .\tests\data\CKL\CKLv2\sampleV2.ckl
#$xml = import-xml -fileobj $file
#$ckl = import-ckl -doc $xml