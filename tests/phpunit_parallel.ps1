function RunDCPhpunitJob($job) {
    # Define the docker-compose command with project name and compose files
    $dc = "docker-compose -p $($job.config) $($job.composefiles)"

    # Stop and delete any running containers
    Invoke-Expression "$dc down --rmi local"

    # Launch stack
    Invoke-Expression "$dc up --build --detach"

    # Get the moodle container id
    $moodleid = Invoke-Expression "docker inspect --format=`"{{.Id}}`" $($job.config)_moodle_1"

    # Wait for the DB to be ready
    Invoke-Expression "docker exec $moodleid /usr/local/bin/wait-for-it.sh db:3306"

    $cmd =  "docker exec $moodleid pwsh -Command Initialize-PhpUnit -Config {1}.xml -AddComponentGroups" -f $job.config, $job.dir
    # Invoke-PhpUnit, skip report generation
    $cmd = "docker exec $moodleid pwsh -Command Invoke-PhpUnit -Config {1}.xml -LogDir {2} -NoReport" -f  $job.config, $job.dir
    Invoke-Expression $cmd

    # Stop and destroy containers
    Invoke-Expression "$dc down --rmi local"
}

function Invoke-PhpunitTests {
    $root = Resolve-Path (Join-Path $PSScriptRoot "..")
    $logdirname = Get-Date -Format 'yyyy-MM-dd_HHmm'
    $containerlogdir = "/app/test_results/phpunit/$logdirname"
    $locallogdir = Join-Path $PSScriptRoot ".." "test_results" "phpunit" $logdirname
    New-Item -ItemType Directory $locallogdir -Force

    $tests = $("moodle", "elis", "custom", "community") | forEach-Object {
        @{
            Config       = "phpunit_$_.xml"
            Dir          = $containerlogdir
            ComposeFiles = "-f $(Join-Path $PSScriptRoot '..' 'dc_phpunit.yml')"
            RunName = $_
        }
    }
    $jobs = $tests | forEach-Object -Parallel { RunDCPhpunitJob $_ } -AsJob
    $jobs | Wait-Job | Receive-Job

    # Generate reports
    Publish-PhpUnitTestReport $locallogdir

    # $("custom", "elis", "community", "moodle") | forEach-Object -Parallel {
    #     $jobs | forEach-Object -Parallel {
    #         $job = $_

    #         # Define the docker-compose command with project name and compose files
    #         $dc = "docker-compose -p $($job.config) $($job.composefiles)"

    #         # Stop and delete any running containers
    #         Invoke-Expression "$dc down --rmi local"

    #         # Launch stack
    #         Invoke-Expression "$dc up --build --detach"

    #         # Get the moodle container id
    #         $moodleid = Invoke-Expression "docker inspect --format=`"{{.Id}}`" $($job.config)_moodle_1"

    #         # Wait for the DB to be ready
    #         $cmd = "docker exec $moodleid /usr/local/bin/wait-for-it.sh db:3306"
    #         Invoke-Expression $cmd

    #         # Invoke-PhpUnit, skip report generation
    #         $cmd = "docker exec {0} pwsh -Command Invoke-PhpUnit -Config {1}.xml -LogDir {2} -NoReport" -f $moodleid, $job.config, $job.dir
    #         Invoke-Expression $cmd

    #         # Stop and destroy containers
    #         Invoke-Expression "$dc down --rmi local"

    #     } -AsJob | Wait-Job | Receive-Job

    #     # Generate reports
    #     Publish-PhpUnitTestReport $locallogdir
    # }

    Invoke-PhpunitTests