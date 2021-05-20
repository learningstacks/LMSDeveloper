$DebugPreference = 'Continue'
$InformationPreference = 'Continue'
$VerbosePreference = 'Continue'

# [System.Threading.Mutex]$mut = New-Object System.Threading.Mutex($false)

class Stack {
    [string]$Name
    [array]$ComposeFiles
    [string]$TestService
    [string]$TestServiceContainerId
    [string]$DCCommand
    [string]$ServiceCmd
    [string]$Status

    Stack([string]$Name, [array]$ComposeFiles, [string]$TestService) {
        $this.ComposeFiles = $ComposeFiles
        $this.Name = $Name
        $this.TestService = $TestService

        # Construct base docker compose command
        $f = $ComposeFiles | ForEach-Object { "-f $_" }
        $this.DCCommand = "docker-compose -p $Name $f"
    }

    [void] Start() {
        $this.Compose("up --build --detach")
        $containerName = $this.Name + "_" + $this.TestService + "_"
        # Get the moodle container id
        $this.TestServiceContainerId = $this.Invoke("docker inspect --format=`"{{.Id}}`" $containerName")
        $this.Status = "ready"
    }

    [void] Stop() {
        $this.Compose("down")
        $this.Status = "stopped"
    }

    [string[]] Compose($cmd) {
        return $this.Invoke("$($this.DCCommand) $cmd")
    }

    [string[]] Moodle([string]$cmd) {
        return $this.Invoke("docker exec $($this.TestServiceContainerId) $cmd")
    }

    [string[]] InitBehat() {
        return $this.Moodle("pwsh -Command Initialize-Behat")
    }

    [string[]] InitPhpunit() {
        return $this.Moodle("pwsh -Command Initialize-Phpunit")
    }

    [string[]] Invoke ([string]$cmd) {
        Write-Debug $cmd
        $result = Invoke-Expression $cmd
        return $result
    }
}

class Test {
    [string]$Type
    [string]$ConfigFile

    Test([string]$Type, [string]$ConfigFile) {
        $this.Type = $Type
        $this.ConfigFile = $ConfigFile
    }
}

class TestManager {
    [System.Collections.ArrayList]$stacks = [System.Collections.ArrayList]::new()
    [int]$Size
    [string[]]$ComposeFiles

    TestManager([int]$Size, [string[]]$ComposeFiles, []) {
        $this.Size = $Size
        $this.ComposeFiles = $ComposeFiles
        $Stacks = foreach($i in 1..$this.PoolSize) {
            $Stacks.Add(([Stack]::New($name, $this.Composefiles, 'moodle')))
        }
    }

    [mixed] GetReadyStack() {
        foreach ($stack in $stacks.Values) {
            if ($stack_.Status -eq "ready") {
                return $stack
            }
        }

        if ($stacks.Values.Count -lt $poolsize) {
            $name = "stack_" + $stacks.Values.Count # zero-based
            $stack = [Stack]::New($name, $this.Composefiles, "test", 'moodle_test')
            $stacks.$name = [Stack]::New($name, $composefiles, "test", 'moodle_test')))
}



function Start-Stack {
    foreach ($stack in $stacks.Values) {
        $stack.Start() | Write-Debug
        # $stack.InitBehat() | Write-Debug
        # $stack.InitPhpunit | Write-Debug
    }
}

function Stop-Stack {
    foreach ($stack in $stacks.Values) {
        $stack.Stop() | Write-Debug
    }
}

function Start-TestJob {
    [CmdletBinding()]
    param (
        [Parameter()][Stack]$Stack,
        [Parameter()][hashtable]$Test
    )

    $job = Start-ThreadJob -Name $stack.Name {
        param($Stack, $Test)
        $Stack.Status = 'running'
        Write-Information "Running test $($Test.Config) on stack $($Stack.Name)"
        Start-Sleep -Seconds 2
        $Stack.Status = 'complete'
    } -ArgumentList $Stack, $Test

    return $job
}

function Invoke-Test {

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )][Test]$Test
    )

    begin {
        # $testenum = $Tests.GetEnumerator()
        $jobs = [System.Collections.ArrayList]::New()
    }

    process {
        $stack = Get-ReadyStack
        if (-Not $stack) {
            $job = $jobs | Wait-Job -Any
            $job | Receive-Job | Remove-Job # TODO Process results
            $jobs.Remove($job)
            $stack = $stacks.($job.Name)
        }
        $job = Start-TestJob -Stack $stack -Test $test
        $jobs.Add($job)
    }

    end {
        # Wait for any remaining runs to complete
        $jobs | Wait-Job | Receive-Job | Remove-Job
    }
}



function Get-Tests {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Type,
        [Parameter()][string]$From,
        [Parameter()][string]$To
    )

    $dir = $config.$Type.Dir
    $pattern = $configD.$Type.ConfigPattern
    $condition = { ((-Not $From ) -or ($_.Name -ge $From)) -and ((-Not $To ) -or ($_.Name -le $To)) }
    $tests = Get-ChildItem -Path $dir -Filter $pattern | Where-Object $condition | ForEach-Object {
        [Test]::New("Behat", $_.Name)
    }

    $tests
}


$config = @{
    Behat   = @{
        Dir             = Join-Path $PSScriptRoot "../tests/configs/behat"
        ConfigPattern   = "*.yml"
        ConfigExtension = ".yml"
    }
    Phpunit = @{
        Dir             = Join-Path $PSScriptRoot "../tests/configs/phpunit"
        ConfigPattern   = "*.xml"
        ConfigExtension = ".xml"
    }
    Stacks  = @{
        PoolSize     = 1
        ComposeFiles = @(
            Join-Path $PSScriptRoot "../docker-compose.yml"
        )
    }
}

$TestManager = New-TestManager `
    - PoolSize 5`
    - ComposeFiles

    $configew-TestManager

$TestManager = [TestManager]::New($config.Stacks.PoolSize, $config.Stacks.ComposeFiles)
$TestManager.Start()
$tests = [array](Get-Tests -Type Behat -Weekly -FailedOnly -Debug -Verbose -Report) # -From "behat_local__datahub.yml" -To "behat_local__datahub.yml")
$Run = $tests | Invoke-Test
$TestManager.Stop()
