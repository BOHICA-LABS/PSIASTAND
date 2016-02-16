function Import-DIACAP {
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
        [Object]$doc = $(Throw "No object provided")
    )

    PROCESS {
        $docColumns = $($doc | Get-Member -MemberType NoteProperty).Name
        if (!($docColumns -contains "Allocated Assessment ID" -and $docColumns -contains "Allocated Control ID" -and $docColumns -contains "Assessed By" -and $docColumns -contains "Assessment Date" -and $docColumns -contains "Assessment Objectives" -and $docColumns -contains "Assessment Status" -and $docColumns -contains "AssessmentObjectiveID" -and $docColumns -contains "Authorization Package" -and $docColumns -contains "Comments" -and $docColumns -contains "Control Implementation Status" -and $docColumns -contains "Control Name" -and $docColumns -contains "Control Number" -and $docColumns -contains "Impact Code" -and $docColumns -contains "Implementation Details" -and $docColumns -contains "Methods Used")) {
            Throw "Sanity Check Failure: Columns are missing from DIACAP Control Doc"
        }
        return $doc
    }
}
