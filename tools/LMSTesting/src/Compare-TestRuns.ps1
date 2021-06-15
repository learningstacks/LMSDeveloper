function Compare-TestRuns {
    <#
        .SYNOPSIS
        Parse all behat log files in the given log directory and produce a consolidated summary report.
    #>
    [CmdletBinding()]
    param (

        [Parameter(
            ParameterSetName = 'run',
            Mandatory = $true,
            Position = 0
        )][string]$Run1,

        [Parameter(
            ParameterSetName = 'run',
            Mandatory = $true,
            Position = 1
        )][string]$Run2,

        [Parameter()][hashtable]$LMSConfig = (Get-LmsConfig)
    )

    begin {
        
        
    }
    
    process {

        $cols = @(
            @{Name = 'Component'; Expression = { $_.Name } }
            @{Name = 'Failures'; Expression = { $_.Count } }
        )

        $Run1Dir = "$($LMSConfig.LocalRoot)/$($LMSConfig.RunRoot)/$Run1"
        $Run2Dir = "$($LMSConfig.LocalRoot)/$($LMSConfig.RunRoot)/$Run2"

        $behat1 = (Get-BehatResults -RunDir $Run1Dir).FailedScenarios | Group-Object Component -NoElement | Select-Object $cols
        $behat2 = (Get-BehatResults -RunDir $Run2Dir).FailedScenarios | Group-Object Component -NoElement | Select-Object $cols

        $behat = @{}

        foreach ($result in $behat1.GetEnumerator()) {
            $behat.($result.Component) = @{
                Component           = $result.Component
                ($Run1) = $result.Failures
                ($Run2) = 0
            }
        }
        foreach ($result in $behat2.GetEnumerator()) {
            if ($behat.ContainsKey($result.Component)) {
                $behat[$result.Component].$Run2 = $result.Failures
            }
            else {
                $behat.($result.Component) = @{
                    Component           = $result.Component
                    ($Run1) = 0
                    ($Run2) = $result.Failures
                }
            }
        }

        '' | Out-Host
        'BEHAT FAILURES' | Out-Host
        $behat.Values | Select-Object Component, $run1, $run2 | Out-String

        $phpunit1 = (Get-PhpunitResults -RunDir $Run1Dir).Issues | Where-Object Result -NE 'skipped' | Group-Object Component -NoElement | Select-Object $cols
        $phpunit2 = (Get-PhpunitResults -RunDir $Run2Dir).Issues | Where-Object Result -NE 'skipped' | Group-Object Component -NoElement | Select-Object $cols

        $phpunit = @{}

        foreach ($result in $phpunit1.GetEnumerator()) {
            $phpunit.($result.Component) = @{
                Component = $result.Component
                ($Run1)   = $result.Failures
                ($Run2)   = 0
            }
        }
        foreach ($result in $phpunit2.GetEnumerator()) {
            if ($phpunit.ContainsKey($result.Component)) {
                $phpunit[$result.Component].$Run2 = $result.Failures
            }
            else {
                $phpunit.($result.Component) = @{
                    Component = $result.Component
                    ($Run1)   = 0
                    ($Run2)   = $result.Failures
                }
            }
        }

        '' | Out-Host
        'PHPUNIT FAILURES' | Out-Host
        $phpunit.Values | Select-Object Component, $run1, $run2 | Out-String
    }

    # $th = '{0,20} {1,30} {2,30}'
    # $tr = '{0,20} {1,10} {2,10} {3,10} {4,10}'

    # $table = @(
    #     ($th -f '', 'Behat Failures', 'Phpunit Failures')
    #     ($tr -f 'Component', $run1, $run2, $run1, $run2 )
    # )

    # $comps = $behat.Keys + $phpunit.Keys | Sort-Object | Get-Unique
    # $table += foreach ($comp in $comps) {
    #     $b1 = $behat1.$comp.$run1
    # }

    # foreach ($comp in ($behat.keys + $phpunit.keys)) {

    # }


}