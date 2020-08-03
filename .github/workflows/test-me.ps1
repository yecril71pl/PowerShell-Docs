#!/usr/bin/env pwsh
Set-PSRepository PSGALLERY -I:Trusted
INSTALL-MODULE PESTER
[STRING] $BUILDROOT = $ARGS[0]
& "$BUILDROOT/build"
INVOKE-PESTER (JOIN-PATH $BUILDROOT 'tests/Pester') -EnableExit
