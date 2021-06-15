function Get-RunStatus {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )][string]$RunName,

        [hashtable]$Site = (Get-Site)
    )

    begin {
        $rundir = "$($Site.Paths.LOcal.RunRoot)/$RunName"
        if (-Not (Test-Path -PathType 'Container' -Path $rundir)) {
            throw "$rundie not found or not a directory"
        }


        function GetStatus($dir) {
            $started = if (Test-Path "$dir/started") { Get-Content "$dir/started" } else { $false }
            $finished = if (Test-Path "$dir/completed") { Get-Content "$dir/completed" } else { $false }
            $state = if (-Not $started) { 
                'notstarted' 
            }
            elseif (-Not $completed) { 
                'incomplete' 
            }
            else {
                'completed'
            }   
            return @{
                Started   = $started
                Completed = $completed
                State    = $state
            }
        }
    }

    
    process {

        $TestRun = Get-Run $rundir
        foreach ($test in $TestRun.Tests) {
            $dir = Join-Path $rundir $test.RunRelativeDir
            $status = GetStatus $_
        }

        $behatdirs = Get-ChildItem -Path "$RunDir/behat" -Directory -Depth 0 | ForEach-Object { 
            $status = GetStatus $_
            $results = Get-BehatResults $_
            @{
                Type       = 'behat'
                Name       = $_.NameString
                HasConfig  = (Test-Path "$_/behat.yml")
                HasResults = (Test-Path "$_/behat_results.log")
                Started    = $status.Started
                Completed  = $status.Completed
                Status     = $status.Status
                Results    = $results
            }
        }
        $phpunitdirs = Get-ChildItem -Path "$RunDir/phpunit" -Directory -Depth 0 | ForEach-Object { 
            $status = GetStatus $_
            $results = Get-PhpunitResults $_
            @{
                Type       = 'phpunit'
                Name       = $_.NameString
                HasConfig  = (Test-Path "$_/phpunit.xml")
                HasResults = (Test-Path "$_/junit.xml")
                Started    = $status.Started
                Completed  = $status.Completed
                Status     = $status.Status
                Results    = $results
            }
        }

        @{
            Behat   = [array]$behatdirs
            Phpunit = [array]$phpunitdirs
        }
    }
}