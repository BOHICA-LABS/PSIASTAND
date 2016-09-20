function Start-Watcher{
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

      .Parameter $testmode
      This is for testing. It will exit the while loop after the defined number of Secounds have passed

      .Paramter $passthur
      This will output the objects to the shell in theroy.

      .Parameter $monmode
      When enabled it writes detected changes to the console.

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

      .Version
      1.0.0.0 (09.16.2016)
        - Initial release
  #>


  # Define the paramters for the function
  param (
    [string]$location = $(Get-Location),
    [string]$filter = '*.*',
    [string]$output = $null,
    [string]$name = $null,
    [int]$testmode,
    [switch]$passthur = $false,
    [switch]$monmode = $false,
    [switch]$includeSubdirectories = $true,
    [switch]$includeChanged = $true,
    [switch]$includeRenamed = $true,
    [switch]$includeCreated = $true,
    [switch]$includeDeleted = $true
  )

  $allowedJobs = @(
    'FileCreated',
    'FileDeleted',
    'FileChanged',
    'FileRenamed'
  )

  try
  {
    # Try to unregister incase this session was used
    # Added SilentlyContinue error action as if this fails, the events arent registered anyways
    # SilentlyContinue hides the unneeded error messages
    Unregister-Event FileCreated -force -ErrorAction SilentlyContinue
    Unregister-Event FileDeleted -force -ErrorAction SilentlyContinue
    Unregister-Event FileChanged -force -ErrorAction SilentlyContinue
    Unregister-Event FileRenamed -force -ErrorAction SilentlyContinue

  }
  catch
  {
    # nothing to do here. This is expected
  }



  if (($output -and !$name) -or (!$output -and $name))
  {
    Throw "Cant create output if both name and output location are not defined"
  }

  if ($passthur -and $monmode)
  {
    Throw "Choose one type of mode."
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
    } | Out-Null # suppress Console Output
  }

  if ($includeDeleted)
  {
    Register-ObjectEvent $watcher Deleted -SourceIdentifier FileDeleted -Action {
      return $Event
    } | Out-Null # suppress Console Output
  }

  if ($includeChanged)
  {
    Register-ObjectEvent $watcher Changed -SourceIdentifier FileChanged -Action {
      return $Event
    } | Out-Null # suppress Console Output
  }

  if ($includeRenamed)
  {
    Register-ObjectEvent $watcher Renamed -SourceIdentifier FileRenamed -Action {
      return $Event
    } | Out-Null # suppress Console Output
  }

  <#
      if (!$testmode) # only invoked if not used in testmode
      {
      Clear-Host # wipe the screen
      }
  #>

  if ($testmode) # used for testing. Set the forced exit time
  {
    $exitTime = (Get-Date).AddSeconds($testmode)
  }

  $monitoring = $true
  while($monitoring)
  {
    foreach ($Job in  Get-Job | Where-Object {$_.HasMoreData}) # Loop through each of the registered Jobs
    {
      if ($allowedJobs -notcontains $Job.name)
      {
        Continue
      }
      $foundEvent = Receive-Job $Job
      if($foundEvent -ne $null)
      {
        foreach ($item in $foundEvent)
        {

            if ($($item.SourceEventArgs.FullPath) -eq $("$($output)\$($name).csv")) # try and detect if a event was raised do to updating report file
            {
              continue
            }
            try
            {
              if ($(Get-Item $item.SourceEventArgs.FullPath -ErrorAction SilentlyContinue) -is [System.IO.DirectoryInfo])
              {
                $itemType = 'Folder'
              }
              elseif ($(Get-Item $item.SourceEventArgs.FullPath -ErrorAction SilentlyContinue) -is [System.IO.FileInfo])
              {
                $itemType = 'File'
              }
              else
              {
                $itemType = 'Unknown'
              }
            }
            catch
            {
              $itemType = 'Unknown'
            }

          $entry = New-Object System.Object|
          Add-Member NoteProperty FilePath $($item.SourceEventArgs.FullPath) -PassThru |
          Add-Member NoteProperty Type $itemType -PassThru|
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

          # if monmode (Monitor Mode) display monitoring on the screen.
          if ($monmode)
          {
            write-host (($entry | Format-List | Out-String).trim() + "`n`r")  -f $color
          }

          # if passthur return object. This is really for testing or interfacing with another application
          if ($passthur)
          {
            $entry
          }

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
    # Some form of sleep should be set in here between while loop iterations.

    if ($testmode) # test Mode. Check if the time condition has been met, if so exit.
    {
      if ($(Get-Date) -ge $exitTime)
      {
        $monitoring = $false
      }
    }
  }
 }
