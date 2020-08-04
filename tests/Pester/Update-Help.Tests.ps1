# Test Settings:
# This is the list of PowerShell Core modules for which we test update-help
$powershellCoreModules = -SPLIT 
'Microsoft.PowerShell.Host
Microsoft.PowerShell.Core
Microsoft.PowerShell.Diagnostics
Microsoft.PowerShell.Management
Microsoft.PowerShell.Security
Microsoft.PowerShell.Utility
Microsoft.WsMan.Management'

# The file extension for the help content on the Download Center.
# For Linux we use zip, and on Windows we use $extension.
$extension = '.cab'

# This is the default help installation path
$HelpInstallationPath = JOIN-PATH $home Documents PowerShell Help
# This is the list of test cases -- each test case represents a PowerShell Core module.
$testCases = @{

    Microsoft.PowerShell.Core = @{
        HelpFiles            = 'System.Management.Automation.dll-help.xml'
        HelpInfoFiles        = 'Microsoft.PowerShell.Core_00000000-0000-0000-0000-000000000000_HelpInfo.xml'
        CompressedFiles      = "Microsoft.PowerShell.Core_00000000-0000-0000-0000-000000000000_en-US_HelpContent$extension"
        HelpInstallationPath = $HelpInstallationPath
    }

    Microsoft.PowerShell.Diagnostics = @{
        HelpFiles            = 'Microsoft.PowerShell.Commands.Diagnostics.dll-help.xml'
        HelpInfoFiles        = 'Microsoft.PowerShell.Diagnostics_ca046f10-ca64-4740-8ff9-2565dba61a4f_HelpInfo.xml'
        CompressedFiles      = "Microsoft.PowerShell.Diagnostics_ca046f10-ca64-4740-8ff9-2565dba61a4f_en-US_helpcontent$extension"
        HelpInstallationPath = $HelpInstallationPath
    }

    Microsoft.PowerShell.Host = @{
        HelpFiles            = 'Microsoft.PowerShell.ConsoleHost.dll-help.xml'
        HelpInfoFiles        = 'Microsoft.PowerShell.Host_56d66100-99a0-4ffc-a12d-eee9a6718aef_HelpInfo.xml'
        CompressedFiles      = "Microsoft.PowerShell.Host_56d66100-99a0-4ffc-a12d-eee9a6718aef_en-US_helpcontent$extension"
        HelpInstallationPath = $HelpInstallationPath
    }

    Microsoft.PowerShell.Management = @{
        HelpFiles            = 'Microsoft.PowerShell.Commands.Management.dll-help.xml'
        HelpInfoFiles        = 'Microsoft.PowerShell.Management_eefcb906-b326-4e99-9f54-8b4bb6ef3c6d_HelpInfo.xml'
        CompressedFiles      = "Microsoft.PowerShell.Management_eefcb906-b326-4e99-9f54-8b4bb6ef3c6d_en-US_helpcontent$extension"
        HelpInstallationPath = $HelpInstallationPath
    }

    Microsoft.PowerShell.Security = @{
        HelpFiles            = 'Microsoft.PowerShell.Security.dll-help.xml'
        HelpInfoFiles        = 'Microsoft.PowerShell.Security_a94c8c7e-9810-47c0-b8af-65089c13a35a_HelpInfo.xml'
        CompressedFiles      = "Microsoft.PowerShell.Security_a94c8c7e-9810-47c0-b8af-65089c13a35a_en-US_helpcontent$extension"
        HelpInstallationPath = $HelpInstallationPath
    }

    Microsoft.PowerShell.Utility = @{
        HelpFiles            = 'Microsoft.PowerShell.Commands.Utility.dll-Help.xml", "Microsoft.PowerShell.Utility-help.xml'
        HelpInfoFiles        = 'Microsoft.PowerShell.Utility_1da87e53-152b-403e-98dc-74d7b4d63d59_HelpInfo.xml'
        CompressedFiles      = "Microsoft.PowerShell.Utility_1da87e53-152b-403e-98dc-74d7b4d63d59_en-US_helpcontent$extension"
        HelpInstallationPath = $HelpInstallationPath
    }

    Microsoft.WSMan.Management = @{
        HelpFiles            = 'Microsoft.WSMan.Management.dll-help.xml'
        HelpInfoFiles        = 'Microsoft.WsMan.Management_766204A6-330E-4263-A7AB-46C87AFC366C_HelpInfo.xml'
        CompressedFiles      = "Microsoft.WsMan.Management_766204A6-330E-4263-A7AB-46C87AFC366C_en-US_helpcontent$extension"
        HelpInstallationPath = $HelpInstallationPath
    }
}

if(($PSVersionTable.PSVersion.Major -ge 5) -and ($PSVersionTable.PSVersion.Minor -ge 1))
{
    $testCases += @{
        Microsoft.PowerShell.LocalAccounts = @{
            HelpFiles            = 'Microsoft.Powershell.LocalAccounts.dll-help.xml'
            HelpInfoFiles        = 'Microsoft.PowerShell.LocalAccounts_8e362604-2c0b-448f-a414-a6a690a644e2_HelpInfo.xml'
            CompressedFiles      = "Microsoft.PowerShell.LocalAccounts_8e362604-2c0b-448f-a414-a6a690a644e2_en-US_HelpContent$extension"
            HelpInstallationPath = JOIN-PATH $pshome Modules Microsoft.PowerShell.LocalAccounts * en-US
        }
    }

    $powershellCoreModules += "Microsoft.PowerShell.LocalAccounts"

}

# These are the inbox modules.
#$modulesInBox = @("Microsoft.PowerShell.Core"
#    Get-Module -ListAvailable | ForEach-Object{$_.Name}
$modulesInBox = $powershellCoreModules

function GetFiles
{
    param (
        [string]$fileType = "*help.xml",
        [ValidateNotNullOrEmpty()]
        [string]$path
    )

    Get-ChildItem $path -Include $fileType -Recurse -ea SilentlyContinue | Select-Object -ExpandProperty FullName
}

function ValidateInstalledHelpContent
{
    param (
        [ValidateNotNullOrEmpty()]
        [PARAMETER()] [string] $moduleName,
        [PARAMETER(MANDATORY)] [ValidateNotNullOrEmpty()] [STRING] $HELPINSTALLATIONPATH,
         [PARAMETER(MANDATORY)] [ValidateNotNullOrEmpty()] [STRING[]] $HelpFiles,
         [PARAMETER(MANDATORY)] [ValidateNotNullOrEmpty()] [Management.Automation.FunctionInfo] $GetFiles
    )

    $helpFilesInstalled = @(& $GetFiles -path $HelpInstallationPath | ForEach-Object {Split-Path $_ -Leaf})
    $expectedHelpFiles = @($HelpFiles)
    $helpFilesInstalled.Count | Should -Be $expectedHelpFiles.Count

    foreach ($fileName in $expectedHelpFiles)
    {
        $helpFilesInstalled -contains $fileName | Should -Betrue
    }
}

function RunUpdateHelpTests
{
    param (
        [switch]$useSourcePath
    )

    foreach ($moduleName in $modulesInBox)
    { [HASHTABLE] $MODULETESTCASES =  $testCases[$moduleName]
   GV moduleName, useSourcePath | % { $MODULETESTCASES[ $_.Name ] = $_.VALUE }
   -SPLIT 'ValidateInstalledHelpContent GetFiles' | % {
   $MODULETESTCASES[ $_ ] = GI FUNCTION:$_ }
        It "Validate Update-Help for module '$moduleName'" {

            # If the help file is already installed, delete it.
            Get-ChildItem $HelpInstallationPath -Include @("about_*.txt","*help.xml") -Recurse -ea SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue

            [HASHTABLE] $SOURCEPATHPARAM = @{}

            if ($useSourcePath)
            {
                $SOURCEPATHPARAM['SourcePath'] = JOIN-PATH $PSScriptRoot .. .. updatablehelp 5.1 $moduleName
            }
            Update-Help -Module:$moduleName -Force @SOURCEPATHPARAM
[COLLECTIONS.GENERIC.DICTIONARY[ STRING, OBJECT ]] $FORWARD =
[COLLECTIONS.GENERIC.KEYVALUEPAIR[ STRING, OBJECT ][]] (
GV HELPINSTALLATIONPATH, HelpFiles, GetFiles | % { NEW-OBJECT 'COLLECTIONS.GENERIC.KEYVALUEPAIR[ STRING, OBJECT ]' $_.NAME, $_.VALUE })
            & $ValidateInstalledHelpContent @FORWARD
        } -TestCases:$MODULETESTCASES
    }
}

Describe "Validate Update-Help -SourcePath for all PowerShell Core modules." {
    BeforeAll {
        $SavedProgressPreference = $ProgressPreference
        $ProgressPreference = "SilentlyContinue"
    }
    AfterAll {
        $ProgressPreference = $SavedProgressPreference
    }

    RunUpdateHelpTests -useSourcePath
}
