
Import-Module LMSTools -Force

# function Get-PathPrefix
# {
#     [CmdletBinding()]
#     param (
#         [Parameter()]
#         [string]
#         $Path,

#         [Parameter()]
#         [string]
#         $Prefix
#     )

#     if ($Path.StartsWith($Prefix))
#     {
#         $Path = $Path -replace $Prefix, ""
#     }
#     $parts = $Path.Trim("/") -split "/"
#     $parts = $_ -split "/"
#     if ($parts[1] -eq "tests")
#     {
#         "moodle/" + $parts[0]
#     }
#     else
#     {
#         "moodle/" + $parts[0] + "/" + $parts[1]
#     }
# }

function GetSegment([string]$path, [string]$Trim = "") {
    $moodleRelativePath = $path -replace $Trim, ""
    $parts = $moodleRelativePath -split "/"
    $prefix = if ($parts[1] -eq "tests")
    {
        $parts[0]
    }
    elseif ($parts[0] -eq 'admin' -and $parts[1] -eq 'tool') {
        $parts[0] + "/" + $parts[1] + $parts[2]
    }
    else
    {
        $parts[0] + "/" + $parts[1]
    }
}

function Get-BehatTests
{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )][hashtable]$BehatConfig,

        [Parameter(
            Mandatory = $true
        )][string]$Trim,

        [Parameter(
        )][hashtable]$LmsConfig = (Get-LmsConfig)

    )

    $paths = @()
    foreach ($suite in $BehatConfig.default.suites.Values)
    {
        if ($suite.paths.Count -gt -0)
        {
            $paths += [array]$suite.paths
        }
    }
    $paths = $paths | Get-Unique

    $data = foreach ($path in $paths)
    {
        # $moodleRelativePath = $path -replace $Trim, ""
        # $parts = $moodleRelativePath -split "/"
        # $prefix = if ($parts[1] -eq "tests")
        # {
        #     $parts[0]
        # }
        # else
        # {
        #     $parts[0] + "/" + $parts[1]
        # }

        @{
            Type      = "Behat"
            Prefix    = GetSegment $path '/app/lms/moodle/'
            File      = $moodleRelativePath
            TestCount = (Select-String -Path (Join-Path $LmsConfig.MoodleDir $moodleRelativePath) -Pattern "Scenario:").Length
        }
    }

    $data
}

function Get-PhpunitTests
{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )][xml]$PhpunitConfig,

        [Parameter(
        )][hashtable]$LmsConfig = (Get-LmsConfig)
    )


    # $prefix = "/app/lms/moodle/"

    Push-Location $LmsConfig.MoodleDir
    $paths = @()
    foreach ($dir in $PhpunitConfig.SelectNodes("//directory"))
    {
        $dirPath = Join-Path $LmsConfig.MoodleDir $dir.InnerText
        if (Test-Path $dirPath)
        {
            $files = Get-ChildItem -Path $dirPath -Filter "*_test.php"
            $p = foreach ($file in $files)
            {
                ($file.ToString() -replace $LmsConfig.MoodleDir, "").TrimStart("/")
            }

            $paths += $p
        }
    }
    Pop-Location

    $data = foreach ($path in $paths)
    {
        # $parts = $path -split "/"
        # $prefix = if ($parts[1] -eq "tests")
        # {
        #     $parts[0]
        # }
        # else
        # {
        #     $parts[0] + "/" + $parts[1]
        # }

        @{
            Type      = "Phpunit"
            Prefix    = GetSegment $path
            File      = $path
            TestCount = (Select-String -Path (Join-Path $LmsConfig.MoodleDir $path) -Pattern "function test_").Length
        }
    }

    $data

}

function Get-BehatResults
{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $TestDir
    )
    $behatResultsDir = Join-Path $TestDir "results/behat"
    $files = $dir | Get-ChildItem -Filter "*.xml"
    $files | ForEach-Object {
        $xdoc = [xml]($_ | Get-Content)
        $features = $xdoc.SelectNodes("/testrun/suite")

    }
}

$LmsConfig = Get-LmsConfig

$TestDir = Join-Path $PSSCriptRoot "../tests/sandbox"
if (Test-Path $TestDir) {
    Remove-Item $TestDir -Recurse -Force
}
New-Item -ItemType Directory $TestDir
New-Item -ItemType Directory "$TestDir/configs"
New-Item -ItemType Directory "$TestDir/configs/phpunit"
New-Item -ItemType Directory "$TestDir/configs/behat"

if ($true)
{

    $BehatConfigPath = Join-Path $PSScriptRoot "../tests/behat.yml"
    $BehatConfig = Get-Content -Path $BehatConfigPath | ConvertFrom-Yaml
    $behatTests = Get-BehatTests -BehatConfig $BehatConfig -Trim "/app/lms/moodle/" -LmsConfig $LmsConfig

    # ($behatTests + $PhpunitTests) | Select-Object -Property Prefix, Type, File, TestCount | Sort-Object Prefix | Format-Table

    # Build configs
    $suiteNames = $BehatConfig.default.suites.Keys.Clone()
    foreach ($suitename in $suitenames)
    {
        if ($suitename -ne "default")
        {
            $BehatConfig.default.suites.Remove($suitename)
        }
    }

    $behatDirs = $behatTests | Group-Object -Property Prefix -AsHashTable
    foreach ($test in $behatDirs.GetEnumerator())
    {
        $configName = "behat_" + ($test.Name -replace "/", "__") + ".yml"
        $paths = $test.Value | ForEach-Object {
            $LmsConfig.MoodleDir.TrimEnd("/") + "/" + $_.File
        }
        $BehatConfig.default.suites.default.paths = [array]$paths
        $path = "$TestDir/configs/behat/$configName"
        $BehatConfig | ConvertTo-Yaml | Set-Content -Path $path
    }

}



# PHPUNIT
$settings = [System.Xml.XmlWriterSettings]::new()
$settings.Indent = $true;
$settings.OmitXmlDeclaration = $true;
$settings.NewLineOnAttributes = $false;

$PhpunitConfigPath = Join-Path $PSSCriptRoot "../lms/moodle/phpunit.xml"
$PhpunitConfig = [xml](Get-Content -Path $PhpunitConfigPath)
$phpunitTests = Get-PhpunitTests -PhpunitConfig $PhpunitConfig -LmsConfig $LmsConfig
$phpunitDirs = $phpunitTests | Group-Object -Property Prefix -AsHashTable

# Set absolute paths for base config
$PhpunitConfig.phpunit.bootstrap = $LmsConfig.MoodleDir + "/" + $PhpunitConfig.phpunit.bootstrap
$PhpunitConfig.phpunit.noNamespaceSchemaLocation = $LmsConfig.MoodleDir + "/" + $PhpunitConfig.phpunit.noNamespaceSchemaLocation
$PhpunitConfig.SelectNodes("/phpunit/filter//directory") | ForEach-Object {
    $_.InnerText = $LmsConfig.MoodleDir + "/" +  $_.InnerText
}

foreach ($test in $phpunitDirs.GetEnumerator())
{
    $suitename = ($test.Name -replace "/", "__")
    $configName = "phpunit_$suitename.xml"
    $paths = $test.Value | ForEach-Object {
        $LmsConfig.MoodleDir.TrimEnd("/") + "/" + $_.File
    }

    $testsuites = $PhpunitConfig.CreateElement("testsuites")
    $testsuite = $PhpunitConfig.CreateElement("testsuite")
    $testsuite.SetAttribute('name', $suitename)
    $null = $testsuites.AppendChild($testsuite)
    foreach ($path in $paths)
    {
        $file = $PhpunitConfig.CreateElement("file")
        $file.InnerText = $path
        $null = $testsuite.AppendChild($file)
    }
    $null = $PhpunitConfig.phpunit.replaceChild($testsuites, $PhpunitConfig.phpunit.testsuites)

    $configPath = "$TestDir/configs/phpunit/$configName"
    $writer = [System.Xml.XmlWriter]::Create($configPath, $settings)
    $PhpunitConfig.WriteTo($writer)
    $writer.flush()
    $writer.close()
}



