
# class Stack {
#     [string]$Name
#     [array]$ComposeFiles
#     [string]$TestService
#     [string]$TestServiceContainerId
#     [string]$DCCommand
#     [string]$ServiceCmd
#     [string]$Status
#     [Object]$Job
#     [string]$Comment

#     Stack([string]$Name, [array]$ComposeFiles, [string]$TestService) {
#         $this.ComposeFiles = $ComposeFiles
#         $this.Name = $Name
#         $this.TestService = $TestService
#         $this.Status = 'stopped'

#         # Construct base docker compose command
#         $f = $ComposeFiles | ForEach-Object { "-f $_" }
#         $this.DCCommand = "docker-compose -p $Name $f"
#     }

#     # [void] Start() {
#     #     Write-Debug 'Stack.Start'
#     #     $this.Compose('up --build --detach')
#     #     Write-Debug 'sleep'
#     #     Start-Sleep -Seconds 5
#     #     Write-Debug 'Slept'
#     #     $this.Status = 'running'
#     # }

#     # [void] Stop() {
#     #     Write-Debug 'Stack.Stop'
#     #     $this.Compose('down')
#     #     $this.Status = 'stopped'
#     # }

#     [string] GetExecCmd([string]$cmd) {
#         return "$($this.DCCommand) exec $($this.TestService) $cmd"
#     }

#     [string] GetUpCmd([string]$cmd) {
#         return "$($this.DCCommand) up --build --detach"
#     }

#     [string] GetDownCmd([string]$cmd) {
#         return "$($this.DCCommand) down"
#     }

#     # [string[]] Invoke([string]$Expression) {
#     #     Write-Debug "Stack.Invoke($Expression)"
#     #     $result = Invoke-Expression $Expression
#     #     return $result
#     # }

#     # [string[]] Compose($cmd) {
#     #     return $this.Invoke("$($this.DCCommand) $cmd")
#     # }

#     # [string[]] Exec([string]$cmd) {
#     #     Write-Debug "Stack.Exec($cmd)"
#     #     if ($this.Status -eq 'stopped') { $this.Start() }
#     #     $result = $this.Compose("exec $($this.TestService) $cmd")
#     #     return $result
#     # }

#     # [Object] StartTest([string]$cmd) {
#     #     Write-Debug "Stack.StartTest($cmd)"
#     #     if ($this.Status -eq 'stopped') { $this.Start() }
#     #     $exp = $this.GetExecCmd($cmd)
#     #     # $this.Job = Start-ThreadJob -Name $this.Name {
#     #     #     param([string]$Exp)
#     #     #     Invoke-Expression $Exp
#     #     # } -ArgumentList $exp
#     #     # return $this.Job
#     #     return $null
#     # }
# }