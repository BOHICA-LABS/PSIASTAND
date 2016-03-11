[BUILD STATUS]

PSIASTAND
===================

This is a rudimentary Powershell module for performing IA functions. Currently the functions have been geared towards supporting Validation Efforts in the Marine Corps as well as my custom algorithm for determining risk

This module is geared towards automating the Marine Corps Validator Workflow following MCCAST v2. This module does contain functions and features that will help anyone performing IA Roles for the DOD

* Thanks to CookieMonster for his PSEXCEL module that has been incorporated into this module (https://github.com/RamblingCookieMonster/PSExcel)
* Thanks to CookieMonster for his PSSQLite module that has been incorporated into this module (https://github.com/RamblingCookieMonster/PSSQLite)

Caveats:

* This covers limited functionnality; contributions are welcome!
* Minimal testing. Contributions are welcome!
* Naming conventon are subject to change. Suggestion are welcome!

#Functionality

* Todo!

#Instructions

```powershell
# One time setup
    # Download the repository
    # Unblock the ZIP
    # Extract the PSIASTAND folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

# Set Execution Policy (This needs to be done for most modules on windows 8.1+)
    Set-ExecutionPolicy Bypass -scope Process

# Import the module.
    Import-Module PSIASTAND     # Alternatively, Import-Module \\Path\To\PSIASTAND

# Get commands in the module
    Get-Command -Module PSIASTAND

# Get help for a command
    Get-Help <Name of Command> -Full

```

##Work Flow:

The following workflow is based on my needs. You can modify/sugest improvements (Pull requests are welcome!!)

1. Invoke-NessusOpenPorts
    1. This creates a Listening Ports Report for each host scanned by nessus
        * This allows for a review of the PPS (Ports Protocals and Services)
        * This allows for a review of the system documentation (Data Flow)
        * Example:
        ```powershell
            Invoke-NessusOpenPorts -Nessus "<path to nessus files>" -packagename "<IS name>" -output "<path to export report>"

            Invoke-NessusOpenPorts -Nessus "C:\nessusfiles" -packagename "Test-Package" -output "C:\reports"
        ```
        * This will output 1 or 2 files. One file will contain all the found open ports: "(IS Name)_openports_(time stamp).csv". if system did not have detected open ports: "(IS Name)_NoOpenPorts_(Time Stamp).csv".

2. Export-CKL
    1. This creats CKL v1 Files from CSV or XLSX IV&V Trackers (Custom format see Test\Data for examples)
        * Creates the required CKL(s) for upload into the package
        * The CKL(s) are processed later in the workflow due to the predictability of formating in a CKL file
        * Example:
        ```powershell
            Export-CKL -Path <Path to CKL Files> -Out <Location to create the CKL(s)> -version <Version of CKL files (1 or 2. Currently only version 1 is supported)>
            
            Export-CKL -Path "C:\Trackers" -out "C:\CKLS" -version 1
        ```
        * this will pull all the trackers in the path folder and turn them into CKLS and place them in the out folder
        * This will error if trackers are not filled out correctly. Read the error message to correct.

3. Export-CombinedReports
    1. This imports both the nessus files and the CKL files and exports:
        * A combined Nessus Report
        * A CKL Combined Report
        * Example:
        ```powershell
            Export-CombinedReports -CKLFILES <Path to CKL Files (Optional)> -NESSUS <Path to Nessus Files (Optional> -output <Path to place reports> -name <IS Name> -xlsx <This is a switch you can leave it off and it will create a CSV instead>

            Export-CombinedReports -CKLFILES "C:\CKLFILES" -Nessus "C:\Nessusfiles" -output "C:\Results" -name "Test-Package" -xlsx
        ```
        * This will create 1 or 2 files depeneding on if you provided CKL files or nessus files or both.
        * File names are (IS Name)_CKL.(xlsx or csv) and (IS Name)_Nessus.(xlsx or csv)

4. Update-Controls
    1. This updates the 8500.2 Controls export from MCCAST with the Controls failed due to STIG Findings that Map to controls
        * Required for an accurate controls status report
        * Example:
        ```powershell
            Update-Controls -path <Path to controls (MCCAST Export)> -ckl <Path to CKL Files> -output <Path to output folder> -name <IS Name> -diacap <This is a switch diacap or rmf (currently only diacap is implemented)>

            Update-Controls -path "C:\Controls\controls.xlsx" -ckl "C:\CKL" -name "Test-Package" -diacap
        ```

5. Update-TestPlan
    1. This updates the MCCAST Testplan export based on the findings in the CKL files
        * Populate Test Plan where the Hardware field is blank with the name of the Package (Short form) (Look in one of your site level stig CKL in the assest field for this)
        * This should answer **ALL** Testplan questions. If not you did something wrong - Should be true. MCCAST is behind in updating the STIGS so this may not always be the case.
        * Example:
        ```powershell
            Update-TestPlan -ckl <Path to CKL Files> -testplan <Path\filename> -output <Path to output folder> -name <IS Name> -version <1 or 2 for CKL files. only version 1 has been implemented>

            Update-TestPlan -ckl "C:\CKLfiles" -testplan "C:\testplan\testplan.xlsx" -output "C:\results" -name "Test-Package" -version 1
        ```
        * This will output a new testplan filled in by the CKLS. Check for Items that did not populate or blanks and investigate.


6. Export-RiskElements
    1. This takes the Controls, the CKL(s), and the nessus file(s) and creates the risk elements report for population
        * this report is used during the population of the Risk Assessment
        * this helps determin the overall risk for the Application during the RA Process
        * This will also output a new risk report that is populated with from the mapping
        * Example:
        ```powershell
            Export-RiskElements -CKLFILES <Path to CKL FIles> -NESSUS <Path to Nessus files> -diacap <This is the path\filename to the controls can be DIACAP or RMF (Currently only DIACAP is implemented)> -name <IS Name> -output <Report output path>

            Export-RiskElements -CKLFILES "C:\CKLFiles" -NESSUS "C:\NessusFiles" -diacap "C:\Controls\controls.xlsx" -name "Test-Package" -output "C:\Results"
        ```
        * This will create a file named: (IS Name)_Risk.xlsx
        * you need to make sure that you keep your risk map updated for the risk algorithm portion of the workflow. See test\data for examples.

7. Get-Compliance
    1. This checks each stig in each CKL and Uses my compliance algorithm to determin the compliance level
        * Creates a compliance report that is used to complete the Risk Assessment
        * Example:
        ```powershell
            Get-Compliance -ckl <Path to CKL Files> -output <path to output the report> -name <IS Name>

            Get-Compliance -ckl "C:\CKLFiles" -output "C:\Report" -name "Test-Package"
        ```
        * This will create a file named: (IS Name)_STIG_Compliance_Report.xlsx

8. Invoke-RiskAlgorithm
    1. This checks the risk report and mapping and runs a custom algorithm to determin the final risk level for the Risk Assessment
        * Creates a updated Risk elements report
        * Creates a risk algorithm report
        * Example:
        ```powershell
            Invoke-RiskAlgorithm -risk <Path\name to risk elements report> -map <path to risk value mappings> -docrisk <Value between 0-100> -sysrisk <Value between 0-100 for system knowledge> -output <Path to report output folder> -name <IS Name>

            Invoke-RiskAlgorithm -risk "C:\Test-Package_Risk.xlsx" -map "C:\Risk_Mappings.xlsx" -docrisk 45 -sysrisk 65 -output "C:\results" -name "Test-Package"
        ```
        This will create 2 files: (IS Name)_Risk_Algorithm_Report.xlsx and (IS Name)_Risk_Report.xlsx

#Examples

* Todo!!

#Development

1. Download pester module and install located at https://github.com/pester/Pester
    1. This is the TDD or BDD framework that this module uses for performing unit tests and end to end tests

2. Instructions
    ```powershell
        # One time setup
            # Download the repository
            # Unblock the ZIP
            # Extract the PESTER folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)
            # Insure the module folder is named pester

        # clone the latest development version of PSIASTAND

        git clone https://github.com/drbothen/PSIASTAND.git

        # create your own branch

        git checkout -b [name_of_your_new_branch]

        # if you dont know how to use git learn that first!!!

        cd <Into PSIASTAND Folder>
        cd tests

        # all test data is in the folder data under the test folder. Please insure all sample data is placed here

        .\run-tests.ps1

        # this will invoke-pester and handle loading and unloading the PSIASTAND module before and after tests
        # if you exit the script before it finishes you will need to unload the PSIASTAND module manually (you need to do this or the changes you make in the module will not take effect for the current session)

        Remove-Module PSIASTAND

        # All functions belong in the functions folder under PSIASTAND
        # All unit tests and e2e test belong in the tests folder under PSIASTAND
    ```
    3. Naming convention
        1. .ps1 function files should be named according to the function name
        2. test .ps1 files should be named <function name>.tests.ps1

#Todo List! (Help Wanted!)

- [ ] Complete Syntax Documentation on functions!
- [ ] Update and further refine test scripts
- [ ] Nessus Compliance Added to **Get-Compliance** function
- [ ] **Invoke-NessusOpenPorts** look into merging with combined reports
- [ ] **Get-StigCompliance** and **Export-CKL** updated to work with Version **2** CKL Files
- [ ] Complete workflow for **RMF** workflow automation
- [ ] Code optimizations (ALWAYS!)
- [ ] Tracker Creation
- [ ] Update examples to include all supporting functions and how to use them. (Currently only the workflow is documented. There is alot more to this module than just MCCAST workflow)

#Feature Requests

Please submit your feature requests!!!!!

- [ ] Compare systems and compute percentage of deviation
- [ ] MCCAST v2 RSA Archer API automation
- [ ] Nessus Scan Policy Auditing
- [ ] Splunk intergration
- [ ] Dashboard...?
- [ ] IASE RSS Feed Parser automated STIG Download
- [ ] SCAP Engine
- [ ] Open STIG Viewer....? better features...