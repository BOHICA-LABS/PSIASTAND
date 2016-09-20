function Get-GPOSettings
{
  <#
      .SYNOPSIS
      Get-GPOSettings function pulls the RSOP XML report and parses out information.

      .DESCRIPTION
      A detailed description of the Get-GPOSettings function.

      .PARAMETER RsopXML
      Full file path to the previously generated RSOP XML.

      .PARAMETER output
      This is the output folder that you want Both the RSOP XML Created as well as the RSOP Report.

      .PARAMETER ComputerName
      This is the name of the computer that you want to pull the RSOP Data for. IF not set it defualts to the current.

      .PARAMETER PassThru
      This will return the parsed content to memory

      .EXAMPLE

      # Import and parse a previously generated RSOP XML File
      PS C:\> Get-GPOSettings -RsopXML <path to RSOP xml file> -output <Folder Path to Output report location>

      #Generate and Parse the RSOP XML for the given host
      PS C:\> Get-GPOSettings -output <Folder Path to Output report location> -ComputerName <Name of the system you want to pull RSOP from>

      .NOTES
      Additional information about the function.

      .VERSION
      1.0.0.0 (08.29.2016)
        - Intial Release
      1.0.1.0 (08.31.2016)
        - Corrected Speeling in the example
        - Added Limited error checking
  #>

  [CmdletBinding()]
  param
  (
    [string]$RsopXML = $null,
    [string]$output = $null,
    [string]$ComputerName = $(if(!$ComputerName){$env:COMPUTERNAME}),
    [switch]$PassThru
  )


      if (!$output -and !$PassThru)
      {
        Throw 'No form of output selected'
      }

      # Formating Varibles
      $nameOfReport = 'GPResultantSetOfPolicy' # Set Name of Report
      $dateOfReport = $(Get-Date -Format '\Dyyyy-MM-dd\THH.mm.ss') # Format date Example: D2016-08-23T14.34.13 (D stands for Date and T stands for Time (Usefull for parsing file name))

      # Get the resulting set of policy for the current system if $RsopXML is not defined
if (!$RsopXML)
{
	Try
	{
		#Get-GPResultantSetOfPolicy -Computer $ComputerName -ReportType Xml -Path $("$($output)\{0}_{1}_{2}.xml" -f $ComputerName, $nameOfReport, $dateOfReport)
		$rsopCommand = "gpresult /s $($ComputerName) /x `"$("$($output)\$($ComputerName)_$($nameOfReport)_$($dateOfReport).xml")`""
		#Write-Host $rsopCommand
		Invoke-Expression "$rsopCommand"
		
		# import created XML document
		[xml]$gpResultsXML = Get-Content $("$($output)\{0}_{1}_{2}.xml" -f $ComputerName, $nameOfReport, $dateOfReport)
	}
	Catch
	{
		Throw "[ERROR] Failed creating RSOP or importing the XML Report. Have you logged into the machine? Did you provoide the FQDN?"
	}
}
else
{
	Try
	{
		# import in the already created RSOP XML document
		[xml]$gpResultsXML = Get-Content $RsopXML
	}
	Catch
	{
		Throw "[ERROR] RSOP Could not be imported"
	}
}


      # Setup the XML namespace manager
      $xmlNameSpaceManager = New-Object System.Xml.XmlNamespaceManager $gpResultsXML.CreateNavigator().NameTable # Creating a new namespace manager object
      $xmlNameSpaceManager.AddNamespace('r', 'http://www.microsoft.com/GroupPolicy/Rsop') # This is the top level Namespace for RSOP XML Files

      # Intailize GPO GUID to Name Array of HashTables
      $gpoGuidToNameTable = @()

      # Populate the gpoGuidToName Table
      $foundGPO = $gpResultsXML.SelectNodes('//r:GPO', $xmlNameSpaceManager)

      foreach($gpo in $foundGPO) # Loop Through the Found GPO and Build a Hashtable
      {
        if (!$gpoGuidToNameTable."$($gpo.path.Identifier | Select-Object -ExpandProperty '#text')") # Check to insure we have not found the GUID NAME pair yet
        {
          $gpoGuidToNameTable += @{$($gpo.path.Identifier | Select-Object -ExpandProperty '#text') = $($gpo.name)} # Add New GUID Name Pair to the array
        }
      }

      # Gather Extensions Required for Computer Results and user results
      $gpoSets = @('ComputerResults', 'UserResults')
      $extensionGroups = @()

      foreach ($set in $gpoSets) # loop through each of the gpo sets to gather extensions
      {
        $Extensions = $gpResultsXML.SelectNodes("//r:$set/r:ExtensionData", $xmlNameSpaceManager) # use xml namespace to select all the extension nodes
        $extensionEntry = ($extensionEntry = ' ' | Select-Object SetGroup, Extensions) # Create an empty Object
        $extensionEntry.SetGroup = $set # Assign the name of the Group
        $extensionEntry.Extensions = $Extensions # Assign the list of extensions
        $extensionGroups += $extensionEntry # add to the results array
      }

      # Extensions Property Filter
      $extensionPropertiesFilter = @('type', 'xmlns')

      # intialize the Query Results Array
      $queryResults = @()

      # Set Querys that have been configured / Accounted for
      $configuredQueries = @('SecurityOptions', 'Account', 'Audit', 'UserRightsAssignment', 'EventLog', 'RestrictedGroups', 'SystemServices', 'File', 'Registry')

      # loop through each of the found groups
      foreach ($group in $extensionGroups)
      {

        # Loop through each found extension for each group
        foreach ($extension in $group.Extensions)
        {
          # We need the Extension child element of this ExtensionData element
          # and have to extract the specific namespaces assigned for Extension
          $extensionNavigator = $extension.Extension.CreateNavigator()
          $extensionNamespace = $extensionNavigator.GetNamespacesInScope('ALL')

          # loop through all the keys for the namespaces
          foreach ($key in $extensionNamespace.Keys)
          {
            # The namespace assignments we're looking for are always named 'q1', 'q2', ... 'q99' etc...
            if ($key -match '^q\d{1,2}$')
            {
              $xmlNameSpaceManager.AddNamespace($key, $extensionNamespace.$key) # add the found namespace we are looking for to the namespace manager
              $queryEntry = ($queryEntry = ' ' | Select-Object GroupSet, Name, Query)
              $queryEntry.GroupSet = $group.SetGroup # Assign the Group Name ComputerResults, UserResults, etc...
              $queryEntry.Name = $key # Name of the Query
              $queryEntry.Query = $extension.Extension | Get-Member -Type Property | Select-Object -ExpandProperty Name | Where-Object{ $extensionPropertiesFilter -notcontains $_ -and $_ -ne $key } # Set the Query(s)
              $queryResults += $queryEntry # Add to the results
            }
          }
        }
      }

      # Intialize the results varible
      $results = @()

      foreach ($queries in $queryResults)
      {
        # Loop through extensions querys
        foreach ($query in $queries.Query)
        {
          if ($configuredQueries -contains $query) # Check to see if we have added the ability to process the results of the query
          {
            $queried = $gpResultsXML.SelectNodes($('//{0}:{1}' -f $queries.Name, $query), $xmlNameSpaceManager) | Select-Object @{
              Label = 'GroupName'; Expression = { $queries.GroupSet }
            },@{
              Label = 'GPOName'; Expression = { $gpoGuidToNameTable."$($_.GPO.Identifier | Select-Object -ExpandProperty '#text')" }
            },@{
              Label = 'QueryName'; Expression = { $query }
            },@{
              Label = 'Name'; Expression = { if ($_.Display.name -and $_.Display.name -ne '')
                                         {
                                            [string]::Concat($_.Display.name)
                                         }
                                         Else
                                         {
                                            $concatArray = @() # Holds all the Values that we will be concat
                                            if ($_.Path -and $_.Path -ne '')
                                            {
                                              $concatArray += $_.Path
                                            }
                                            if ($_.GroupName.Name -and $_.GroupName.Name -ne '') {$concatArray += $($_.GroupName.Name | Select-Object -ExpandProperty '#text')}
                                            if ($_.KeyName -and $_.KeyName -ne '') {$concatArray += $_.KeyName}
                                            if ($_.SystemAccessPolicyName -and $_.SystemAccessPolicyName -ne '' ) {$concatArray += $_.SystemAccessPolicyName}
                                            if ($_.Name -ne $('{0}:{1}' -f $queries.Name, $query))
                                            {
                                              if ($_.Log)
                                              {
                                                $concatArray += $($_.Name + ':' + $_.Log)
                                              }
                                              else
                                              {
                                                $concatArray += $_.Name
                                              }
                                            }

                                            [string]::Concat($concatArray)
                                         }
                                       }
            },@{
              Label = 'Value'; Expression = { if ($_.Display.name -and $_.Display.name -ne '') # Checks if it has a display name (Cleaner name) and pulls the display version of the value
                                          {
                                            $concatArray = @() # Holds all the Values that we will be concat
                                            if ($_.Display.DisplayNumber -and $_.Display.DisplayNumber -ne '') {$concatArray += $_.Display.DisplayNumber}
                                            if ($_.Display.DisplayBoolean -and $_.Display.DisplayBoolean -ne '') {$concatArray += $_.Display.DisplayBoolean}
                                            if ($_.Display.DisplayString -and $_.Display.DisplayString -ne '') {$concatArray += $_.Display.DisplayString}

                                            if ($_.Display.DisplayStrings)
                                            {
                                              $concatArray += $($_.Display.DisplayStrings |
                                                              ForEach-Object -Begin { $output = @() } -Process { $output += $_.Value } -End { $([string]::join("`r`n", $output)) } )
                                            }
                                            if ($_.Display.DisplayFields)
                                            {
                                              $concatArray += $($_.Display.DisplayFields.Field |
                                                              ForEach-Object -Begin { $output = @() } -Process { $output += $($_.Name + ':' +$_.Value) } -End { $([string]::join("`r`n", $output)) } )
                                            }
                                            [string]::Concat($concatArray)
                                          }
                                          else
                                          {
                                            $concatArray = @() # Holds all the Values that we will be concat
                                            if ($_.SuccessAttempts)
                                            {
                                              $concatArray += $('Success:' + $_.SuccessAttempts)
                                            }
                                            if ($_.FailureAttempts)
                                            {
                                              $concatArray += $('Failure:' + $_.FailureAttempts)
                                            }
                                            if ($_.StartupMode)
                                            {
                                              $concatArray += $('StartupMode:' + $_.StartupMode)
                                            }
                                            if ($_.SecurityDescriptor) # Need to have greater sample size to see if this can conatin more information
                                            {
                                              if ($($_.SecurityDescriptor.PermissionsPresent | Select-Object -ExpandProperty '#text') -eq 'true')
                                              {
                                                $concatArray += $('PermissionsPresent:' + $($_.SecurityDescriptor.PermissionsPresent | Select-Object -ExpandProperty '#text')) # Label Permissions Present True
                                                $concatArray += $($_.SecurityDescriptor.Permissions.TrusteePermissions |
                                                                  ForEach-Object -Begin { $output = @() } -Process { $output += $( if ($($_.Trustee.Name | Select-Object -ExpandProperty '#text') -eq '')
                                                                                                                     {
                                                                                                                        if ($_.Standard.RegistryGroupedAccessEnum)
                                                                                                                        {
                                                                                                                          $($_.Trustee.SID | Select-Object -ExpandProperty '#text') +':' + $($_.Type.PermissionType) + ':' + $($_.Standard.RegistryGroupedAccessEnum)
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                          $($_.Trustee.SID | Select-Object -ExpandProperty '#text') +':' + $($_.Type.PermissionType) + ':' + $($_.Standard.FileGroupedAccessEnum)
                                                                                                                        }
                                                                                                                     }
                                                                                                                     else
                                                                                                                     {
                                                                                                                         if ($_.Standard.RegistryGroupedAccessEnum)
                                                                                                                         {
                                                                                                                            $($_.Trustee.Name | Select-Object -ExpandProperty '#text') + ':' + $($_.Type.PermissionType) + ':' + $($_.Standard.RegistryGroupedAccessEnum)
                                                                                                                         }
                                                                                                                         else
                                                                                                                         {
                                                                                                                            $($_.Trustee.Name | Select-Object -ExpandProperty '#text') + ':' + $($_.Type.PermissionType) + ':' + $($_.Standard.FileGroupedAccessEnum)
                                                                                                                         }
                                                                                                                     }
                                                                                                                   ) } -End { $([string]::join("`r`n", $output)) })
                                              }
                                              else
                                              {
                                                $concatArray += $('PermissionsPresent:' + $($_.SecurityDescriptor.PermissionsPresent | Select-Object -ExpandProperty '#text')) # Need to Check this if its set to true. My examples have it set to false
                                              }
                                              if ($($_.SecurityDescriptor.AuditingPresent | Select-Object -ExpandProperty '#text') -eq 'true')
                                              {
                                                 $concatArray += $('AuditingPresent:' + $($_.SecurityDescriptor.AuditingPresent | Select-Object -ExpandProperty '#text')) # Set AuditingPresent to True
                                                 $concatArray += $($_.SecurityDescriptor.Auditing.TrusteeAuditing |
                                                                    ForEach-Object -Begin { $output = @() } -Process { $output += $( if ($($_.Trustee.Name | Select-Object -ExpandProperty '#text') -eq '')
                                                                                                                                     {
                                                                                                                                        $($_.Trustee.SID | Select-Object -ExpandProperty '#text') + ':' + $_.Type.AuditType
                                                                                                                                     }
                                                                                                                                     else
                                                                                                                                     {
                                                                                                                                        $($_.Trustee.Name | Select-Object -ExpandProperty '#text') + ':' + $_.Type.AuditType
                                                                                                                                     }
                                                                                                                                    ) }  -End { ([string]::join("`r`n", $output)) })
                                              }
                                              else
                                              {
                                                $concatArray += $('AuditingPresent:' + $($_.SecurityDescriptor.AuditingPresent | Select-Object -ExpandProperty '#text')) # Need to Check this if its set to true. My examples have it set to false
                                              }
                                            }

                                            if ($_.SettingNumber -and $_.SettingNumber -ne '') {$concatArray += $_.SettingNumber}
                                            if ($_.SettingString -and $_.SettingString -ne '') {$concatArray += $_.SettingString}
                                            if ($_.SettingBoolean -and $_.SettingBoolean -ne '') {$concatArray += $_.SettingBoolean}
                                            if ($_.SettingStrings -and $_.SettingStrings -ne '') {$concatArray += $($_.SettingStrings |
                                                                                                    ForEach-Object -Begin { $output = @() } -Process { $output += $_.Value } -End { $([string]::join('|', $output)) } )}
                                            if ($_.Member -and $_.Member -ne '') {$concatArray += $($_.Member |
                                                                                      ForEach-Object -Begin { $output = @() } -Process { $output += $( if ($_.SID)
                                                                                                                                                       {
                                                                                                                                                        $_.SID | Select-Object -ExpandProperty '#text'
                                                                                                                                                       }
                                                                                                                                                       else
                                                                                                                                                       {
                                                                                                                                                        $_.Name | Select-Object -ExpandProperty '#text'
                                                                                                                                                       }
                                                                                                                                                      ) } -End { $([string]::join("`r`n", $output)) } )}
                                            [string]::join("`r`n",$concatArray)
                                          }
                                        }
            } | Sort-Object Name
            $results += $queried
          }
        }
      }

      if ($output)
      {
        # Output the results from the parser
        $results | Export-Csv -NoTypeInformation -Path $("$($output)\{0}_{1}_{2}.csv" -f $ComputerName, $nameOfReport, $dateOfReport)
      }
      if ($PassThru)
      {
        # Return results of the RSOP Parse to memory
        return $results
      }
    }
