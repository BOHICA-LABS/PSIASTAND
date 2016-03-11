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
        * This will output 1 or 2 files. One file will contain all the found open ports: "(IS Name)_openports_(time stamp).csv". if system did not have detected open ports: "(IS Name)_NoOpePorts_(Time Stamp).csv".

2. Export-CKL
    1. This creats CKL v1 Files from CSV or XLSX IV&V Trackers (Custom format see Test\Data for examples)
        * Creates the required CKL(s) for upload into the package
        * The CKL(s) are processed later in the workflow due to the predictability of formating in a CKL file

3. Export-CombinedReports
    1. This imports both the nessus files and the CKL files and exports:
        * A combined Nessus Report
        * A CKL Combined Report

4. Update-Controls
    1. This updates the 8500.2 Controls export from MCCAST with the Controls failed due to STIG Findings that Map to controls
        * Required for an accurate controls status report

5. Update-TestPlan
    1. This updates the MCCAST Testplan export based on the findings in the CKL files
        * Populate Test Plan where the Hardware field is blank with the name of the Package (Short form) (Look in one of your site level stig CKL in the assest field for this)
        * This should answer **ALL** Testplan questions. If not you did something wrong - Should be true. MCCAST is behind in updating the STIGS so this may not always be the case.

6. Export-RiskElements
    1. This takes the Controls, the CKL(s), and the nessus file(s) and creates the risk elements report for population
        * this report is used during the population of the Risk Assessment
        * this helps determin the overall risk for the Application during the RA Process
        * This will also output a new risk report that is populated with from the mapping

7. Get-Compliance
    1. This checks each stig in each CKL and Uses my compliance algorithm to determin the compliance level
        * Creates a compliance report that is used to complete the Risk Assessment

8. Invoke-RiskAlgorithm
    1. This checks the risk report and mapping and runs a custom algorithm to determin the final risk level for the Risk Assessment
        * Creates a updated Risk elements report
        * Creates a risk algorithm report



#Examples

* Todo!!

#Todo List! (Help Wanted!)

- [ ] Complete Syntax Documentation on functions!
- [ ] Update and further refine test scripts
- [ ] Nessus Compliance Added to **Get-Compliance** function
- [ ] **Invoke-NessusOpenPorts** look into merging with combined reports
- [ ] **Get-StigCompliance** and **Export-CKL** updated to work with Version **2** CKL Files
- [ ] Complete workflow for **RMF** workflow automation
- [ ] Code optimizations (ALWAYS!)
- [ ] Tracker Creation

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