$Behat = Invoke-Command {
    $BehatConfigFile = Join-Path $PSSCriptRoot "../tests/behat.yml"

    $config = Get-Content -Path $BehatConfigFile | ConvertFrom-Yaml

    # $prefix = "/app/lms/moodle/"

    $data = $config.default.suites.default.paths | Group-Object  -AsHashTable {
        $parts = $_ -split "/"
        $key = if ($parts[5] -eq "tests") {
            "moodle/" + $parts[4]
        }
        else {
            "moodle/" + $parts[4] + "/" + $parts[5]
        }
        $file = $_
        $scenarioCount = (Select-String -Path $_ -Pattern "Scenario:").Length
        @('behat', $key, $_, $scenarioCount )
    }

    $subdirs | Sort
    # foreach($dir in $subdirs.GetEnumerator()) | Sort Name

    $a = $subdirs.GetEnumerator() | Sort-Object Name
    $a
}

$Phpunit = {}

$Behat