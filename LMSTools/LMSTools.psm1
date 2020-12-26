using namespace System.Collections

$InformationPreference = 'Continue'
$ErrorActionPreference = 'Stop'

$Env:LMSOriginUri = "https://gitpapl1.uth.tmc.edu/CLI_Engage_Moodle/cliengage_lms.git"
$Env:LMSDir = (Join-Path $PSScriptRoot .. lms)
$Env:MoodleDir = Join-Path $Env:LMSDir moodle

function Add-LMSRemote {
    <#

    .SYNOPSIS
        Add a Git remote referencing the named component repository.

    .DESCRIPTION
        The function adds a remote with the name of the component and then fetches the remote.
        It sets the Git fetch comfiguration so that all component tags are grouped by the component name to seperate them from local tags.
        If the remote already exists it is refreshed.

    .PARAMETER Name
        The name of the component. This should be the component name as used by Moodle. It will be used as the name of the remote.
        The component must be defined in the components.csv file.

    .EXAMPLE
        PS> Add-LMSRemote -Name moodle

    #>

    [CmdletBinding()]
    Param (
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

    .PARAMETER Name
        The nmame of the remote to be removed.

    .EXAMPLE
        PS> Remove-LMSRemote moodle

    #>

    [CmdletBinding()]
    Param (
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

    .PARAMETER Name
        The name of the component. This should be the component name as used by Moodle. It will be used as the name of the remote.
        The component must be defined in the components.csv file.

    .PARAMETER CommitRef
        Identifies the specific commit to be added. This can be a label, a branch reference or a commit hash.

    .EXAMPLE
        PS> Add-LMSComponent -Name moodle -Prefix moodle -OriginUri https://github.com/moodle/moodle.git MOODLE_39_STABLE

    .EXAMPLE
        PS> Add-LMSComponent -Name mod_questionnaire -Prefix moodle/mod/questionnaire -OriginUri https://gitpapl1.uth.tmc.edu/CLI_Engage_Moodle/mod_questionnaire.git master

    #>

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]

    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)][string]$Name,
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
    php (Join-Path $Env:MoodleDir "admin/tool/phpunit/cli/init.php")
}

function Invoke-PhpUnit {
    <#

    .SYNOPSIS
        Execute PHPUnit tests.

    .DESCRIPTION
        If a remote with the given name exists it is removed. Then all tags prefixed with the remote name are deleted.

    .PARAMETER Config
        If a configuration name is provided, the confiuration file named phpunit_configname.xml is used to define the tests to be executed.
        If no Config value is provided the phpunit.xml file is used.

        Test results are logged to test_results/phpunit/YYYY-MM-DD_HHMM where the directory name YYY-MM-DD_HHMM is the date and minute the test began.

        After running, test results are summarized in results.csv. This can be loaded into Excel and pivoted for analysis.

    .EXAMPLE
        PS> Invoke-PHPUnit

        This will run all tests found in lms/moodle/phpunit.xml

    .EXAMPLE
        PS> Invoke-PHPUnit elis

        This will run all tests found in lms/moodle/phpunit_elis.xml

    #>
    [CmdletBinding()]
    Param(
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
        Build-TestReport $logdir -ErrorAction Continue
        Pop-Location
    }

}

function Build-TestReport {
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

$ExportedFunctions = @(
    'Add-LMSComponent'
    'Add-LMSRemote'
    'Remove-LMSRemote'
    'Initialize-PHPUnit'
    'Invoke-PHPUnit'
)

Export-ModuleMember -Function $ExportedFunctions
