$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path $PSSCriptRoot tools.psm1) -Force -

$lmsdir = (Join-Path $PSScriptRoot .. lms)

if (-Not (Test-Path $lmsdir)) {
    git clone $LMSOriginUri $lmsdir
}

$components = Get-Components -LmsDir $lmsdir -ComponentsFile Resolve-path (Join-Path $lmsdir components.csv)
Set-ComponentRemotes -LmsDir $lmsdir -Components $components -UseUpstream
