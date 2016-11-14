function Invoke-STIGZIPTraverse
{
  <#
      .SYNOPSIS
      This Script extracts XCCDF from ZIP files

      .PARAMETER 

      .PARAMETER 

      .EXAMPLE

      .LINK

      .VERSION
      1.0.0 (11.14.2016)
        -Intial Release

  #>
  
  # Parameters
  [CmdletBinding()]
  param
  (
    [String]
    $zips,
  
    [String]
    $output
  )
  
  # Add the require type to handle ZIP's
  Add-Type -AssemblyName "system.io.compression.filesystem"

  # Find all the Zip files
  $foundzips = Get-ChildItem -Filter '*.zip' -Path $zips
  
  # Initialize results array
  $results = @()
  
  # cycle through each of the found Zips
  foreach ($zip in $foundzips)
  {
    # Open the archive for reading
    $archive = [io.compression.zipfile]::OpenRead($zip.fullname)
    
    # Enum all entries in the archive (files and Directories)
    foreach ($archiveEntry in $archive.Entries)
    {
      # if the file is an XCCDF Document
      if($archiveEntry.FullName -match '.*xccdf\.xml')
      {
        # Get Temp File -- This will also create the file
        $tempFile = [System.IO.Path]::GetTempFileName()
        
        # Extract to temp file
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($archiveEntry, $tempFile, $true)
        
        # Load extracted XML
        [xml]$xml = Get-Content $tempFile
        Write-Verbose "Processing: $($xml.Benchmark.title)"
        
        # Parse XML and generate Line Item Object
        foreach ($group in $xml.Benchmark.Group)
        {
          # Create Initial Object
          $entry = (' ' | Select-Object STIG_Title, RuleID, RuleVersion, VNum, Title, Rule_Title, Description, Check_Content, Severity)
          
          # Populate entry Object
          $entry.STIG_Title = $xml.Benchmark.title
          $entry.RuleID = $group.rule.id
          $entry.RuleVersion = $Group.rule.version
          $entry.Vnum = $Group.id
          $entry.Title = $group.title
          $entry.Rule_Title = $group.Rule.title
          $entry.Description = $group.rule.description
          $entry.check_Content = $group.Rule.check.'check-content'
          $entry.Severity = $group.rule.severity
          
          # Append entry object to results array
          $results += $entry
          
        }
      }
    }
  }
  
  # Export $results Varible to CSV
  
  $results | Export-Csv -NoTypeInformation -Path $output
}

Invoke-STIGZIPTraverse -zips "C:\Users\josh\Google Drive\Code_Repo\PSIASTAND\Downloads\11142016-3140" -output "C:\Users\josh\Google Drive\Code_Repo\PSIASTAND\STIG_Report.csv" -Verbose
