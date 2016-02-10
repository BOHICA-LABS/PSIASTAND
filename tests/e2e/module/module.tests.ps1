$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$manifestPath = "$here\..\..\..\PSIASTAND.psd1"
$changeLogPath = "$here\..\..\..\CHANGELOG.md"
$guidCheck = '84be6f1a-8fb2-49c4-83be-9e2d0a7cbe4e'
$moduleName = 'PSIASTAND'
$tempPath = "H:\Powershell\Modules\Custom\NessusOpenPorts"
$root = "$here\..\..\..\"

# General manifest annd Changelog checks
Describe -Tags 'VersionChecks' "Powershell IA Standard Library manifest and changelog" {
    $Script:manifest - $null
        It "has a valid manifest" {
            {
                $Script:manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
            } | Should Not Throw
        }

        It "has a valid name in the manifest" {
            $Script:manifest.Name | Should Be $moduleName
        }

        It "has a valid guid in the manifest" {
            $Script:manifest.Guid | Should Be $guidCheck
        }

        It "has a version listed in the manifest" {
            $Script:manifest.Version -as [version] | Should Not BeNullOrEmpty
        }

        $Script:changeLogVersion = $null
        It "has a valid version in the changelog" {
            foreach ($line in (Get-Content $changeLogPath)) {
                if ($line -match "^\D*(?<Version>(\d+\.){1,3}\d+)") {
                    $Script:changeLogVersion = $matches.Version
                    break
                }
            }
            $Script:changeLogVersion | Should Not BeNullOrEmpty
            $Script:changeLogVersion -as [Version] | Should Not BeNullOrEmpty
        }

        It "changelog and manifest versions are the same" {
            $Script:changeLogVersion -as [Version] | Should Be ($Script:manifest.Version -as [Version])
        }
}

# Module Checks

# General env Checks

# all commands are called from the safe command table
#Import-Module "$((Get-Location).Path)\..\..\..\$($moduleName)"
#Import-Module "$here\..\..\..\$($moduleName)"
InModuleScope PSIASTAND {
    Describe 'SafeCommands table' {
        $path = $ExecutionContext.SessionState.Module.ModuleBase
        $filesToCheck = Get-ChildItem -Path $path -Recurse -Include *.ps1,*.psm1 -Exclude *.Tests.ps1
        $i = 0
        $callsToSafeCommands = @(
            foreach ($file in $filesToCheck) {
                $i += 1
                $tokens = $parseErrors = $null
                $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $tokens, [ref] $parseErrors)
                #Write-Host $ast
                $filter = {
                    $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                    $args[0].InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Ampersand -and
                    $args[0].CommandElements[0] -is [System.Management.Automation.Language.IndexExpressionAst] -and
                    $args[0].CommandElements[0].Target -is [System.Management.Automation.Language.VariableExpressionAst] -and
                    $args[0].CommandElements[0].Target.VariablePath.UserPath -match '^(?:script:)?SafeCommands$'
                }

                $ast.FindAll($filter, $true)
                #Write-Host $ast.FindAll($filter, $true) $i
            }
        )
        #write-host $callsToSafeCommands.GetType()
        $uniqueSafeCommands = $callsToSafeCommands | ForEach-Object { $_.CommandElements[0].Index.Value } | Select-Object -Unique
        #write-host $callsToSafeCommands
        $missingSafeCommands = $uniqueSafeCommands | Where-Object { -not $script:SafeCommands.ContainsKey($_) }

        It 'The SafeCommands table contains all commands that are called from the module' {
            $missingSafeCommands | Should Be $null
        }
    }
}
#Remove-Module $moduleName

# Style Enforcement
Describe 'Style rules' {

  #  $files = @(
   #     Get-ChildItem "$((Get-Location).Path)" -Include *ps1, *psm1
    #    Get-ChildItem "$((Get-Location).Path)\functions" -Include *.ps1, *.psm1 -Recurse
     #   Get-ChildItem "$((Get-Location).Path)\tests" -Include *.ps1, *.psm1 -Recurse
    #)

        $files = @(
        Get-ChildItem "$root" -Include *ps1, *psm1
        Get-ChildItem "$($root)functions" -Include *.ps1, *.psm1 -Recurse
        Get-ChildItem "$($root)\tests" -Include *.ps1, *.psm1 -Recurse
    )

    It "$($moduleName) source files contain no trailing whitespace" {
        $badLines = @(
            foreach ($file in $files) {
                $lines = [System.IO.File]::ReadAllLines($file.FullName)
                $lineCount = $lines.Count

                for ($i = 0; $i -lt $lineCount; $i++) {
                    if ($lines[$i] -match '\s+$') {
                        'File: {0}, Line: {1}' -f $file.FullName, ($i + 1)
                    }
                }
            }
        )

        if ($badLines.Count -gt 0) {
            Throw "The following $($badLines.Count) lines contain trailing whitespace: `r`n`r`n$($badLines -join '`r`n')"
        }
    }

    It "$($moduleName) source files all end with a new line" {
        $badFiles = @(
            foreach ($file in $files) {
                $string = [System.IO.File]::ReadAllText($file.FullName)
                if ($string.Length -gt 0 -and $string[-1] -ne "`n") {
                    $file.FullName
                }
            }
        )

        if ($badFiles.Count -gt 0) {
            throw "The following files do not end with newline: `r`n`r`n$($badFiles -join '`r`n')"
        }
    }
}
