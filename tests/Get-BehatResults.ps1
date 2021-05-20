Import-Module (Join-Path $PSScriptRoot "../LMSTools") -Force
$summary, $failedScenarios = Get-BehatResults -ResultsDir /home/terry/workspace/uth/restructure/LMS_Developer_Terry/test_runs/run_1/behat
"FAILURES"
$summary | Where-Object Status -eq 'FAILED' | Select-Object Component,ScenariosFailed | Format-Table