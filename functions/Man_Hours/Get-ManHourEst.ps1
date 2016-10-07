function Get-ManHourEst
{
  <#
    .SYNOPSIS
    Get-ManHourEst produces serveral numuical values for the total amount of hours required to complete
    a package, with a given set of STIGS, and Metrics provided.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER deviceMap
    Describe parameter -deviceMap.

    .PARAMETER loeMap
    Describe parameter -loeMap.

    .EXAMPLE
    Get-ManHourEst -deviceMap Value -loeMap Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-ManHourEst

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


  
  param
  (
    [String]
    $deviceMap,
  
    [String]
    $loeMap
  )
  
  # Import SpreedSheets
  $devices = Import-XLSX $deviceMap # Import the device to STIG List
  $metrics = Import-XLSX $loeMap # Import the LOE (Level of Effort) List
  
  $admin = ("Traditional Security Checklist","DoD Internet-NIPRNet DMZ STIG", "Enclave Security Checklist", "Enclave Test and Development STIG", "DoD Enterprise DMZ Checklist",
          "DoD Enterprise DMZ Checklist", "Cloud SRG", "DNS Policy STIG", "RMF Controls", "Validator Review")
          
  $results = @()
  foreach($device in $devices){
      $entry = ($entry = " " | Select-Object Activity, Hours) # create empty obect
      $List = $device.psobject.Properties | Where-Object{$_.value -ne $null} # create object list of STIGS
      $entry.Activity = $($List | Where-Object{$_.Name -eq "Device"}).Value # Set Activity on return object
      $entry.Hours = 0 # initialize Hours to 0
      $stigs = $List | Where-Object{$_.Name -ne "Device"}
      foreach($stig in $stigs) {
          if(!$($metrics | Where-Object{$_.effort -eq $stig.name})){ # if stig was not found. Throw an eror
              Throw "{0} was not found in Metrics" -f $stig.name
          }
          $entry.Hours += $($metrics | Where-Object{$_.effort -eq $stig.name}).Hours
      }
      $results += $entry
  }

  foreach($task in $admin){
      $entry = ($entry = " " | Select-Object Activity, Hours) # create empty obect
      $entry.Activity = $task # Set Activity on return object
      if($task -eq "Validator Review"){
          $entry.Hours = $($($metrics | Where-Object{$_.effort -eq $task}).Hours * $devices.Count)
      }
      else {
        $entry.Hours = $($metrics | Where-Object{$_.effort -eq $task}).Hours
      }
        $results += $entry
  }

  #$results

  $countOfHours = 0 # set count to 0.
  foreach($result in $results){ # here we count each activities hours
      $countOfHours += $result.Hours
  }

  $estimatedHours = $countOfHours * 1 #.60 # we counted the total man hours for the entire enclave. Now we just want to pull 60% for the estimate
  $estimateWeeks = $estimatedHours / 169.6 # this is the averge amount of time the team can speed performing the IV&V
  $estimateMonths = $estimateWeeks / 4

  Write-Host ("Total Hours to complete IV&V: {0}" -f $estimatedHours)
  Write-host ("Total Weeks required to complete IV&V: {0}" -f $estimateWeeks)
  Write-Host ("Total Number of months required to complete IV&V: {0}" -f $estimateMonths)

}
