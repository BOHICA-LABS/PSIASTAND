function Activate-Watcher{
  <#
      .Synopsis
      Continuously monitors a directory tree and write to the output the path of the file that has changed.

      .Description 
      This powershell cmdlet continuously monitors a directory tree and write to the output the path of the file that has changed.
      This allows you to create an script that for instance, run a suite of unit tests when an specific file has changed using powershell pipelining.
	
      .Parameter $location
      The directory to watch. Optional, default to current directory.

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
    [string]$location = "",
    [string]$output,
    [string]$name,
    [switch]$includeSubdirectories = $true,
    [switch]$includeChanged = $true,
    [switch]$includeRenamed = $true,
    [switch]$includeCreated = $true,
    [switch]$includeDeleted = $true
  )
  
  if ($output -and !$name -or $name -and !$output)
  {
    Throw "Cant create output if both name and output location are not defined"
    return
  }
  
  
  # Get the current location
  if($location -eq ""){
    $location = get-location
  }
	
  # Create the FileSystemWatcher
  $watcher = New-Object System.IO.FileSystemWatcher # FileSystemWatcher Object
  $watcher.Path = $location # Location to where we will looking for changes
  $watcher.IncludeSubdirectories = $includeSubdirectories # Look at all folders below the root folder (True or False)
  $watcher.EnableRaisingEvents = $true
  $watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::DirectoryName -bor [System.IO.NotifyFilters]::LastAccess # Set the NotifyFilters
	
  # Build the conditions based on the types of changes we want to look for
  $conditions = 0
  if($includeChanged){
    $conditions = [System.IO.WatcherChangeTypes]::Changed 
  }

  if($includeRenamed){
    $conditions = $conditions -bOr [System.IO.WatcherChangeTypes]::Renamed
  }

  if($includeCreated){
    $conditions = $conditions -bOr [System.IO.WatcherChangeTypes]::Created 
  }

  if($includeDeleted){
    $conditions = $conditions -bOr [System.IO.WatcherChangeTypes]::Deleted
  }
	
  while($TRUE){
    $result = $watcher.WaitForChanged($conditions, 1000); # wait for changes
    if($result.TimedOut){
      continue;
    }
    $filepath = [System.IO.Path]::Combine($location, $result.Name) # Create the File Path
    New-Object Object |
          Add-Member NoteProperty Path $filepath -passThru | 
          Add-Member NoteProperty Operation $result.ChangeType.ToString() -passThru | 
          write-output # Write to console
    if ($output) 
    {
      # Create entry that will be flushed to CSV
      ($entry = ""  | Select-Object FilePath, ChangeType, Date) 
      $entry.FilePath =  $filepath
      $entry.ChangeType = $result.ChangeType
      $entry.Date = Get-Date # get current time information (Maybe not the most acurate for this...?)
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
