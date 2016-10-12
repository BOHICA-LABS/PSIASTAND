$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = "$here\..\..\..\"


Describe -tag 'Statistics' 'Code Statistics' {

        $files = @(
            Get-ChildItem "$root" -Include *ps1, *psm1
            Get-ChildItem "$($root)functions" -Include *.ps1, *.psm1 -Recurse
            Get-ChildItem "$($root)\tests" -Include *.ps1, *.psm1 -Recurse
        )
        $lineCount = 0
        $NewlineCount = 0
        $realline = 0
        foreach ($file in $files) {
            $lines = [System.IO.File]::ReadAllLines($file.FullName)
            $lineCount += $lines.Count

            for($i = 0; $i -lt $($lines.Count); $i++) {
                if ($lines[$i] -match '^\s*$') {
                    $NewlineCount ++
                }
                else{
                    $realline ++
                }
            }
        }

        $testfiles = @(
            Get-ChildItem "$($root)\tests" -Include *.ps1, *.psm1 -Recurse
        )
        $testlinecount = 0
        $testnewlineCount = 0
        $testrealline = 0
        foreach ($file in $testfiles) {
            $lines = [System.IO.File]::ReadAllLines($file.FullName)
            $testlinecount += $lines.Count

            for($i = 0; $i -lt $($lines.Count); $i++) {
                if ($lines[$i] -match '^\s*$') {
                    $testnewlineCount ++
                }
                else {
                    $testrealline ++
                }
            }
        }

        $mainfiles = @(
            Get-ChildItem "$root" -Include *ps1, *psm1
            Get-ChildItem "$($root)functions" -Include *.ps1, *.psm1 -Recurse
        )
        $mainlinecount = 0
        $mainnewlineCount = 0
        $mainrealline = 0
        foreach ($file in $mainfiles) {
            $lines = [System.IO.File]::ReadAllLines($file.FullName)
            $mainlinecount += $lines.Count

            for($i = 0; $i -lt $($lines.Count); $i++) {
                if ($lines[$i] -match '^\s*$') {
                    $mainnewlineCount ++
                }
                else {
                    $mainrealline ++
                }
            }
        }
    Context "Overall Code statistics" {

        It "$($moduleName) Code base has $($lineCount) total lines" {
            $true | Should Be $true
        }

        It "$($moduleName) Code base has $($realline) code lines" {
            $true | Should Be $true
        }

        It "$($moduleName) Code base has $($NewlineCount) blank lines (Style Lines)" {
            $true | Should Be $true
        }
    }

    Context "Test Code statistics" {

        It "$($moduleName) Code base has $($testlinecount) total lines" {
            $true | Should Be $true
        }

        It "$($moduleName) Code base has $($testrealline) code lines" {
            $true | Should Be $true
        }

        It "$($moduleName) Code base has $($testnewlineCount) blank lines (Style Lines)" {
            $true | Should Be $true
        }
    }

    Context "Main Code statistics" {

        It "$($moduleName) Code base has $($mainlinecount) total lines" {
            $true | Should Be $true
        }

        It "$($moduleName) Code base has $($mainrealline) code lines" {
            $true | Should Be $true
        }

        It "$($moduleName) Code base has $($mainnewlineCount) blank lines (Style Lines)" {
            $true | Should Be $true
        }
    }
}
