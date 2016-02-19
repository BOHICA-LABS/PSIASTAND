function Export-CKL {
<#
.SYNOPSIS
This Script takes our trackers and converts them to CKL files

.PARAMETER Path
Path to the STIG Viewer Export (CSV or XLSX) file. Do not end the path with a \
The files located at the path need to be specially formated following the IVV Process
Created by Joshua Magady

.PARAMETER Out
Path to place the generated CKL

.PARAMETER version
the version of ckl we want to create

.PARAMETER Recursive
switch to indicate if we want to travers all the child directorys


.EXAMPLE
Export-CKL -Path C:\files -Out C:\Results -Version 1

Export-CKL -Path C:\files -Out C:\Results -Version 1 -Recursive

Export-CKL -Path C: -Out C:\Results -Version 1 -Recursive

.LINK

.VERSION
1.0.0 (02.10.2016)
    -Intial Release

#>

    [CmdletBinding()]
    Param(
        [string]$Path = $(Throw "No Path provided"),
        [string]$Out = $(Throw "No output path provided"),
        [int]$version = $(Throw "No Version provided"),
        [switch]$Recursive
    )

    BEGIN {
        if ($version -eq 1){ # Needs to be updated to support version 2 of the STIG Viewer
            $stigViewerVersion = "DISA STIG Viewer : 1.2.0"
            $headMappers = [ordered]@{ # Change the value of the hastable key values to match the headers of the sheet your importing # Maybe needed [ordered]
                "Vuln_Num"="Vuln ID"
                "Severity"="Severity"
                "Group_Title"="Group Title"
                "Rule_ID"="Rule ID"
                "Rule_Ver"="STIG ID"
                "Rule_Title"="Rule Title"
                "Vuln_Discuss"="Discussion"
                "IA_Controls"="IA Controls"
                "Check_Content"="Check Content"
                "Fix_Text"="Fix Text"
                "False_Positives"="False Positives"
                "False_Negatives"="False Negatives"
                "Documentable"="Documentable"
                "Mitigations"="Mitigations"
                "Potential_Impact"="Potential Impact"
                "Third_Party_Tools"="Third Party Tools"
                "Mitigation_Control"="Mitigation Control"
                "Responsibility"="Responsibility"
                "Security_Override_Guidance"="Severity Override Guidance"
                "Check_Content_Ref"="Check Content Reference"
                "Class"="Classification"
                "STIGRef"="STIG"
                "TargetKey"="VMS Asset Posture"
                # "CCI_REF"="CCI Data"  -- Removed this Attribute
                "STATUS"="Status"
                # These Below can be equal to $null
                "FINDING_DETAILS"="Notes"
                "COMMENTS"= "Comments"
                "SEVERITY_OVERRIDE"= "Severity Override"
                "SEVERITY_JUSTIFICATION"= "Severity Override Justification"
            }
        }
        Else{
            $stigViewerVersion = "DISA STIG Viewer : 1.2.0"
            $headMappers = [ordered]@{ # Change the value of the hastable key values to match the headers of the sheet your importing # Maybe needed [ordered]
                "Vuln_Num"="Vuln ID"
                "Severity"="Severity"
                "Group_Title"="Group Title"
                "Rule_ID"="Rule ID"
                "Rule_Ver"="STIG ID"
                "Rule_Title"="Rule Title"
                "Vuln_Discuss"="Discussion"
                "IA_Controls"="IA Controls"
                "Check_Content"="Check Content"
                "Fix_Text"="Fix Text"
                "False_Positives"="False Positives"
                "False_Negatives"="False Negatives"
                "Documentable"="Documentable"
                "Mitigations"="Mitigations"
                "Potential_Impact"="Potential Impact"
                "Third_Party_Tools"="Third Party Tools"
                "Mitigation_Control"="Mitigation Control"
                "Responsibility"="Responsibility"
                "Security_Override_Guidance"="Severity Override Guidance"
                "Check_Content_Ref"="Check Content Reference"
                "Class"="Classification"
                "STIGRef"="STIG"
                "TargetKey"="VMS Asset Posture"
                # "CCI_REF"="CCI Data"  -- Removed this Attribute
                "STATUS"="Status"
                # These Below can be equal to $null
                "FINDING_DETAILS"="Notes"
                "COMMENTS"= "Comments"
                "SEVERITY_OVERRIDE"= "Severity Override"
                "SEVERITY_JUSTIFICATION"= "Severity Override Justification"
            }
        }
    }
    PROCESS {
        if ($Recursive) {
            $Private:files = Get-ChildItem -Path "$($Path)\*" -Include "*.xlsx","*.csv" -Recurse # Get files recursively
        }
        Else {
            $Private:files = Get-ChildItem -Path "$($Path)\*" -Include "*.xlsx","*.csv" # get files non recursively
        }
    }
    END {
        if (!$Private:files) {
            Throw "No Files Found"
        }
        foreach ($Private:file in $Private:files) { # Loop through the found files
            $Private:filehostname = $($Private:file.name).split("_")[0] # Pull hostname from the file (Requires the file to be name <hostname>_<STIG NAME>.<csv or xlsx>)
            $Private:filename = "$($($Private:file.name).Split(".")[0]).ckl" # Create new file name
            if($file.extension -like ".csv"){ # Checks if the file is a csv
                $Private:importfile = Import-Csv -Path $file.FullName
            }
            Elseif($file.extension -like ".xlsx") { # Checks if the file is an xlsx
                $Private:importfile = Import-XLSX -Path $file.FullName
            }
            Else {
                Throw "An error has occured"
            }
            ConvertTo-CKL -Obj $Private:importfile -version $stigViewerVersion -hostn $Private:filehostname -map $headMappers -ofile "$($Out)\$($Private:filename)" # Create and Write the ckl file
        }
    }
}
