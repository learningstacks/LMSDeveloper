using module ./LMSTesting

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$DebugPreference = 'SilentlyContinue'

Set-StrictMode -Version 4.0
Set-PSDebug -Off

Import-Module (Join-Path $PSScriptRoot '../LMSTools') -Force -ErrorAction 'Stop'
Import-Module (Join-Path $PSScriptRoot 'LMSTesting') -Force -Verbose:$false




# $RunSpec = {
#     Name = 'name'
#     PhpunitBy = 'Group'
#     BehatBy = 'Segment'
#     FilterSpec = { $_.Component -ne 'moodle' }
# } | New-TestRun | Start-TestRun

# New-Run -CommitRef 'master' -PhpunitBy 'Group' -Filter { $_.Component -ne 'moodle'} -BehatBy 'Segment'

<#
TODO
- New-Run should build the moodle container and tag it. Could freeze the codebase this way
#>

$TestSpec = @{
    CommitRef = 'master'
    Phpunit   = @{
        SegmentBy = 'Group'
        Filter    = { $_.Component -ne 'moodle' }
    }
    Behat     = @{
        SegmentBy = 'Component'
        Filter    = { $_.Component -ne 'moodle' }
    }
}
$runname = 'plugins_4'
$run = New-TestRun -RunName $runname -TestSpec $testspec -Force -Verbose 

$run | start-testrun -Reset
# $run | Start-TestRun -Verbose
