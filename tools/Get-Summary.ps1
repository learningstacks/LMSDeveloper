# $resultFile = Join-Path $PSScriptRoot "../test_results/Test Results - behat_community.xml"
# $xdoc = [xml](Get-Content $resultFile)
# $features = $xdoc.SelectNodes("/testrun/suite")
# $paths = $features | ForEach-Object {
#     $fileUri = [uri]$_.locationUrl
#     @{
#         Path = $fileUri.LocalPath
#     }
# }
Import-Module LMSTools -Force


function Get-BehatResults {
    [CmdletBinding()]
    param (
        [Parameter()][string]$ResultsDir
    )

    $resultFiles = Get-ChildItem -Path $ResultsDir -Filter *.log -Recurse
    $resultFiles
}

$behatResultsDir = Join-Path $PSScriptRoot "../test_runs/run_1/behat"
# $behatResults = Get-BehatResults (Join-Path $PSScriptRoot "../test_runs/run_1/behat")
Publish-BehatTestReport -LogDir $behatResultsDir

$a = 1