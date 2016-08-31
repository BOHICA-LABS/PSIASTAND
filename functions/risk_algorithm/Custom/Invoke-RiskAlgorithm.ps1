function Invoke-RiskAlgorithm {
<#
.SYNOPSIS

.PARAMETER risk

.PARAMETER map

.PARAMETER docrisk

.PARAMETER sysrisk

.PARAMETER output

.PARAMETER name

.EXAMPLE

.LINK

.VERSION
1.0.0 (02.17.2016)
    -Intial Release
1.0.1 (05.23.2016)
	-Corrected a bug that Could cause system
	object to be displayed in the output due to
	multiple values found in the Risk-mapper xlsx
1.0.2 (08.29.2016)
    -Removed the logic that checks for more then 1 item
    from the Risk-Mapper.  Duplicates should be handled
    before this point via data validation.  If multiple
    items are passed through the script will choose the
    first object.
1.0.2.1 (08.31.2016)
    -Removed Whitespace
#>

    [CmdletBinding()]
    Param(
        [string]$risk = $(Throw "No RISK Path provided"),
        [string]$map = $(Throw "No MAP provided"),
        [int]$docrisk = $(Throw "No Documentation level provided"),
        [int]$sysrisk = $(Throw "No System Knowledge level provided"),
        [string]$output = $(Throw "No Output folder provided"),
        [String]$name = $(Throw "No Name provided")
    )

    BEGIN {
        $VeryHighweight = 0.5
        $Highweight = 0.25
        $Mediumweight = 0.15
        $lowweight = 0.09
        $verylowweight = 0.01

        $tech = 0.50
        $docu = 0.40
        $sysKno = 0.10

        if ($docrisk -gt 100 -or $docrisk -lt 0 -or $sysrisk -gt 100 -or $sysrisk -lt 0) {Throw "System Knowledge risk or Documentation risk falls outside of 0-100"}
        if(!(Test-Path -Path $risk)){Throw "Risk path does not exist"}
        if(!(Test-Path -Path $map)){Throw "Map path does not exist"}
        $riskelements = Import-XLSX -Path $risk
        $riskmap = Import-XLSX -Path $map
        $riskmapnamelist = $(($riskmap | Select name).name)
        foreach ($element in $riskelements) {
            if (!($riskmapnamelist -contains $($element.name))) {
                Throw "$($element.name) is not mapped"
            }
        }
        foreach ($element in $riskelements) {
            $mapping = $riskmap | Where-Object { $_.Name -eq $($element.name) }
            # IF mapping found more than 1 assigned first found
            #if($mapping -gt 1){$mapping = $mapping[0]}
            $mapping = $mapping[0]
            $element."Assessed Risk Level" = $($mapping."Assessed Risk Level")
            $element."Quantitative Values" = $($mapping."Quantitative Values")
        }
        $VeryHigh = $riskelements | Where-Object {$_."Assessed Risk Level" -eq "Very High"}
        $High = $riskelements | Where-Object {$_."Assessed Risk Level" -eq "High"}
        $Medium = $riskelements | Where-Object {$_."Assessed Risk Level" -eq "Medium"}
        $Low = $riskelements | Where-Object {$_."Assessed Risk Level" -eq "Low"}
        $VeryLow = $riskelements | Where-Object {$_."Assessed Risk Level" -eq "Very Low"}

        if ($VeryHigh) {
            $VeryHighCount = $VeryHigh.count
            $num = $VeryHigh."Quantitative Values"
            $VeryHighAVG = Get-Average -array $num
        }
        else {
            $VeryHighCount = 0
            $VeryHighAVG = 0
        }
        if ($High) {
            $HighCount = $High.count
            $num = $High."Quantitative Values"
            $HighAVG = Get-Average -array $num
        }
        else {
            $HighCount = 0
            $HighAVG = 0
        }
        if ($Medium) {
            $MediumCount = $Medium.count
            $num = $Medium."Quantitative Values"
            $MediumAVG = Get-Average -array $num
        }
        else {
            $MediumCount = 0
            $MediumAVG = 0
        }
        if ($Low) {
            $LowCount = $Low.Count
            $num = $Low."Quantitative Values"
            $LowAVG = Get-Average -array $num
        }
        else {
            $LowCount = 0
            $LowAVG = 0
        }
        if ($VeryLow) {
            $VeryLowCount = $VeryLow.Count
            $num = $VeryLow."Quantitative Values"
            $VeryLowAVG = Get-Average -array $num
        }
        else {
            $VeryLowCount = 0
            $VeryLowAVG = 0
        }
    }
    PROCESS {
        $results = ($results = " " | select-object "Technical Review", "Overall Documentation", "Knowledge of the System", "VERY HIGH", "HIGH", "MEDIUM", "LOW", "VERY LOW", "AVG VERY HIGH", "AVG HIGH", "AVG MEDIUM", "AVG LOW", "AVG VERY LOW", "Quantitative Value", "Risk Level")
        $results."Technical Review" = $(($VeryHighAVG * $VeryHighweight) + ($HighAVG * $Highweight) + ($MediumAVG * $Mediumweight) + ($LowAVG * $lowweight) + ($VeryLowAVG * $verylowweight))
        $results."Overall Documentation" = $docrisk
        $results."Knowledge of the System" = $sysrisk
        $results."VERY HIGH" = $VeryHighCount
        $results."HIGH" = $HighCount
        $results."MEDIUM" = $MediumCount
        $results."LOW" = $LowCount
        $results."VERY LOW" = $VeryLowCount
        $results."AVG VERY HIGH" = $VeryHighAVG
        $results."AVG HIGH" = $HighAVG
        $results."AVG MEDIUM" = $MediumAVG
        $results."AVG LOW" = $LowAVG
        $results."AVG VERY LOW" = $VeryLowAVG
        $results."Quantitative Value" = $(($results."Technical Review" * $tech) + ($results."Overall Documentation" * $docu) + ($results."Knowledge of the System" * $sysKno))
        $results."Risk Level" = $(if($results."Quantitative Value" -gt 67){"HIGH"}elseif($results."Quantitative Value" -lt 68 -and $results."Quantitative Value" -gt 32){"MEDIUM"}else{"LOW"})
    }
    END {
        Export-XLSX -Path "$($output)\$($name)_Risk_Algorithm_Report.xlsx" -InputObject $results
        Export-XLSX -Path "$($output)\$($name)_Risk_Report.xlsx" -InputObject $riskelements
    }
}

#Invoke-RiskAlgorithm -risk "C:\Users\josh\Google Drive\Work\modules\custom\PSIASTAND\tests\data\Mock_APP\APP_OWNER_Risk.xlsx" -map "C:\Users\josh\Google Drive\Work\modules\custom\PSIASTAND\tests\data\Risk_Mapping\Sample_Risk_Map.xlsx" -docrisk 45 -sysrisk 45 -output "C:\Users\josh\Google Drive\Work\modules\custom\PSIASTAND\tests\data" -name "APP_OWNER"
