# using namespace System.Collections

# $MaxPoolSize = 5

# class PoolManager {
#     [hashtable]$Docker
#     [string[]]$ComposeFiles
#     [string]$Service
#     [hashtable]$Stacks = @{}
#     [ArrayList]$AllJobs = [ArrayList]::New()

#     PoolManager([string[]]$ComposeFiles, [string]$Service) {
#         $this.ComposeFiles = $ComposeFiles
#         $this.Service = $Service
#     }

 
#     [Object[]] GetJobs() {
#         $jobs = $this.Stacks.Values | Where-Object { $_.Job } | Select-Object Job
#         return $jobs
#     }

#     [Stack[]] GetStacks() {
#         return $this.Stacks.Values
#     }
# }

# function New-PoolManager {
#     param (

#         [Parameter(
#             Mandatory = $true,
#             ValueFromPipelineByPropertyName = $true
#         )][string[]]$ComposeFiles,

#         [Parameter(
#             Mandatory = $false,
#             ValueFromPipelineByPropertyName = $true
#         )][string]$Service = 'moodle'
#     )

#     [PoolManager]::New($ComposeFiles, $Service)
# }

# function Start-Pool {
#     param (
#         [Parameter(
#             Mandatory = $true,
#             ValueFromPipeline = $true
#         )][PoolManager]$PoolManager,

#         [Parameter()][int]$Size,

#         [switch]$SkipStart
#     )

#     Write-Verbose "Starting pool size: $Size"

#     # Create Stacks
#     foreach ($i in 1..$Size) {
#         $name = "teststack_$i"
#         $stack = [Stack]::New($name, $PoolManager.Composefiles, $PoolManager.Service)
#         $PoolManager.Stacks.$name = $stack
#     }
#     # Start Stacks
#     if (-Not $SkipStart) {
#         foreach ($stack in $PoolManager.Stacks.Values) {
#             # $cmd = "$($stack.DCCommand) up --build --detach"
    
#             # $job = Start-ThreadJob {
#             #     param($stack, $cmd)
#             Invoke-Expression "$($stack.DCCommand) up --build --detach"
#             # TODO Find a better way to determine up
#             $stack.Status = 'running'
#             # } -ArgumentList $stack, $cmd -Name "start $($stack.Name)"
#             # # To do look for errors
#             # $job
#         } 

#         Start-Sleep -Seconds 10
#         foreach ($stack in $PoolManager.Stacks.Values) {
#             $stack | Invoke-Stack -Sh 'sudo chown -R docker /appdata'
#         }
            
#         # $jobs | Wait-Job | Receive-Job | Remove-Job
#         # $null = $jobs | Remove-Job
#     }
#     Write-Debug 'Pool started'
# }

# function Stop-Pool {
#     param (
#         [Parameter(
#             Mandatory = $true,
#             ValueFromPipeline = $true
#         )][PoolManager]$PoolManager
#     )

#     $null = $PoolManager.GetStacks() | Stop-Stack
# }

# function Get-Stack {
#     param (
#         [Parameter(
#             Mandatory = $true,
#             ValueFromPipeline = $true
#         )][PoolManager]$PoolManager
#     )

#     $stack = $null
#     while (-Not $stack) {
#         # Handle any compled and failed jobs
#         $PoolManager.GetStacks() | Select-Object Name, Job | Write-Debug
#         foreach ($stack in $PoolManager.GetStacks()) {
#             if ($stack.Job) {
#                 switch ($stack.Job.State) {
#                     'Completed' {
#                         Write-Debug "get-Stack: found COMPLETED stack: $($stack.Name)"
#                         # Process?
#                         $stack.Job = $null
#                     }

#                     'Blocked' {
#                     }

#                     'Failed' {
#                         Write-Debug "get-Stack: found FAILED stack: $($stack.Name)"
#                         $stack.Job = $null
#                     }

#                     default {
#                     }
#                 }
#             }
#             else {
#                 Write-Debug "Stack $($stack.Name) has no job"
#             }
#         }

#         # Find an open stack
#         if ($stack = $PoolManager.GetStacks() | Where-Object { $null -eq $_.Job } | Select-Object -First 1) {
#             Write-Debug "Found open stack: $($stack.Name)"
#             return $stack
#         }
        
#         # No available stack, wait for a job to complete
#         Write-Debug 'Waiting for a stack'
#         $null = $PoolManager.GetJobs() | Wait-Job -Any
#     }
#     return $stack
# }
