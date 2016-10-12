$here = Split-Path -Parent $MyInvocation.MyCommand.Path
#$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
#. "$here\..\..\..\..\functions\nessus\main\$sut"

$moduleName = "PSIASTAND"

$PSVersion = $PSVersionTable.PSVersion.Major

#Import-Module "$here\..\..\..\..\$($moduleName)"

#Set up some data we will use in testing
    $ExistingXLSXFile = "$here\Working.xlsx"
    Remove-Item $ExistingXLSXFile  -force -ErrorAction SilentlyContinue
    Copy-Item $here\Test.xlsx $ExistingXLSXFile -force

    $NewXLSXFile = "$here\New.xlsx"
    Remove-Item $NewXLSXFile  -force -ErrorAction SilentlyContinue

    $Files = Get-ChildItem $PSScriptRoot | Where {-not $_.PSIsContainer}

Describe -tag 'Add-Table' "Add-Table PS: $PSVersion" {

    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'Should add a table to an existing xlsx' {
            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force

	    $TableName = "TestTable"
	    $WorkSheetName = 'Worksheet1'

            Get-ChildItem C:\Windows |
                Where {-not $_.PSIsContainer} |
                Export-XLSX -Path $NewXLSXFile

            Add-Table -Path $NewXLSXFile -WorkSheetName $WorkSheetName -TableStyle Medium10 -TableName $TableName

            $Excel = New-Excel -Path $NewXLSXFile
            $WorkSheet = @( $Excel | Get-Worksheet -Name $WorkSheetName )

            $Table = $Worksheet[0].Tables[0]
	    $Table.Name | Should be $TableName
	    $Table.Worksheet | Should be $WorkSheetName
	    $Table.StyleName | Should be 'TableStyleMedium10'

            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force
        }
	It 'Should create a table in an xlsx' {
            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force

	    $WorkSheetName = 'Worksheet1'

            Get-ChildItem C:\Windows |
                Where {-not $_.PSIsContainer} |
                Export-XLSX -Path $NewXLSXFile -WorkSheetName $WorkSheetName -Table -TableStyle Medium10 -AutoFit

            $Excel = New-Excel -Path $NewXLSXFile
            $WorkSheet = @( $Excel | Get-Worksheet -Name $WorkSheetName )

            $Table = $Worksheet[0].Tables[0]
	    $Table.Name | Should be $WorkSheetName
	    $Table.Worksheet | Should be $WorkSheetName
	    $Table.StyleName | Should be 'TableStyleMedium10'

            Remove-Item $NewXLSXFile -ErrorAction SilentlyContinue -force
        }
    }
}
#Remove-Module $moduleName
Remove-Item $NewXLSXFile -force -ErrorAction SilentlyContinue
Remove-Item $ExistingXLSXFile -force -ErrorAction SilentlyContinue
