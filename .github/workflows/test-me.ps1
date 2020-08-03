#!/usr/bin/env pwsh
Set-PSRepository PSGALLERY -I:Trusted
IF (INSTALL-MODULE PESTER) {
INVOKE-PESTER @ARGS } ELSE { EXIT 1 }
