function Show-TestRun {
    <#
        .SYNOPSIS
        Parse all behat log files in the given log directory and produce a consolidated summary report.
    #>
    [CmdletBinding()]
    param (
        # The directory containing the result files to be processed.
        [Parameter(
            ParameterSetName = 'dir',
            Mandatory = $true
        )][string]$RunDir,

        [Parameter(
            ParameterSetName = 'run',
            Mandatory = $true
        )][string]$Run,

        [Parameter()][hashtable]$LMSConfig = (Get-LmsConfig)
    )

    begin {        
    }
    
    process {

        if ($Run) {
            $RunDir = "$($LMSConfig.LocalRoot)/$($LMSConfig.RunRoot)/$Run"
        }
    
        if (-Not (Test-Path $RunDir)) {
            throw "$RunDir not found"
        }

        $behatresults = Get-BehatResults -RunDir $RunDir
        $phpunitresults = Get-PhpunitResults -RunDir $RunDir

        $cols = @(
            @{Name = 'Component'; Expression = { $_.Name } }
            @{Name = 'Failures'; Expression = { $_.Count } }
        )

        '' | Out-Host
        '' | Out-Host
        'BEHAT RESULTS' | Out-Host
        '-------------' | Out-Host
        $behatresults.FailedScenarios | Group-Object Component -NoElement | Select-Object $cols | Format-Table | Out-Host

        '' | Out-Host
        '' | Out-Host
        'PHPUNIT RESULTS' | Out-Host
        '-------------' | Out-Host
        $phpunitresults.Issues | Where-Object Result -NE 'skipped' | Group-Object Component -NoElement | Select-Object $cols | Format-Table | Out-Host 
    }
}