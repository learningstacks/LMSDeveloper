function Start-RemoteTestRun {

}

function Start-LocalTestRun {

}

function Start-TestRun {
    [CmdletBinding()]
    param (

        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$RunName,

        # [Parameter(
        #     ParameterSetName = 'testrun',
        #     Mandatory = $true,
        #     ValueFromPipeline = $true
        # )][TestRun]$TestRun,

        [Parameter()]
        [Scriptblock]$FilterSpec = { $true },
 
        [switch]$Reset,
        [switch]$ReRun,
        # [switch]$Quiet,

        [switch]$RerunFailed,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Site = (Get-Site)
        
        # [int]$MaxPoolSize = 5
    )

    $status = @{
        TestSegments = $tests.Count
        Started      = 0
        Finished     = 0
        Failed       = 0
    }

    function LogStatus {
        $status | ConvertTo-Json -Depth 2 | Out-File "$localrundir/RunStatus.json"
    }

    $isRemote = $Site.ContainsKey('Docker')
    $remoterundir = $null
        
    if ($RunName) {
        $localrundir = "$($Site.Paths.Local.RunRoot)/$RunName"
        $remoterundir = if ($isRemote) { "$($Site.Paths.Remote.RunRoot)/$RunName" } else { $null }
    }
    else {
        $localrundir = $RunDir
    }
         
    # elseif ($TestRun) {
    #     $localrundir = $TestRun.Paths.Local.RunDir
    #     $remoterundir = if ($isRemote) {$TestRun.Paths.Remote.RunDir} else { $null }
    # }
        
    # if ($TestRun.Docker) {
    #     $rundir = $TestRun.Paths.Remote.RunDir
    # }
    # else {
    #     $rundir = $TestRun.Paths.Local.RunDir
    # }

    if (-Not (Test-Path -PathType Container -Path $localrundir)) {
        throw "$localrundir does not exist or is not a directory"
    }

    # Find all test directories
    $tests = foreach ($type in @('behat', 'phpunit')) {
        Get-ChildItem -Directory -Path "$localrundir/$type" -Recurse | Where-Object { (Test-Path "$_/behat.yml") -or (Test-Path "$_/phpunit.xml") } | ForEach-Object {
            @{
                Type           = $type
                RunRelativeDir = [System.IO.Path]::GetRelativePath($localrundir, $_ ) 
            } 
        }
    }

    # Apply the filter
    $tests = $tests | Where-Object $FilterSpec

    if ($Reset) {
        Get-ChildItem $localrundir -File | Remove-Item
        foreach ($test in $tests) { 
            $dir = Join-Path $localrundir $test.RunRelativeDir 
            Get-ChildItem $dir -Exclude phpunit.xml, behat.yml | Remove-Item -Recurse
        }
    }
        
    
    $template = @{
        behat   = 'Invoke-Behat -Config {0}/behat.yml -LogDir {0}'
        phpunit = 'Invoke-Phpunit -Config {0}/phpunit.xml -LogDir {0}'
    }
    try {
        LogStatus
        
        if ($isRemote) {
            $PoolManager = [PoolManager]::New($Site.Docker.ComposeFiles, $Site.Docker.Service)
            $PoolManager | Start-Pool -Size ([Math]::Min($MaxPoolSize, $tests.Count))
        }
        
        Set-Content -Path "$localrundir/started" (Get-Date)
        
        # Run the tests
        $testNum = 0
        foreach ($test in $tests) {     

            $testnum++      

            if ($isRemote) {
                $Stack = $PoolManager | Get-Stack
                $invocation = $template[$Test.Type] -f "$remoterundir/$($Test.RunRelativeDir)"
                Write-Verbose "Starting: $($Test.RunRelativeDir) on Stack $($Stack.Name) ($testnum of $($tests.Count))"
                $job = $Stack | Invoke-Stack -Pwsh $invocation -AsJob
                $Stack.Test = $Test
            }
                    
            else {
                Write-Verbose "Starting: $($Test.RunRelativeDir) ($testnum of $($tests.Count))"
                $invocation = $template[$Test.Type] -f "$localrundir/$($Test.RunRelativeDir)"
                $result = $Stack | Invoke-Stack -Pwsh $invocation
                # Invoke-Expression $invocation
            }

            $status.Started++
            LogStatus
        }
    }

    catch {
        Write-Error $_.ToString()
    }
    finally {
        if ($isRemote) {
            $PoolManager.GetJobs() | Wait-Job | Receive-Job
            $null = Get-Job | Remove-Job
            $PoolManager | Stop-Pool
        }
        Write-Output 'COMPLETE'
        Set-Content -Path "$localrundir/finished" -Value (Get-Date)
    }

    # Produce reports
    Publish-TestRunResults $RunName

}