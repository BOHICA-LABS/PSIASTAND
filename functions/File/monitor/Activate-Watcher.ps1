﻿function Activate-Watcher{
  <#
      .Synopsis
      Continuously monitors a directory tree and write to the output the path of the file that has changed.

      .Description 
      This powershell cmdlet continuously monitors a directory tree and write to the output the path of the file that has changed.
      This allows you to create an script that for instance, run a suite of unit tests when an specific file has changed using powershell pipelining.
	
      .Parameter $location
      The directory to watch. Optional, default to current directory.

      .Parameter $filter
      Filter for only the files you are interested in.

      .Parameter $output
      the directory to create the log. Will append if log is currentlyt in the folder Parameter is optional

      .Parameter $name
      This is the name of the report to create

      .Parameter $includeSubdirectories
      .Parameter $includeChanged
      .Parameter $includeRenamed
      .Parameter $includeCreated
      .Parameter $includeDeleted
      .Link

      .Example
      Import-Module pswatch
      watch "Myfolder\Other" | %{
      Write-Host "$_.Path has changed!"
      RunUnitTests.exe $_.Path
      }
      Description
      -----------
      A simple example.
	
      .Example
      watch | Get-Item | Where-Object { $_.Extension -eq ".js" } | %{
      do the magic...
      }

      Description
      -----------
      You can filter by using powershell pipelining.
  #>


  # Define the paramters for the function
  param (
    [string]$location = $(Get-Location),
    [string]$filter = '*.*',
    [string]$output,
    [string]$name,
    [switch]$includeSubdirectories = $true,
    [switch]$includeChanged = $true,
    [switch]$includeRenamed = $true,
    [switch]$includeCreated = $true,
    [switch]$includeDeleted = $true
  )
  
  try
  {
    # Try to unregister incase this session was used
    Unregister-Event FileCreated -force
    Unregister-Event FileDeleted -force
    Unregister-Event FileChanged -force
    Unregister-Event FileRenamed -force
  
  }
  catch
  {
    # nothing to do here. This is expected
  }
  
  
  
  if ($output -and !$name -or $name -and !$output)
  {
    Throw "Cant create output if both name and output location are not defined"
    return
  }
  
  # Create the FileSystemWatcher
  $watcher = New-Object System.IO.FileSystemWatcher # FileSystemWatcher Object
  $watcher.Path = $location # Location to where we will looking for changes
  $watcher.IncludeSubdirectories = $includeSubdirectories # Look at all folders below the root folder (True or False)
  $watcher.EnableRaisingEvents = $true
  $watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::DirectoryName -bor [System.IO.NotifyFilters]::LastAccess  #-bor [System.IO.NotifyFilters]::CreationTime-bor [System.IO.NotifyFilters]::Security -bor [System.IO.NotifyFilters]::Attributes -bor [System.IO.NotifyFilters]::Size # Set the NotifyFilters
	
  # register events
  if ($includeCreated) 
  {
    Register-ObjectEvent $watcher Created -SourceIdentifier FileCreated -Action {
      return $Event
    }
  }
  
  if ($includeDeleted)
  {
    Register-ObjectEvent $watcher Deleted -SourceIdentifier FileDeleted -Action {
      return $Event
    }
  }

  if ($includeChanged)
  {
    Register-ObjectEvent $watcher Changed -SourceIdentifier FileChanged -Action {
      return $Event
    }
  }
  
  if ($includeRenamed) 
  {
    Register-ObjectEvent $watcher Renamed -SourceIdentifier FileRenamed -Action {
      return $Event
    }
  }
  Clear-Host

  while($TRUE)
  {
    foreach ($Job in  Get-Job | Where-Object {$_.HasMoreData}) # Loop through each of the registered Jobs
    {
      $foundEvent = Receive-Job $Job
      if($foundEvent -ne $null)
      {
        foreach ($item in $foundEvent)
        {
          $entry = New-Object System.Object|
          Add-Member NoteProperty FilePath $($item.SourceEventArgs.FullPath) -PassThru |
          Add-Member NoteProperty ChangeType $($item.SourceEventArgs.ChangeType.ToString()) -PassThru |
          Add-Member NoteProperty Date $($item.TimeGenerated) -PassThru
          switch ($entry.ChangeType)
          {
             'Created'{$color = 'Green'}
             'Deleted'{$color = 'Red'}
             'Renamed'{$color = 'White'}
             'Changed'{$color = 'Magenta'}
              default {$color = 'White'}
          }
          
          write-host (($entry | Format-List | Out-String).trim() + "`n`r")  -f $color
          if ($output)
          {
            # Create entry that will be flushed to CSV
            if(![System.IO.File]::Exists("$($output)\$($name).csv")) # check if file already exist (.net way)
            {
              $entry | Export-Csv -Path "$($output)\$($name).csv" -NoTypeInformation # Create the intial export
            }
            else
            {
              try
              {
                $entry | Export-Csv -Path "$($output)\$($name).csv" -NoTypeInformation -Append # append to current report
              }
              catch
              {
                Write-Host 'Could not flush to CSV. Did you open the file?' -f Red
              }
            }
          }
        }
      }
    }      
  }
 }

