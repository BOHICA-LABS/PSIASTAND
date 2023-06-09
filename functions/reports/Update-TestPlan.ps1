﻿function Update-TestPlan {
<#
.SYNOPSIS

.PARAMETER CKL

.PARAMETER testplan

.PARAMETER Output

.PARAMETER name

.PARAMETER recursive

.EXAMPLE

.LINK

.VERSION
1.0.1 (02.19.2016)
    - Added -replace "r\d+_rule" to strip r#_rule from rule ID. This portion of the rule ID details the revision of the rule and due
        to MCCAST being behind on import the STIGS this will cause Items to not match

1.0.0 (02.16.2016)
    -Intial Release
#>

    [CmdletBinding()]
    Param(
        [string]$ckl = $(Throw "No CKL Path provided"),
        [string]$testplan = $(Throw "No Testplan provided"),
        [string]$output = $(Throw "No Output folder provided"),
        [String]$name = $(Throw "No Name provided"),
        [int]$version = 1,
        [switch]$recursive
    )

    BEGIN {
        if ($recursive) {
            if(!(Test-Path -Path $ckl)) {Throw "CKL Path not found"}
            $cfiles = Get-ChildItem -Path $ckl -Filter "*.ckl" -Recurse
            if ($cfiles.count -lt 1) {Throw "No CKL files found"}
        }
        else {
            if(!(Test-Path -Path $ckl)) {Throw "CKL Path not found"}
            $cfiles = Get-ChildItem -Path $ckl -Filter "*.ckl"
            if ($cfiles.count -lt 1) {Throw "No CKL files found"}
        }
        if(!(Test-Path -Path $testplan)) {Throw "Testplan not found"}
        else {$testplanimport = Import-XLSX -Path $testplan}
        if ($testplanimport.count -lt 1) {Throw "Testplan count is less than 1. Please check testplan"}
    }
    PROCESS {
        Try {
            $compiledCKLObj = @()
            foreach ($file in $cfiles) { # Process CKL Files
                $xml = Import-XML -fileobj $file
                $cklfile = Import-CKL -doc $xml
                $compiledCKLObj += $cklfile
            } # End For loop
        }
        Catch{
            Throw "$($file.name) CKL failed to process"
            exit
        }
        #$((($current | Select AssetName -Unique).AssetName))
        $cklversion = $($compiledCKLObj | Select-Object StigViewer_Version -Unique).StigViewer_Version
        switch ($cklversion) {
            1 {
                #Try {
                    #$listofassets = $((($testplanimport | Select "Hardware Name" -Unique)."Hardware Name") | ForEach-Object {$_.trim()}) # for Later use
                    $listofimportassets = $((($compiledCKLObj | Select "AssetName" -Unique)."AssetName") | ForEach-Object {$_.trim()})
                    foreach ($assetname in $listofimportassets) {
                        $findings = $($compiledCKLObj | Where-Object {$_."AssetName" -match $assetname})
                        $importlist = $($testplanimport | Where-Object {$_."Hardware Name" -match $assetname})
                        foreach ($finding in $findings) {
                            $rowintestplan = $importlist | Where-Object {$_."Rule ID" -match $(($finding.Rule_ID) -replace "r\d+_rule")}
                            if ($rowintestplan) {
                                $rowintestplan."Implementation Result" = $(if($finding.STATUS -match "NotAfinding"){"Pass"}elseif($finding.STATUS -match "open"){"Fail"}else{$($finding.STATUS)})
                                $rowintestplan."Implementer Comments" = $($finding.FINDING_DETAILS)
                            }
                        }
                    }
                #}
            #Catch {
            #}

            }
            2 {
                $listofimportassets = $((($compiledCKLObj | Select "Host_Name" -Unique)."Host_Name") | ForEach-Object {$_.trim()})
                foreach ($assetname in $listofimportassets) {
                    $findings = $($compiledCKLObj | Where-Object {$_."Host_Name" -match $assetname})
                    $importlist = $($testplanimport | Where-Object {$_."Hardware Name" -match $assetname})
                    foreach ($finding in $findings) {
                        $rowintestplan = $importlist | Where-Object {$_."Rule ID" -match $(($finding.Rule_ID) -replace "r\d+_rule")}
                        if ($rowintestplan) {
                            $rowintestplan."Implementation Result" = $(if($finding.STATUS -match "NotAfinding"){"Pass"}elseif($finding.STATUS -match "open"){"Fail"}else{$($finding.STATUS)})
                            $rowintestplan."Implementer Comments" = $($finding.FINDING_DETAILS)
                        }
                    }
                }
            }
        }
    }
    END {
        Export-XLSX -Path "$($output)\$($name)_TestPlan.xlsx" -InputObject $testplanimport
    }
}

#Update-TestPlan -ckl "C:\Users\josh\Google Drive\Work\modules\custom\PSIASTAND\tests\data\CKL\CKLv1" -testplan "C:\Users\josh\Google Drive\Work\modules\custom\PSIASTAND\tests\data\MCCAST_TestPlan\MCCAST_TestPlan.xlsx" -output "C:\Users\josh\Google Drive\Work\modules\custom\PSIASTAND\tests\data" -name "APP_OWNER" -version 1
