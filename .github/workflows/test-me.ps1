#!/usr/bin/env pwsh
$VerbosePreference = [System.Management.Automation.ActionPreference]:: Continue
Set-PSRepository PSGALLERY -I:Trusted
INSTALL-MODULE PLATYPS, PESTER
[STRING] $BUILDROOT = $ARGS[0]
& "$BUILDROOT/build" -SKIPCABS
INVOKE-PESTER (JOIN-PATH $BUILDROOT 'tests/Pester') -EnableExit
