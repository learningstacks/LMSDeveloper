using namespace System.Collections

$InformationPreference = 'Continue'
$ErrorActionPreference = 'Stop'

$Env:LMSOriginUri = "https://gitpapl1.uth.tmc.edu/CLI_Engage_Moodle/cliengage_lms.git"
$Env:LMSDir = (Join-Path $PSScriptRoot .. lms)
$Env:MoodleDir = Join-Path $Env:LMSDir moodle
$Env:BehatdataDir = "/appdata/behatdata"

function Add-LMSRemote {
    <#
    .SYNOPSIS
        Add a Git remote referencing the named component repository.

    .DESCRIPTION
        The function adds a remote with the name of the component and then fetches the remote. Adding a remote to the upstream repository
        of a componment allows the Developer to view the history of that component to examine upstream changes, etc.

        The component must be defined in components.csv.

        It sets the Git fetch comfiguration so that all component tags are grouped by the component name to seperate them from local tags.

        If the remote already exists it is refreshed, fetching all updates.

    .EXAMPLE
        Add-LMSRemote -Name moodle

        Adds a remote named moodle and fetches all branches and tags. Tags are grouped by the component name.
        For example: moodle/3.7.1.

    #>

    [CmdletBinding()]
    Param (
        # The name of the component. This should be the component name as used by Moodle. It will be used as the name of the remote.
        # The component must be defined in the components.csv file.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][string]$Name
    )

    begin {
        $comps = Import-Components -ErrorAction 'Stop'
    }

    process {
        if (-Not $comps.ContainsKey($Name)) {
            Write-Error "Component $Name is not defined in components.csv"
        }

        $OriginUri = $comps.$Name.OriginUri

        # If remote does not yet exist add it
        if (-Not (git -C $Env:LMSDir remote | Select-String $Name)) {
            Write-Information "Adding remote $name"

            # Configure the remote
            git -C $Env:LMSDir config --local ("remote.$name.url") $OriginUri
            git -C $Env:LMSDir config --local ("remote.$name.fetch") "+refs/heads/*:refs/remotes/$name/*"

            # Place tags under the remote name to group them
            git -C $Env:LMSDir config --local --add ("remote.$name.fetch") "+refs/tags/*:refs/tags/$name/*"
            git -C $Env:LMSDir config --local ("remote.$name.tagopt") "--no-tags"
        }

        # If remote exists and URI has changed, update it
        elseif ((git -C $Env:LMSDir remote get-url $name) -ne $OriginUri) {
            Write-Information "Updating remote $name"
            git -C $Env:LMSDir config --local ("remote.$name.url") $uri
        }

        # Refresh the remote, fetching all branches and tags
        git -C $Env:LMSDir remote update $Name
    }

}

function Remove-LMSRemote {
    <#

    .SYNOPSIS
        Remove the named remote and all associated tags.

    .DESCRIPTION
        If a remote with the given name exists it is removed. Then all tags prefixed with the remote name are deleted.

    .EXAMPLE
        Remove-LMSRemote moodle

        Removes the remote named 'moodle' and all tags named 'moodle/*'

        .EXAMPLE
        Remove-LMSRemote mod_certificate

        Removes the remote named 'mod_certificate' and all tags named 'mod_certificate/*'.

    #>

    [CmdletBinding()]
    Param (
        # The name of the component whose remote is to be removed.
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName = $true)][string]$Name
    )

    if ((git -C $Env:LMSDir remote | Select-String $Name)) {
        Write-Information "Removing remote $Name"
        git -C $Env:LMSDir remote remove $Name
    }

    # Delete all tags associated with the remote
    (git -C $Env:LMSDir tag -l) | Select-String -Pattern "^$Name/.*$" | ForEach-Object {
        git -C $Env:LMSDir tag -d $_
    }
}


function Import-Components {
    [OutputType('HashTable')]

    $ComponentsFile = (Join-Path $PSScriptRoot .. components.csv)
    if (-Not (Test-Path $ComponentsFile)) {
        throw "Components file $ComponentsFile not found"
    }

    $comps = @{}
    Get-Content $ComponentsFile | ConvertFrom-Csv | ForEach-Object {
        $comps.($_.Name) = $_
    }
    $comps
}


function Add-LMSComponent {
    <#
    .SYNOPSIS
        Add or update an LMS component.

    .DESCRIPTION
        The function looks up component details in the components.csv file.
        If the prefix directory does not exist the component is added as a Git subtree.
        If the prefix directory exists the component is updated to the specified commit.

    .EXAMPLE
        Add-LMSComponent -Name moodle -CommitRef MOODLE_39_STABLE

    .EXAMPLE
        Add-LMSComponent -Name mod_questionnaire -CommitRef v3.1.1
    #>

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]

    Param(
        # The name of the component. This should be the component name as used by Moodle. It will be used as the name of the remote.
        # The component must be defined in the components.csv file.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][string]$Name,

        # The specific version (commit) of the componen to be added or updated. This vcan be a branch name, a commit has, or a rag name.
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)][string]$CommitRef
    )

    begin {
        $comps = Import-Components
    }

    process {

        if (-Not $comps.ContainsKey($Name)) {
            Write-Error "Component $Name is not defined in components.csv"
        }

        $comp = $comps.$Name
        $prefix = "moodle/" + $comp.Prefix
        $uri = $comp.OriginUri

        if (Test-Path (Join-Path $Env:LMSDir $prefix)) {
            $op = 'pull'
            $action = "Update component"
        }
        else {
            $op = "add"
            $action = "Add component"
        }

        $commitmsg = @(
            "$action $Name"
            ""
            "From: $uri"
            "To Directory: $prefix"
            "Commit: $CommitRef"
        ) -join "`n"
        $prompt = @(
            "`nComponent name: $Name"
            "`nFrom: $uri"
            "`nTo directory: $prefix"
            "`nCommit: $CommitRef"
        )
        if ($PSCmdlet.ShouldProcess($prompt, $action)) {
            Invoke-Command {
                git -C $Env:LMSDir subtree $op --prefix=$prefix $uri $CommitRef --squash -m $commitmsg
            }
        }
    }
}

function Disable-XDebug {
    if ($IsLinux) {
        sudo phpdismod xdebug
        sudo service apache2 reload
    }
}

function Enable-XDebug {
    if ($IsLinux) {
        sudo phpenmod xdebug
        sudo service apache2 reload
    }
}

function Initialize-PhpUnit {
    <#
    .SYNOPSIS
        Executes the Moodle PHPUnit init script

    .EXAMPLE
        Initialize-PHPUnit
    #>

    php (Join-Path $Env:MoodleDir "admin/tool/phpunit/cli/init.php")
}

function Invoke-PhpUnit {
    <#

    .SYNOPSIS
        Execute PHPUnit tests.

    .DESCRIPTION
        If a remote with the given name exists it is removed. Then all tags prefixed with the remote name are deleted.

        Test results are logged to test_results/phpunit/YYYY-MM-DD_HHMM where the directory name YYY-MM-DD_HHMM is the date and minute the test began.

        After running, test results are summarized in results.csv. This can be loaded into Excel and pivoted for analysis.

    .EXAMPLE
        Invoke-PHPUnit

        Run all unit tests

    .EXAMPLE
        Invoke-PHPUnit elis

        Run all tests found in lms/moodle/phpunit_elis.xml
    #>
    [CmdletBinding()]
    Param(
        # If a configuration name is provided, the confiuration file named phpunit_configname.xml is used to define the tests to be executed.
        # If no Config value is provided the default phpunit.xml file is used.
        [Parameter(ValueFromPipeline = $true, Position = 0)][string]$Config = "",
        [switch]$Log
    )

    begin {
        Disable-XDebug
        Initialize-PhpUnit
        $phpunit = Join-Path $Env:MoodleDir "vendor/bin/phpunit"
        $resultsDir = Join-Path $PSScriptRoot .. test_results
        $logdir = Join-Path $resultsDir phpunit (Get-Date -Format 'yyyy-MM-dd_HHmm')
        New-Item -ItemType Directory $logdir -Force
        Push-Location $Env:MoodleDir
        $logfile = Join-Path $logdir "stdout.log"
    }

    process {
        if ($Config) {
            $configfile = "phpunit_$config.xml"
            $log_junit = Join-Path $logdir "phpunit_$($config)_junit.xml"
        }
        else {
            $configfile = "phpunit.xml"
            $log_junit = Join-Path $logdir "phpunit_junit.xml"
        }

        if (-Not (Test-Path $configfile)) {
            Write-Error Unable to find configuration file $configfile
        }
        else {
            if ($Log) {
                & $phpunit -c $configfile --log-junit $log_junit >> $logfile 2>&1
            }
            else {
                & $phpunit -c $configfile --log-junit $log_junit
            }
        }
    }

    end {
        Build-PhpunitTestReport $logdir -ErrorAction Continue
        Pop-Location
    }

}

function Build-PhpunitTestReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)][string]$Dir
    )

    function GetResult([XmlNode]$testcase) {
        if (-Not $testcase.HasChildNodes) { return @('pass', '', '') }
        $res = $testcase.ChildNodes[0]
        $msglines = ($res.InnerText -split '\r?\n').Trim()
        $result = $res.LocalName
        $subtype = ""

        if ($res.LocalName -eq 'error') {
            $subtype = $res.type
        }

        return @($result, $subtype, ($msglines -join '#####'))
    }

    $results = [System.Collections.ArrayList]::new()

    Get-ChildItem -Path $Dir '*_junit.xml' | ForEach-Object {
        $file = $_
        [xml]$xdoc = Get-Content $file
        if ($xdoc) {
            $xdoc.SelectNodes('//testcase') | foreach-object {
                $testcase = $_

                if ($testcase.name -match '^(?<method>.+) with data set (?<dataset>.+)$') {
                    $method = $Matches.method
                    $dataset = $Matches.dataset
                    $class = $testcase.class
                    $testfile = $testcase.file
                    $suite = $testcase.ParentNode.ParentNode.ParentNode.name
                }
                else {
                    $method = $testcase.name
                    $dataset = ""
                    $class = $testcase.class
                    $testfile = $testcase.file
                    $suite = $testcase.ParentNode.ParentNode.name
                }

                $result, $subtype, $msg = GetResult($_)

                $results.Add([PSCustomObject]@{
                        ConfigFile    = $file
                        Suite         = $suite
                        Testfile      = $testfile
                        Class         = $class
                        Method        = $method
                        DataSet       = $dataSet
                        Result        = $result
                        ResultSubtype = $subtype
                        Message       = $msg
                    }
                )
            }
        }
    }

    $outfile = Join-Path $Dir results.csv
    $results | Select-Object -Property * | ConvertTo-Csv | Set-Content $outfile -Force
}


function Initialize-Behat {
    <#
    .SYNOPSIS
        Executes the Moodle Behat init script.

    .EXAMPLE
        Initialize-Behat
    #>

    php (Join-Path $Env:MoodleDir "admin/tool/behat/cli/init.php")
    # Initialize-BehatConfig
}

function Initialize-BehatConfig {

    Write-Information "Preparing custom Behat configuration file to test only plugins"
    $b = Get-Content (Join-Path $Env:BehatdataDir behatrun behat behat.yml) | ConvertFrom-Yaml
    $comps = Import-Components
    $pluginPrefixes = $comps.Values | Where-Object -Property Name -NE 'moodle' | ForEach-Object { $_.Prefix }
    $exp = "/moodle/" + "(" + ($pluginPrefixes -join '|') + ")"
    $b.default.suites.default.paths = ($b.default.suites.default.paths -match $exp) | Sort-Object
    $b.plugins = @{
        suites = @{
            default = @{
                paths = @($b.default.suites.default.paths[0])
            }
        }
    }

    # foreach ($comp in $comps) {

    #     if ($comp.Name -eq 'moodle') {
    #         # $b.default.suites.moodle = @{
    #         #     contexts = $defaultsuite.contexts
    #         # }
    #     }
    #     else {
    #         $name = $comp.Name
    #         $paths = $defaultsuite.paths -match $exp
    #         $b.default.suites.$name = @{
    #             paths    = $paths
    #             contexts = $defaultsuite.contexts
    #         }
    #     }
    # }

    # $b.default.suites.default.paths = @()

    $b | ConvertTo-Yaml | Set-Content /app/test_results/behat_plugins.yml -force
}

function Invoke-Behat {
    <#

    .SYNOPSIS
        Execute Benat tests.

    .DESCRIPTION
        Initializes Behat then tests the components defined by the parameters.
        Test results are stored under test_results/behat in a time-stamped directory.

    .EXAMPLE
        Invoke-Behat

        Test all plugins

    .EXAMPLE
        Invoke-Behat -PluginGroup elis

        Test all ELIS plugins

        .EXAMPLE
        Invoke-Behat -Plugin mod_certificate,mod_customcert

        Test two plugins

    #>
    [CmdletBinding()]
    Param(
        # The Behat configuration file to use. Defaults to the one generated by Moodle.
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
        [string]$ConfigFile = (Join-Path $Env:BehatdataDir behatrun behat behat.yml),

        # Defines the plugin groups to be tested (groups are defined in components.csv).
        # By default no groups are included
        # Excludes Moodle
        [Parameter(Mandatory = $false)]
        [string[]]$Group = @(),

        # Defines specific plugins to be tested by plugin name. Can be regular expression (e.g., .* to test all)
        # By default all plugins will be tested
        # Excludes Moodle
        [Parameter(Mandatory = $false)]
        [string[]]$Plugin = '.*'
    )

    begin {
        Disable-XDebug
        Initialize-Behat

        $behat = Join-Path $Env:MoodleDir "vendor/bin/behat"
        $resultsDir = Join-Path $PSScriptRoot .. test_results
        $logdir = Join-Path $resultsDir behat (Get-Date -Format 'yyyy-MM-dd_HHmm')
        New-Item -ItemType Directory $logdir -Force
        Push-Location $Env:MoodleDir
        $logfile = Join-Path $logdir "test_results.log"

        $comps = Import-Components
        $compsToTest = @()
        if ($PluginGroup) {
            $exp = $PluginGroup -join "|"
            $c = $comps.values | Where-Object { ($_.Group -match $exp) -And ($_.Name -ne 'moodle') }
            $compsToTest = $compsToTest + $c
        }

        if ($Plugin) {
            $exp = $Plugin -join "|"
            $c = $comps.values | Where-Object { ($_.Name -match $exp) -And ($_.Name -ne 'moodle') }
            $compsToTest = $compsToTest + $c
        }

        $compsToTest = $compsToTest | Select-Object -Property Name -Unique
        $compsToTest = $compsToTest | Where-Object { Test-Path (Join-Path $Env:MoodleDir $_.Prefix) } | Sort-Object -Property Name

        if (-Not $compsToTest) {
            $compsToTest = $comps.values | Where-Object { $_.Name -ne 'moodle' }
        }

        $defaultConfig = Join-Path $Env:BehatdataDir behatrun behat behat.yml
        $OnCompNum = 1
    }

    process {
        if (-Not (Test-Path $Configfile)) {
            Write-Error Unable to find configuration file $configfile
        }


        else {
            Write-Information "`nBeginning Test"
            if ($Log) {
                & $behat --config $Configfile --format junit --out $logdir >> $logfile 2>&1
            }
            else {
                # & $behat --config $Configfile --tags --format=pretty #--out=$prettyfile --format=moodle_progress
                foreach ($comp in $compsToTest) {
                    $tag = "@" + $comp.Name
                    # $logfile = Join-Path $logdir ($comp.Name + '.log')

                    Write-Information "Testing $($comp.name) ($OnCompNum of $($compsToTest.Count))"
                    @(
                        ""
                        "----------------------------------------"
                        "Component: " + $comp.Name
                        "----------------------------------------"
                    ) | Out-File $logfile -Append
                    & $behat --config=$defaultConfig --tags=$tag  --format=moodle_progress --out=std | Out-File $logfile -Append

                    $OnCompNum++
                }
            }
        }
    }

    end {
        Write-Information "`nTest Complete"
        $summary = Get-BehatTestSummary $logfile
        $ReportFile = Join-Path (Split-Path $logfile) 'test_report.txt'
        $summary.SummaryCounts | Format-List | Out-File -Path $ReportFile -Force
        $summary.ComponentSummary | Sort-Object -Property Status | Format-Table | Out-File -Path $ReportFile -Append
        (Get-Content $logfile) | Out-File -Path $ReportFile -Append
        Pop-Location

        $summary.SummaryCounts | Format-List | Out-String | Write-Information
    }

}

function Get-BehatTestSummary {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)][string]$File
    )

    $TestResults = Get-Content $File
    $lines = $TestResults -match "^(Component:|(No|[0-9]+) scenarios|(No|[0-9]+) steps)"

    function getCounts([string]$line) {
        $result = @{
            Total     = 0
            Passed    = 0
            Failed    = 0
            Undefined = 0
            Skipped   = 0
        }

        if ($line -match '^(?<num>[0-9]+)') { $result.Total = [Int32]$Matches.num }
        if ($line -match '(?<num>[0-9]+) passed') { $result.Passed = [Int32]$Matches.num }
        if ($line -match '(?<num>[0-9]+) failed') { $result.Failed = [Int32]$Matches.num }
        if ($line -match '(?<num>[0-9]+) undefined') { $result.Undefined = [Int32]$Matches.num }
        if ($line -match '(?<num>[0-9]+) skipped') { $result.Skipped = [Int32]$Matches.num }

        return $result
    }

    $ComponentSummary = [System.Collections.ArrayList]::new()

    for ($i = 0; $i -lt $lines.Count; $i += 3 ) {
        $compLine = $lines[$i]
        $scenLine = $lines[$i + 1]
        $stepLine = $lines[$i + 2]

        if (-Not ($compline -match '^Component: (?<name>.*)$')) {
            Write-Error "Line '$compLine' does not define a component"
        }
        $compName = $Matches.name

        if (-Not ($scenLine -match '(No|[0-9]+) scenarios')) {
            Write-Error "Line '$scenLine' does not define scenario counts"
        }

        $scenarios = getCounts($scenLine)

        if (-Not ($stepLine -match '(No|[0-9]+) steps')) {
            Write-Error "Line '$stepLine' does not define step counts"
        }

        $steps = getCounts($stepLine)
        $status = if ($scenarios.total -eq 0) { "NO TESTS" } elseif ($scenarios.failed -gt 0) { "FAILED" } else { "PASSED" }

        $null = $ComponentSummary.Add(
            [PSCustomObject]@{
                Component       = $compName
                Status          = $status
                ScenariosTotal  = $scenarios.Total
                ScenariosPassed = $scenarios.Passed
                ScenariosFailed = $scenarios.Failed
                # ScenariosSkipped = $scenarios.Skipped
                StepsTotal      = $steps.Total
                StepsPassed     = $steps.Passed
                StepsFailed     = $steps.Failed
                StepsUndefined  = $steps.Undefined
                StepsSkipped    = $steps.Skipped
            }
        )
    }

    $SummaryCounts = [PSCustomObject]@{
        "Total Components"         = $ComponentSummary.Count
        "Components Passed"        = ( $ComponentSummary | Where-Object { $_.Status -eq "PASSED" }).Count
        "Components Failed"        = ( $ComponentSummary | Where-Object { $_.Status -eq "FAILED" }).Count
        "Components Without Tests" = ( $ComponentSummary | Where-Object { $_.Status -eq "NO TESTS" }).Count
        'Failed Scenarios'         = ( $ComponentSummary | Measure-Object -Property ScenariosFailed -Sum).Sum
        'Failed Steps'             = ( $ComponentSummary | Measure-Object -Property StepsFailed -Sum).Sum
        'Skipped Steps'            = ( $ComponentSummary | Measure-Object -Property StepsSkipped -Sum).Sum
        'Undefined Steps'          = ( $ComponentSummary | Measure-Object -Property StepsUndefined -Sum).Sum
    }

    @{
        TestLogFile      = $File
        SummaryCounts    = $SummaryCounts
        ComponentSummary = $ComponentSummary
    }

}

# $ExportedFunctions = @(
#     # Manage components
#     'Add-LMSComponent'
#     'Add-LMSRemote'
#     'Remove-LMSRemote'

#     # PHPUnit testing
#     'Initialize-PHPUnit'
#     'Invoke-PHPUnit'

#     # Behat testing
#     'Initialize-Behat'
#     'Invoke-Behat'
#     'Get-BehatSummary'
# )

Export-ModuleMember -Function *
