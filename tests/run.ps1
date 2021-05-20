Import-Module /app/LMSTools -Force

$InformationPreference = 'Continue'
$DebugPreference = 'Continue'
$VerbosePreference = 'Continue'

$root = $PSScriptRoot

$tests = [array](Get-Tests -Type Behat -From "behat_local__datahub.yml")



$behatconfigs = "/app/tests/configs/behat"
foreach($config in (Get-ChildItem -Path $behatconfigs -Filter '*.yml')) {
    $basename = ([System.IO.FileSystemInfo]$config).BaseName
    invoke-behat `
        -Config $config.FullName `
        -LogDir /app/test_runs/run_1/behat/$basename `
        -RunName $basename `
        -NoReport
}
