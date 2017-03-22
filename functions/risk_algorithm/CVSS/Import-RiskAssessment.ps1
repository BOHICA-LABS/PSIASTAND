function Import-RiskAssessment
{
  <#
      .SYNOPSIS
      Launches the CLI for assigning CVSS Scores

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
  param
  (
    [String]
    $risk = $(Throw "No RISK Path provided"),
  
    [String]
    $map = $(Throw "No MAP provided"),
    
    [String]
    $output = $(Throw "No Output folder provided"),
    
    [String]
    $name = $(Throw "No Name provided"),
    
    [switch]
    $answer
  )
  
  # Global Regex Objects
  $colonfind = New-Object System.Text.RegularExpressions.Regex '^.*(:{2}).*$', 'ignorecase'
  $ruleandVuln = New-Object System.Text.RegularExpressions.Regex '^\s{0,}(\S{0,})\s{0,}::\s{0,}(\S{0,})\s{0,}$', 'ignorecase'
  
  # Test to see if the path to the risk report exists
  if(!(Test-Path -Path $risk)){Throw "Risk path does not exist"} 
  
  # Test to see if the path to the map report exists
  if(!(Test-Path -Path $map)){Throw "Map path does not exist"}

  # Import Risk Elements
  $riskelements = Import-XLSX -Path $risk
  
  # Import mapper
  $riskmap = Import-XLSX -Path $map
  
  # Select the ID from the Risk Map
  $riskmapIDlist = $(($riskmap | Select-Object ID).ID)
  
  # Loop Through Each risk Element
  $nomap = @()
  foreach ($element in $riskelements)
  {
    # Test for a colon in the element
    if($colonfind.IsMatch($element.id))
    {
      # Extract Both sides of the colon
      $extracted = $ruleandVuln.Matches($element.id)
      
      # Test different variations for a match in the mapper
      if($riskmapIDlist -match "^\s{0,}($($extracted.groups[1].Value))\s{0,}::\s{0,}($($extracted.groups[2].Value))\s{0,}$")
      {
        $mapping = $riskmap | Where-Object {$_.ID -match "^\s{0,}($($extracted.groups[1].Value))\s{0,}::\s{0,}($($extracted.groups[2].Value))\s{0,}$"}
      }
      elseif($riskmapIDlist -match "^\s{0,}($($extracted.groups[1].Value))\s{0,}::\s{0,}(\S{0,})\s{0,}$")
      {
        $mapping = $riskmap | Where-Object {$_.ID -match "^\s{0,}($($extracted.groups[1].Value))\s{0,}::\s{0,}(\S{0,})\s{0,}$"}
      }
      elseif($riskmapIDlist -match "^\s{0,}(\S{0,})\s{0,}::\s{0,}($($extracted.groups[1].Value))\s{0,}$")
      {
        $mapping = $riskmap | Where-Object {$_.ID -match "^\s{0,}(\S{0,})\s{0,}::\s{0,}($($extracted.groups[1].Value))\s{0,}$"}
      }
      elseif($answer)
      {
        # This will be a call to CLI answer
      }
      else
      {
        $badmap = (' ' | Select-Object Source, Name, ID, Cat, IAControl, CVSS)
        $badmap.Source = $element.Source
        $badmap.Name = $element.name
        $badmap.ID = $element.ID
        $badmap.Cat = $element.Cat
        $badmap.IAControl = $element."IA Control"
        $nomap += $badmap
      } 
      
    }
    elseif($riskmapIDlist -match $element.id)
    {
      $mapping = $riskmap | Where-Object {$_.ID -match $element.id}
    }
    elseif($answer)
    {
      # This will be a call to CLI answer
    }
    else
    {
        $badmap = (' ' | Select-Object Source, Name, ID, Cat, IAControl, CVSS)
        $badmap.Source = $element.Source
        $badmap.Name = $element.name
        $badmap.ID = $element.ID
        $badmap.Cat = $element.Cat
        $badmap.IAControl = $element."IA Control"
        $nomap += $badmap
    }
    
    # Check to see if it returned more then one match
    if($mapping.Count -gt 1){$mapping = $mapping[0]}
    $element.CVSS = $mapping.CVSS
  }
  
  if($nomap)
  {
    Export-XLSX -Path "$($output)\$($name)_Risk_ERROR.xlsx" -InputObject $nomap
    Throw "Items are missing Mappings. Please Check $($output)\$($name)_MissingMap_Report.xlsx"
  }
  else
  {
    Export-XLSX -Path "$($output)\$($name)_Risk_Report.xlsx" -InputObject $riskelements
  }
}

#Import-RiskAssessment -risk "C:\Users\josh\Google Drive\Code_Repo\PSIASTAND\tests\data\Mock_APP\APP_OWNER_Risk_CVSS1.xlsx" -map "C:\Users\josh\Google Drive\Code_Repo\PSIASTAND\tests\data\Risk_Mapping\Sample_Risk_Map_CVSS1.xlsx" -output "C:\Users\josh\Google Drive\Code_Repo\PSIASTAND\tests" -name "test"

