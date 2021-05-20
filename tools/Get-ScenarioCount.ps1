

# Invoke-BehatJob {
#     param(
#         $LMSconfig
#         $Stack
#         $MasterBehatConfig
#         $ComponentsToTest = "moodle"
#     )

#     begin {
#         # Prepare a job file to be picked iup in the container

#     }

#     Process {
#         Invoke-Stack $stack
#     }

#     end {

#     }
# }


# function Measure-Scenarios {
#     param(
#         [Parameter(
#             ParameterSetName = "job"
#             Mandatory = $true
#             ValueFromPipeline = $true
#         )][BehatJob]$BehatJob

#         [Parameter(
#             ValueFromPipelineByPropertyName = $true
#         )][string]$MasterBehatConfig
#     )
    $MasterConfig = Join-Path $PSScriptRoot "../tests/behat_moodle.yml"
    $master = Get-Content -Path $MasterConfig | ConvertFrom-Yaml
    $scenarioCount = 0
    foreach ($path in $master.default.suites.default.paths ) {
        $p = $path -replace "/app/lms/moodle", (Join-Path $PSScriptRoot "../lms/moodle")
        $scenarios = Select-String -Path $p -Pattern "Scenario:"
        $scenarioCount += $scenarios.Count
    }
     $ScenarioCount
    # $master.default.suites.default.paths | Select-String -Path $path -Pattern "Scenario:" -AllMatches
# }
