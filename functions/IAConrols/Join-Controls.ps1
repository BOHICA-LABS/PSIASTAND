function Join-Controls {
<#
.SYNOPSIS

.PARAMETER doc

.EXAMPLE

.LINK

.VERSION
1.0.0 (02.15.2016)
    -Intial Release
#>

    [CmdletBinding()]
    Param(
        [Object]$controls = $(Throw "No object provided"),
        [object]$CKL = $(Throw "No object provided"),
        [switch]$DIACAP,
        [switch]$RMF
    )

    PROCESS {
        if ($DIACAP) {
            $foundFailedControls = $($ckl | Select IA_Controls -Unique | ForEach-Object {$_.IA_COntrols -replace '\s', ''})
            if ($foundFailedControls.count -lt 1) {
                Throw "Merge Selected but found nothing to merge"
            }
            foreach($control in $controls){
                foreach ($failedcon in $foundFailedControls) {
                    #Write-Host "$($failedcon)  $($control.'control number')"
                    if($failedcon.split(",") -contains $($control."control number").trim()){
                        #Write-Host "$($failedcon)  $($control.'control number')"
                        if($control."Assessment Status" -match "Pass"){
                            $control."Assessment Status" = "Fail"
                            $control.Comments = "Various STIG items whose Rule ID's Map to this IA Control Number have failed. Please reference the report exports and the Test Plan for further details."
                        }
                    }
                }
            }
            return $controls
        }
        if ($RMF) { # Place Holder
        }
    }
}

#$diacapxlsx = Import-XLSX -Path "C:\Users\josh\Google Drive\Work\modules\custom\PSIASTAND\tests\data\Controls\Sample_DODI_8500_2_Controls.xlsx"
#$controls = Import-DIACAP -doc $diacapxlsx
#$file = Get-Item -Path "C:\Users\josh\Google Drive\Work\modules\custom\PSIASTAND\tests\data\CKL\CKLv1\Sample04_Win2008R2MS.ckl"
#$cklxml = Import-XML -fileobj $file
#$cklfile = Import-CKL -doc $cklxml
#$filteredCKL = $cklfile | Where-Object{$_.Status -eq "Open"}
#compressedCKL = Compress-Report -Report $filteredCKL -CKL
#$finalControls = Join-Controls -Controls $controls -CKL $compressedCKL -DIACAP
