
function Build-FailedBehatConfig {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = "Phpstorm",
            Mandatory = $true
        )][string]$PhpstormResultsFile,

        [Parameter(
            Mandatory = $true
        )][string]$BehatConfigFile,

        [Parameter(
            Mandatory = $true
        )][string]$OutFile
    )

    if ($PhpstormResultsFile) {
        if (-Not (Test-Path $PhpstormResultsFile)) {
            throw "PhpstormResultsFile not found: $PhpstormResultsFile"
        }
    }

    $xResults = [xml](Get-Content $PhpstormResultsFile)
    $scenarios = $xResults.SelectNodes("/testrun/suite/suite[@status != 'passed']")
    $paths = $scenarios | ForEach-Object {
        $fileUri = [uri]$_.locationUrl
        $fileUri.LocalPath
    }

    $config = Get-Content $BehatConfigFile | ConvertFrom-Yaml
    $config.default.suites.default.paths = $paths

    $config | ConvertTo-Yaml | Set-Content -Path $OutFile
}


Build-FailedBehatConfig `
    -PhpstormResultsFile (Join-Path $PSScriptRoot "../test_results/Test Results - behat_moodle part 1.xml") `
    -BehatConfigFile (Join-Path $PSScriptRoot "../tests/behat_moodle.yml") `
    -OutFile (Join-Path $PSScriptRoot "../tests/behat_moodle_failed_1.yml")