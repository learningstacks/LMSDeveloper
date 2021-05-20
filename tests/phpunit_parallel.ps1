function Start-Containers {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipelineByPropertName = $true
        )][string[]]$ComposeFiles,
        [Parameter(
            ValueFromPipelineByPropertName = $true
        )][string]$Service,
        [Parameter(
            ValueFromPipelineByPropertName = $true
        )][string]$ProjectName
    )
    $f = $ComposeFiles | ForEach-Object { "-f $_" }
    $dc = "docker-compose -p $Project $f)"

    # Launch stack
    Invoke-Expression "$dc up --build --detach"

    # Get the moodle container id
    $moodleContainerid = Invoke-Expression "docker inspect --format=`"{{.Id}}`" $($job.config)_moodle_1"
    $result = $job.Clone()
    $result.moodleContainerid = $moodleContainerid
    $result
}

function Stop-Containers {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)][hashtable]$Job,
        [Parameter(
            ValueFromPipelineByPropertName = $true
        )][string[]]$ComposeFiles

    )
    $f = $ComposeFiles | ForEach-Object { "-f $_" }

    $dc = "docker-compose -p $($job.config) $f)"

    # Stop and destroy containers
    Invoke-Expression "$dc down --rmi local"
    $job

}

Invoke-ContainerCommand ($containerid, $cmd) {
    Invoke-Expression "docker exec $containerid $cmd"
}


function Invoke-PhpunitJob {
    [CmdletBinding()]
    param (
        # [Parameter(ValueFromPipeline = $true)][hashtable]$Job
        # [Parameter(
        #     ParameterSetName = "docker",
        #     Mandatory = $true,
        #     ValueFromPipelineByPropertyName = $true
        # )][string]$HostType,
        [Parameter(
            ParameterSetName = "docker",
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )][string[]]$ComposeFiles,
        [Parameter(
            ParameterSetName = "docker",
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )][string]$Service,

        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )][string]$RunName,

        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )][string[]]$Components,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )][string]$ResultsDir
    )

    begin {
        # Validate $Job
    }

    process {
        Stop-Containers -ProjectName $RunName -ComposeFiles $ComposeFiles
        $moodleContainerId = Start-Containers -ComposeFiles $ComposeFiles -Service $Service
        # $results = Invoke-ContainerCommand $moodleContainerId "pwsh -Command Invoke-PhpUnit -Components  -LogDir $RemoteResultsDir -NoReport"
        Stop-Containers -ComposeFiles
        $results
    }

    end {
    }
}

}function Invoke-Tests {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)][hashtable]$Spec
    )

    $logdirname = Get-Date -Format 'yyyy-MM-dd_HHmm'
    $containerlogdir = $Spec.RemoteResultsDir + "/$logdirname"
    $locallogdir = $Spec.LocalResultsDir + "/$logdirname"
    New-Item -ItemType Directory $locallogdir -Force

    $Spec.TestJobs | ForEach-Object {
        if ($_.Type = "Phpunit") {
            $jobs = $_.TestJobs | forEach-Object -Parallel {
                @{
                    Invoke-PhpunitJob
                    Dir = $containerlogdir
                    ComposeFiles = "-f $(Join-Path $PSScriptRoot '..' 'dc_phpunit.yml')"
                    RunName = $_
                    CpmponentGroups
                }
            }

            $jobs | Wait-Job | Receive-Job

        }

        Publish-PhpUnitTestReport $locallogdir
    }

}

$tests = @{

    Host             = "Docker"
    ComposeFiles     = @(
        (Join-Path $PSScriptRoot "../dc_phpunit.yml")
    )
    Service          = "moodle"

    LocalResultsDir  = (Join-Path $PSScriptRoot "../test_results")
    RemoteResultsDir = "/app/test_results"

    $TestJobs        = @(
        @{
            Type    = "Phpunit"
            JobSets = @(
                @(
                    @{ Components = "moodle" }
                    @{ Components = "custom" }
                    @{ Components = "community" }
                    @{ Components = "elis" }
                )
            )
        }
        @{
            Type    = "Behat"
            JobSets = @(
                @(
                    @{ Components = "moodle"; Features = @{ From = 1; To = 1000 } }
                    @{ Components = "moodle"; Features = @{ From = 1001 } }
                    @{ Components = "custom" }
                    @{ Components = "community" }
                    @{ Components = "elis" }
                )
            )
        }

    )
}

Invoke-Tests $tests