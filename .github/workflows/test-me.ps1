#!/usr/bin/env pwsh
Set-PSRepository PSGALLERY -I:Trusted
INSTALL-MODULE PESTER
INVOKE-PESTER @ARGS
