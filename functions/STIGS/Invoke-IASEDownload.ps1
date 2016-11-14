function invoke-IASEDownload
{
  <#
      .SYNOPSIS
      This Script downloads *.zip from IASE website

      .PARAMETER 

      .PARAMETER 

      .PARAMETER

      .PARAMETER 


      .EXAMPLE


      .LINK

      .VERSION
      1.0.0 (11.14.2016)
        -Intial Release

  #>

  [CmdletBinding()]
  Param(
    [string]$downloadDir,
    [array]$linksAddress = @(
      'http://iase.disa.mil/stigs/Pages/a-z.aspx?&&p_Title=Outlook%202007%20STIG%20-%20Version%204%2c%20Release%2015&&PageFirstRow=1&&View={25A09AF8-178B-447B-B42B-8839EBD71CAD}',
      'http://iase.disa.mil/stigs/Pages/a-z.aspx?Paged=TRUE&p_Title=Oracle%20WebLogic%20Server%2012c%20STIG%20-%20Ver%201%2c%20Rel%202%20&p_ID=600&PageFirstRow=301&&View={25A09AF8-178B-447B-B42B-8839EBD71CAD}'
    ),
    [string]$baseURL = 'http://iase.disa.mil', # Base URL for IASE (STIG Site)
    [int]$thread = 5, # number of threads to use
    [switch]$archive
  )
  
  New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null
  if($archive)
  {
    $achivefolder = Get-Date -Format "MMddyyyy-HHmmssms"
    New-Item -ItemType Directory -Force -Path "$($downloadDir)\$($achivefolder)" | Out-Null
    $downloadDir = "$($downloadDir)\$($achivefolder)"
  }
  else
  {
    Remove-Item "$($downloadDir)\*.zip"
  }
  
  # Download Script Block. We create it here for ease of updating code
  $downloadScriptBlock = {
    Param(
      [string]$downloadURL,
      [string]$downloaddir
    )
    
    # Create a webclient
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($downloadURL, $downloaddir)
  }
  
  # Create Runspace Pool
  $runSpacePool = [RunspaceFactory]::CreateRunspacePool(1, $thread)
  $runSpacePool.Open()
  $jobs = @()
  
  # Initialize Count
  $count =
  # Make the initial webrequest to find zips to download
  foreach ($address in $linksAddress)
  {
    $request = Invoke-WebRequest -Uri $address # Request the page
    
    # Filter links by REGEX so that we only get the full versions of STIGS/SRG
    $foundZIP = $request.Links | Where-Object{$_.href -match '(?i)^.*\.zip$' -and $_.href -notmatch '(?i)^.*IAVM.*$' -and $_.href -notmatch '(?i)^.*Benchmark.*$' -and $_.href -notmatch '(?i)^.*SCAP.*$' -and $_.href -notmatch '(?i)^.*SCC.*$' -and $_.href -notmatch '(?i)^.*Overview.*$' -and $_.href -notmatch '(?i)^.*Library.*$' -and $_.href -notmatch '(?i)^.*Quick_Start.*$' -and $_.href -notmatch '(?i)^.*Guide-Tool.*$' -and $_.href -notmatch '(?i)^.*fouo.*$'}
    
    # Download Each Zip found (Or attempt current failures are probably due to PKI)
    foreach($zip in $foundZIP)
    {
      if(!$zip.href.StartsWith('http'))
      {
        $Job = [powershell]::Create().AddScript($downloadScriptBlock).AddParameter("downloadURL", $($baseURL+$zip.href)).AddParameter("downloaddir", $($downloadDir+'\'+$($zip.href.Split('/')[-1])))
      }
      else
      {
        $Job = [powershell]::Create().AddScript($downloadScriptBlock).AddParameter("downloadURL" ,$($zip.href)).AddParameter("downloaddir",$($downloadDir+'\'+$($zip.href.Split('/')[-1])))
      }
      $Job.RunspacePool = $runSpacePool
      $jobs += New-Object PSObject -Property @{
        Pipe = $Job
        Result = $Job.BeginInvoke()
      }
    }
  }
  
  # Wait for Jobs
  While($jobs.Result.IsCompleted -contains $false)
  {
    Start-Sleep -Seconds 1
  }
  
  # Need to Add Error Handling
  #$results = @()
  #foreach($Job in $jobs)
  #{
  #  $results += $Job.Pipe.EndInvoke($Job.Result)
  #}
  #$results | Out-GridView
}

# for Testing
#invoke-IASEDownload -downloadDir "C:\Users\josh\Google Drive\Code_Repo\PSIASTAND\Downloads" -archive
