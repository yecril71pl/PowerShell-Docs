#!/usr/bin/env pwsh
$VerbosePreference = [System.Management.Automation.ActionPreference]:: Continue
$PSVERSIONTABLE
UPDATE-HELP MICROSOFT.POWERSHELL.CORE -SO:NULL
EXIT $?
Set-PSRepository PSGALLERY -I:Trusted
INSTALL-MODULE PLATYPS, PESTER
[STRING] $BUILDROOT = $ARGS[0]
& "$BUILDROOT/build" -SKIPCABS
INVOKE-PESTER (JOIN-PATH $BUILDROOT 'tests/Pester') -EnableExit
