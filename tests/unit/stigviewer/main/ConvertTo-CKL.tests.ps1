$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'


$moduleName = "PSIASTAND"
$PSVersion = $PSVersionTable.PSVersion.Major


Describe "ConvertTo-CKL PS: $PSVersion" {

    # Stig viewer version
    $stigViewerVersion = "DISA STIG Viewer : 1.2.0"

    # mappers
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

    Copy-Item -Path "$Global:testData\Trackers\Sample04_Win2008R2MS.csv" -Destination "TestDrive:\Sample_Win2008R2MS.csv"
    Copy-Item -Path "$Global:testData\Trackers\Sample05_Win2008R2MS.xlsx" -Destination "TestDrive:\Sample_Win2008R2MS.xlsx"

    Setup -Dir "result"

    Context "Strict mode" {

        Set-StrictMode -Version latest

        It "Should create a ckl v1 file from (CSV)" {
            $csvfile = Import-Csv -Path "TestDrive:\Sample_Win2008R2MS.csv"
            ConvertTo-CKL -Obj $csvfile -version 1 -hostn "Sample" -map $headMappers -ofile $(Join-Path $TestDrive "result\samplecsvV1.ckl")
            $file = Get-Item -Path "TestDrive:\result\samplecsvV1.ckl"
            #Remove-Item "TestDrive:\result\sample.ckl"
            $file.name | Should be "samplecsvV1.ckl"
        }

        It "Should create a ckl v2 file from (CSV)" {
            $csvfile = Import-Csv -Path "TestDrive:\Sample_Win2008R2MS.csv"
            ConvertTo-CKL -Obj $csvfile -version 2 -hostn "Sample" -map $headMappers -ofile $(Join-Path $TestDrive "result\samplecsvV2.ckl")
            $file = Get-Item -Path "TestDrive:\result\samplecsvV2.ckl"
            #Remove-Item "TestDrive:\result\sample.ckl"
            $file.name | Should be "samplecsvV2.ckl"
        }

        It "Should create a ckl v1 file from (XLSX) (Requires Import-XLSX)" {
            $xlsxfile = Import-XLSX -Path "TestDrive:\Sample_Win2008R2MS.xlsx"
            ConvertTo-CKL -Obj $xlsxfile -version 1 -hostn "Sample" -map $headMappers -ofile $(Join-Path $TestDrive "result\samplexlsxV1.ckl")
            $file = Get-Item -Path "TestDrive:\result\samplexlsxV1.ckl"
            #Remove-Item "TestDrive:\result\sample.ckl"
            $file.name | Should be "samplexlsxV1.ckl"
        }

        It "Should create a ckl v2 file from (XLSX) (Requires Import-XLSX)" {
            $xlsxfile = Import-XLSX -Path "TestDrive:\Sample_Win2008R2MS.xlsx"
            ConvertTo-CKL -Obj $xlsxfile -version 2 -hostn "Sample" -map $headMappers -ofile $(Join-Path $TestDrive "result\samplexlsxV2.ckl")
            $file = Get-Item -Path "TestDrive:\result\samplexlsxV2.ckl"
            #Remove-Item "TestDrive:\result\sample.ckl"
            $file.name | Should be "samplexlsxV2.ckl"
        }

        It "Should create a CKL v1 file (csv) (Requires Import-XML, Import-CKL)" {
            $xml = Import-XML -Path $(Join-Path $TestDrive "result\samplecsvV1.ckl")
            $xml.CHECKLIST.VULN | Should Be $true
        }

        It "Should create a CKL v1 file (xlsx) (Requires Import-XML, Import-CKL)" {
            $xml2 = Import-XML -Path $(Join-Path $TestDrive "result\samplexlsxV1.ckl")
            $xml2.CHECKLIST.VULN | Should Be $true
        }

        It "Should create a CKL v2 file (csv) (Requires Import-XML, Import-CKL)" {
            $xml3 = Import-XML -Path $(Join-Path $TestDrive "result\samplecsvV2.ckl")
            $xml3.CHECKLIST.STIGS | Should Be $true
        }

        It "Should create a CKL v2 file (xlsx) (Requires Import-XML, Import-CKL)" {
            $xml4 = Import-XML -Path $(Join-Path $TestDrive "result\samplexlsxV2.ckl")
            $xml4.CHECKLIST.STIGS | Should Be $true
        }
    }
}

#Remove-Module $moduleName
