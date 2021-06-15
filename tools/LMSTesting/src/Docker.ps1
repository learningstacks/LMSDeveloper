using namespace System.Collections

class Stack {
    [string]$Name
    [array]$ComposeFiles
    [string]$TestService
    [string]$TestServiceContainerId
    [string]$DCCommand
    [string]$ServiceCmd
    [string]$Status
    [Object]$Job
    [hashtable]$Test
    [string]$Comment

    Stack([string]$Name, [array]$ComposeFiles, [string]$TestService) {
        $this.ComposeFiles = $ComposeFiles
        $this.Name = $Name
        $this.TestService = $TestService
        $this.Status = 'stopped'

        # Construct base docker compose command
        $f = $ComposeFiles | ForEach-Object { "-f $_" }
        $this.DCCommand = "docker-compose -p $Name $f"
    }

    # [void] Start() {
    #     Write-Debug 'Stack.Start'
    #     $this.Compose('up --build --detach')
    #     Write-Debug 'sleep'
    #     Start-Sleep -Seconds 5
    #     Write-Debug 'Slept'
    #     $this.Status = 'running'
    # }

    # [void] Stop() {
    #     Write-Debug 'Stack.Stop'
    #     $this.Compose('down')
    #     $this.Status = 'stopped'
    # }

    [string] GetExecCmd([string]$cmd) {
        return "$($this.DCCommand) exec $($this.TestService) $cmd"
    }

    [string] GetUpCmd([string]$cmd) {
        return "$($this.DCCommand) up --build --detach"
    }

    [string] GetDownCmd([string]$cmd) {
        return "$($this.DCCommand) down"
    }

    # [string[]] Invoke([string]$Expression) {
    #     Write-Debug "Stack.Invoke($Expression)"
    #     $result = Invoke-Expression $Expression
    #     return $result
    # }

    # [string[]] Compose($cmd) {
    #     return $this.Invoke("$($this.DCCommand) $cmd")
    # }

    # [string[]] Exec([string]$cmd) {
    #     Write-Debug "Stack.Exec($cmd)"
    #     if ($this.Status -eq 'stopped') { $this.Start() }
    #     $result = $this.Compose("exec $($this.TestService) $cmd")
    #     return $result
    # }

    # [Object] StartTest([string]$cmd) {
    #     Write-Debug "Stack.StartTest($cmd)"
    #     if ($this.Status -eq 'stopped') { $this.Start() }
    #     $exp = $this.GetExecCmd($cmd)
    #     # $this.Job = Start-ThreadJob -Name $this.Name {
    #     #     param([string]$Exp)
    #     #     Invoke-Expression $Exp
    #     # } -ArgumentList $exp
    #     # return $this.Job
    #     return $null
    # }
}



function New-Stack {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )][string]$Name,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )][string[]]$ComposeFiles,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )][string]$RemoteRoot = '/app',

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )][string]$TestService = 'moodle'
    )

    [Stack]::New($Name, $ComposeFiles, $TestService)
}

function Start-Stack {
    param(
        [Parameter(
            ParameterSetName = 'stackobject',
            Mandatory = $true,
            ValueFromPipeline = $true
        )][Stack]$Stack,

        [switch]$AsJob

    )

    Write-Debug "Starting stack $($Stack.Name)"

    $block = {
        param($Stack)
        Import-Module './tools/LMSTesting'
        $null = Invoke-Expression "$($Stack.DCCommand) up --build --detach"
        $Stack.Status = 'running'
        $Stack | Invoke-Stack -Sh 'wait-for-it db:3306'
        $Stack | Inmvoke-Stack -Sh 'sudo chown -R docker /appdata' # HACK
    }
    
    $null = Invoke-Expression "$($Stack.DCCommand) up --build --detach"
    $Stack.Status = 'running'
    $null = $Stack | Invoke-Stack -Sh 'wait-for-it db:3306'

    # if ($AsJob) {
    #     $Stack.Job = $job
    #     $job
    # }
    # else {
    #     $job | Wait-Job | Receive-Job -Keep -ErrorVariable err -InformationVariable info -OutVariable out
    #     $null = $job | Remove-Job
    # }

    # if ($AsJob) {
    # $job = Start-ThreadJob {
    #     param($cmd)
    #     Invoke-Expression $cmd
    #     # TODO Find a better way to determine up
    #     Start-Sleep -Seconds 10
    # } -ArgumentList $cmd | Wait-Job
    # # To do look for errors
    # $null = $job | Remove-Job
    # $Stack.Status = 'running'
}

function Stop-Stack {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )][Stack]$Stack
    )

    process {
        if ($Stack.Status -eq 'running') {
            Write-Debug "Stopping Stack '$($Stack.Name)'"
            $cmd = "$($Stack.DCCommand) down"
            $job = Start-ThreadJob {
                param($cmd)
                Invoke-Expression $cmd
            } -ArgumentList $cmd | Wait-Job
            # To do look for errors
            $null = $job | Remove-Job
            $Stack.Status = 'stopped'
        }
        else {
            Write-Debug "Stop-Stack: Stack '$($Stack.Name)' is not running"
        }
    }
}

function Invoke-Stack {
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )][Stack]$Stack,

        [Parameter(
            ParameterSetName = 'pwsh',
            Mandatory = $true
        )][string]$Pwsh,

        [Parameter(
            ParameterSetName = 'sh',
            Mandatory = $true
        )][string]$Sh,

        [Parameter(
            ParameterSetName = 'do',
            Mandatory = $true
        )][string]$Do,

        [switch]$AsJob
    )

    if ($Stack.Status -ne 'running') {
        $Stack | Start-Stack
    }

    if ($Do) {
        $exp = "$($Stack.DCCommand) exec $($Stack.TestService) pwsh -File /app/do.ps1 $Do"
        Write-Debug "Invoke Stack $exp"
        $result = Invoke-Expression $exp
        if ($LASTEXITCODE -ne 0) {
            Write-Error $stderr
        }
        $result | ConvertFrom-Json
    }
    elseif ($Sh) {
        $exp = "$($Stack.DCCommand) exec $($Stack.TestService) sh -c '$Sh'"
        Write-Debug "Invoke Stack $exp"
        $result = Invoke-Expression $exp
        if ($LASTEXITCODE -ne 0) {
            Write-Error $result
        }
        $result
    }
    elseif ($Pwsh) {
        $exp = "$($Stack.DCCommand) exec $($Stack.TestService) pwsh -Command '$Pwsh'"

        $block = {
            param([string]$Exp)

            Write-Debug "Invoke Stack $($Stack.Name):  $Exp"
            $result = Invoke-Expression $Exp
            if ($LASTEXITCODE -ne 0) {
                Write-Error $result
            }
            $result | Write-Output
        }

        $job = Start-ThreadJob $block -ArgumentList $exp -Name $Stack.Name -Verbose -Debug
        if ($job.State -eq 'failed') {
            $job | Receive-Job -Keep -ErrorVariable err -InformationVariable info -OutVariable out
            throw $err
        }
        
        if ($AsJob) {
            $Stack.Job = $job
            $job
        }
        else {
            $job | Wait-Job | Receive-Job -Keep -ErrorVariable err -InformationVariable info -OutVariable out
            $null = $job | Remove-Job
        }
    }
}


$MaxPoolSize = 5

class PoolManager {
    [hashtable]$Docker
    [string[]]$ComposeFiles
    [string]$Service
    [hashtable]$Stacks = @{}
    [ArrayList]$AllJobs = [ArrayList]::New()

    PoolManager([string[]]$ComposeFiles, [string]$Service) {
        $this.ComposeFiles = $ComposeFiles
        $this.Service = $Service
    }

     [Object[]] GetJobs() {
        $jobs = $this.Stacks.Values | Where-Object { $_.Job } | Select-Object Job
        return $jobs
    }

    [Stack[]] GetStacks() {
        return $this.Stacks.Values
    }

    [void] FinishJob($job) {
        $stack = $this.Stacks[$job.Name]
        $test = $stack.Test
        switch ($job.State) {
            'Completed' {
                $stack.Job = $null
                $stack.Test = $null
                $job | Receive-Job
                $job | Remove-Job
                Write-Verbose "Test $($test.RunRelativeDir) completed"
            }

            'Failed' {
                $stack.Job = $null
                $stack.Test = $null
                $err = ''
                $job | Receive-Job -ErrorVariable err
                $job | Remove-Job
                Write-Debug "Test $($test.RunRelativeDir) failed $err"

            }

            default {
                throw "Unknown Job State $($job.State)"
            }
        }
    }
}

function New-PoolManager {
    param (

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )][string[]]$ComposeFiles,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )][string]$Service = 'moodle'
    )

    [PoolManager]::New($ComposeFiles, $Service)
}

function Start-Pool {
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )][PoolManager]$PoolManager,

         [Parameter()][int]$Size
    )

    Write-Verbose "Starting pool size: $Size"

    # Create Stacks
    foreach ($i in 1..$Size) {
        $name = "teststack_$i"
        $stack = New-Stack -Name $name -ComposeFiles $PoolManager.Composefiles -TestService $PoolManager.Service
        $stack | Start-Stack
        $stack | Invoke-Stack -Sh 'sudo chown -R docker /appdata'
        $PoolManager.Stacks.$name = $stack
    }

    Write-Debug 'Pool started'

    # Start Stacks
    # if (-Not $SkipStart) {
    #     foreach ($stack in $PoolManager.Stacks.Values) {
    # $cmd = "$($stack.DCCommand) up --build --detach"
    
    # $job = Start-ThreadJob {
    #     param($stack, $cmd)
    # Invoke-Expression "$($stack.DCCommand) up --build --detach"
    # TODO Find a better way to determine up
    # $stack.Status = 'running'
    # } -ArgumentList $stack, $cmd -Name "start $($stack.Name)"
    # # To do look for errors
    # $job

    # Start-Sleep -Seconds 10
    # foreach ($stack in $PoolManager.Stacks.Values) {
    #     $stack | Invoke-Stack -Sh 'sudo chown -R docker /appdata'
    # }
            
    # $jobs | Wait-Job | Receive-Job | Remove-Job
    # $null = $jobs | Remove-Job
    # }
}

function Stop-Pool {
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )][PoolManager]$PoolManager
    )

    $null = $PoolManager.GetStacks() | Stop-Stack
}

function Get-Stack {
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )][PoolManager]$PoolManager
    )

    $stack = $null
    while (-Not $stack) {
        # Handle any compled and failed jobs
        # $PoolManager.GetStacks() | Select-Object Name, Job | Write-Debug

        # Process any completed jobs
        $PoolManager.GetJobs() | Where-Object { $_.State -in 'Completed', 'Failed' } | ForEach-Object {
            $PoolManager.FinishJob($_)
        }
        
        # foreach ($stack in $PoolManager.GetStacks()) {
        #     if ($stack.Job) {
        #         switch ($stack.Job.State) {
        #             'Completed' {
        #                 # Write-Verbose "get-Stack: $($stack.Test.RunRelativeDir) completed"
        #                 # # Process?
        #                 # $stack.Job = $null
        #                 # $stack.Test = $null
        #                 $PoolManager.FinishJob($stack.Job)
        #             }

        #             'Blocked' {
        #                 Write-Error "$($stack.Test.RunRelativeDir) blocked on stack $($stack.Name)"
        #             }

        #             'Failed' {
        #                 # Write-Debug "get-Stack: found FAILED stack: $($stack.Name)"
        #                 # $stack.Job = $null
        #                 $PoolManager.FinishJob($stack.Job)
        #             }

        #             default {
        #                 Write-Error "Unrecognized Job State $($stack.Name): $($stack.Job.State)"
        #             }
        #         }
        #     }
        #     else {
        #         Write-Debug "Stack $($stack.Name) has no job"
        #     }
        # }

        # Find an open stack
        if ($stack = $PoolManager.GetStacks() | Where-Object { $null -eq $_.Job } | Select-Object -First 1) {
            Write-Debug "Found open stack: $($stack.Name)"
            return $stack
        }
        
        # No available stack, wait for a job to complete
        Write-Debug 'Waiting for a stack'
        $completedJobs = $PoolManager.GetJobs() | Wait-Job -Any
        foreach($job in $completedJobs) {
            $PoolManager.FinishJob($job)
        }
    }
    
    return $stack
}