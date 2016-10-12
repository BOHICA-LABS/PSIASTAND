<#
  .Version
    1.0.0.0
#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'


$moduleName = 'PSIASTAND'
$PSVersion = $PSVersionTable.PSVersion.Major

Describe -tag 'Get-GPOSettings' "Get-GPOSettings PS: $PSVersion"{
  # Copy test data to TestDrive. The testData Varaible is created by the run tests script
  Copy-Item -Path "$Global:testData\GPO\RSOP\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml" -Destination 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml'

  Set-Content $('TestDrive:\test.txt') -Value 'This is of no value'

  Context 'Strict Mode'{
    # Enable Strict Mode in Powershell
    Set-StrictMode -Version latest

    It 'Should find results for the UserRightsAssignment Query'{
      # Pull the Count for the number of objects expected for the UserRightsAssignment Query
      $Count = $((Get-GPOSettings -RsopXML "$($TestDrive)\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml" -PassThru).QueryName | Where-Object {$_ -eq 'UserRightsAssignment'}).Count
      $Count | Should be 43
    }

    It 'Should find results for the SecurityOptions Query'{
      # Pull the Count for the number of objects expected for the SecurityOptions Query
      $Count = $((Get-GPOSettings -RsopXML 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml' -PassThru).QueryName | Where-Object {$_ -eq 'SecurityOptions'}).Count
      $Count | Should be 86
    }

    It 'Should find results for the Account Query'{
      # Pull the Count for the number of objects expected for the Account Query
      $Count = $((Get-GPOSettings -RsopXML 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml' -PassThru).QueryName | Where-Object {$_ -eq 'Account'}).Count
      $Count | Should be 9
    }

    It 'Should find results for the Audit Query'{
      # Pull the Count for the number of objects expected for the Audit Query
      $Count = $((Get-GPOSettings -RsopXML 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml' -PassThru).QueryName | Where-Object {$_ -eq 'Audit'}).Count
      $Count | Should be 8
    }

    It 'Should find results for the EventLog Query'{
      # Pull the Count for the number of objects expected for the EventLog Query
      $Count = $((Get-GPOSettings -RsopXML 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml' -PassThru).QueryName | Where-Object {$_ -eq 'EventLog'}).Count
      $Count | Should be 9
    }

    It 'Should find results for the RestrictedGroups Query'{
      # Pull the Count for the number of objects expected for the RestrictedGroups Query
      $Count = $((Get-GPOSettings -RsopXML 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml' -PassThru).QueryName | Where-Object {$_ -eq 'RestrictedGroups'}).Count
      $Count | Should be 2
    }

    It 'Should find results for the SystemServices Query'{
      # Pull the Count for the number of objects expected for the SystemServices Query
      $Count = $((Get-GPOSettings -RsopXML 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml' -PassThru).QueryName | Where-Object {$_ -eq 'SystemServices'}).Count
      $Count | Should be 12
    }

    It 'Should find results for the File Query'{
      # Pull the Count for the number of objects expected for the File Query
      $Count = $((Get-GPOSettings -RsopXML 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml' -PassThru).QueryName | Where-Object {$_ -eq 'File'}).Count
      $Count | Should be 11
    }

    It 'Should find results for the Registry Query'{
      # Pull the Count for the number of objects expected for the Registry Query
      $Count = $((Get-GPOSettings -RsopXML 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml' -PassThru).QueryName | Where-Object {$_ -eq 'Registry'}).Count
      $Count | Should be 11
    }

    It 'should throw "No form of output selected"'{
      {Get-GPOSettings -RsopXML 'TestDrive:\Sample_GPResultantSetOfPolicy_D2016-08-30T17.38.49.xml'} | Should throw 'No form of output selected'
    }

    It 'should throw "RSOP Could not be imported"'{
      {$testResults = Get-GPOSettings -RsopXML 'TestDrive:\test.txt' -PassThru} | Should throw 'RSOP Could not be imported'
    }

  }
}
