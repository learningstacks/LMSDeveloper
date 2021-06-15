function Initialize-BehatRun {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'testrun',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0
        )][TestRun]$TestRun
    )

    $BuildDir = "$($TestRun.Paths.Local.RunDir)/behat"
    $FilterSpec = $TestRun.TestSpec.Behat.Filter
    $SegmentBy = $TestRun.TestSpec.Behat.SegmentBy

    # Find the master config file
    $MasterConfigSrcFile = ''
    if (Test-Path "$BuildDir/behat.yml") {
        $MasterConfigSrcFile = "$BuildDir/behat.yml"
    }
    else {
        throw 'Master config file not found'
    }

    # If we are not segmenting just copy the config file
    # TODO We still need to apply the FilterSpecs
    if ($SegmentBy -eq 'None') {
        $segmentDir = "$BuildDir/all"
        if (-Not (Test-Path $segmentdir)) {
            $null = New-Item -ItemType Directory $segmentdir
        }
        Copy-Item $MasterConfigSrcFile "$segmentdir/behat.yml"
    }
    else {

        # Get all paths from the config file as a flattened array
        $BehatConfig = Get-Content -Path $MasterConfigSrcFile | ConvertFrom-Yaml -ErrorAction 'Stop'
        $allPaths = foreach ($suitename in $BehatConfig.default.suites.Keys) {
            $suite = $BehatConfig.default.suites.$suitename
            foreach ($path in [array]$suite.paths) {
                if ($path -is [string]) {
                    $pathobject = @{
                        Path      = ($path -replace '\\', '/') -replace '^.*/lms/moodle/', ''
                        FullPath  = $path
                        OrigSuite = $suitename
                    }
                    $pathobject.Theme = if ($path -match '/theme/') { $suitename } else { 'default' }
                    $pathobject
                }
            }
        }

        # Set the segments
        $allPaths = Set-PathSegments $allPaths 

        # Apply the filter
        $allPaths = $allPaths | Where-Object $FilterSpec

        # Group by theme
        $themes = $allPaths | Group-Object 'Theme' -AsHashTable

        foreach ($pair in $themes.GetEnumerator()) {
            $suitename = $pair.Key
            $paths = $pair.Value
            
            # Setup the suite dir
            $suitedir = "$BuildDir/$suitename"
            if (-Not (Test-Path $suitedir)) {
                $null = New-Item -ItemType Directory $suitedir
            }
            
            # Group the theme paths by specified segment
            $segments = $paths | Group-Object { $_.$SegmentBy } -AsHashTable
            foreach ($pair in $segments.GetEnumerator()) {
                $segmentName = $pair.Key
                $segmentPaths = $pair.Value | ForEach-Object { $_.FullPath }

                # Set up the segment dir
                $segmentDir = "$suitedir/$($segmentName)"
                if (-Not (Test-Path $segmentdir)) {
                    $null = New-Item -ItemType Directory $segmentdir
                }
                
                # Populate the template
                $template = @{}
                $template.default = $BehatConfig.default.Clone() # Shallow clone
                $template.default.suites = @{}
                $template.default.suites.$suitename = $BehatConfig.default.suites.$suitename.Clone()
                $template.default.suites.$suitename.paths = [array]$segmentPaths
                $template | ConvertTo-Yaml | Set-Content -Path "$segmentdir/behat.yml"
                Write-Debug "Created config in $segmentdir"
            }
        }
    }
}

function Initialize-PhpunitRun {
    [CmdletBinding()]
    param (
        [Parameter(
            # ParameterSetName = 'testrun',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0
        )][TestRun]$TestRun

    )

    $BuildDir = "$($TestRun.Paths.Local.RunDir)/phpunit"
    $FilterSpec = $TestRun.TestSpec.Phpunit.Filter
    $SegmentBy = $TestRun.TestSpec.Phpunit.SegmentBy
    $MoodleRunDir = if ($TestRun.Paths.Remote) {
        $TestRun.Paths.Remote.MoodleDir
    }
    else {
        $TestRun.Paths.Local.MoodleDir
    }

    $BuildDir = Resolve-Path $BuildDir -ErrorAction Stop

    # Abort if a lock file is present, no changes allowed
    if (Test-Path "$builddir/locked") {
        throw "$builddir is locked (has a locked file)"
    }

    if ($Reset) {
        Get-ChildItem $BuildDir -Directory | Remove-Item -Recurse
    }

    # Get all test directories from the masterconfig as a flat list
    $DefaultConfig = [xml](Get-Content "$BuildDir/phpunit.xml" -ErrorAction 'Stop')
    $testDirPaths = $DefaultConfig.SelectNodes('//testsuite/directory') | ForEach-Object {
        @{
            Path  = ($_.InnerText -replace '\\', '/').Trim('/')
            Suite = $_.ParentNode.name
        }
    }

    # Assignment segment values
    $testDirPaths = Set-PathSegments -PathObjects $testDirPaths

    # Apply the filter
    $testDirPaths = $testDirPaths | Where-Object $FilterSpec

    
    # Group by a derived segment name
    if ($SegmentBy) {
        $segments = $testDirPaths | Group-Object { $_.$SegmentBy } -AsHashTable
    }
    else {
        $segments = @{
            All = $testDirPaths
        }
    }
 
    # Prepare the default config XML document as a template
    # Set absolute paths for base config
    $DefaultConfig.SelectNodes('//filter//directory') | ForEach-Object {
        $_.InnerText = "$MoodleRunDir/$($_.InnerText)"
    }
    $DefaultConfig.phpunit.bootstrap = "$MoodleRunDir/$($DefaultConfig.phpunit.bootstrap)"
    $DefaultConfig.phpunit.noNamespaceSchemaLocation = "$MoodleRunDir/$($DefaultConfig.phpunit.noNamespaceSchemaLocation)"

    foreach ($segmentGroup in $segments.GetEnumerator()) {
        $segmentname = $segmentGroup.Key -replace '/', '__'
        $segmentTestDirs = $segmentGroup.Value
        $segmentDir = "$BuildDir/$segmentname/"
        if (Test-Path $segmentDir) {
            if ($Force) {
                Remove-Item $segmentDir -Force -Recurse
            }
            else {
                throw "$segmentDir exists and -Force not specified"
            }
        }
        $null = New-Item $segmentDir -ItemType Directory -ErrorAction 'Stop'
        
        $testSuitesNode = $DefaultConfig.CreateElement('testsuites')

        $bySuite = $segmentTestDirs | Group-Object -Property Suite -AsHashTable
        foreach ($testSuiteName in $bySuite.Keys) {
            $testSuiteNode = $DefaultConfig.CreateElement('testsuite')
            $testSuiteNode.SetAttribute('name', $testSuiteName)
            $null = $testSuitesNode.AppendChild($testSuiteNode)
            foreach ($testDir in $bySuite.$testSuiteName) {
                $dirNode = $DefaultConfig.CreateElement('directory')
                $dirNode.InnerText = "$MoodleRunDir/$($testDir.Path)"
                $dirNode.SetAttribute('suffix', '_test.php')
                $testSuiteNode.AppendChild($dirNode) | Out-Null
            }
        }

        $null = $DefaultConfig.phpunit.replaceChild($testSuitesNode, $DefaultConfig.phpunit.testsuites)
        $DefaultConfig.Save("$segmentDir/phpunit.xml")
        Write-Debug "Created config in $segmentdir"
    }
}

function Initialize-TestRun {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'testrun',
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0
        )][Object]$TestRun,

        [switch]$Reset,

        [switch]$Force
    )

 
    $localrunroot = $TestRun.Paths.Local.RunRoot
    $localrundir = "$localrunroot/$($TestRun.RunName)"
    $localbehatrundir = "$localrundir/behat"
    $localphpunitrundir = "$localrundir/phpunit"

    if ($Reset) {
        $localrundir | Remove-Item -Recurse
    }
    
    @($localrundir, $localbehatrundir, $localphpunitrundir) | ForEach-Object {
        if (-Not (Test-Path $_)) { 
            New-Item -ItemType Directory $_ 
        }
    }

    $initPhpunit = ($TestRun.TestSpec.Phpunit) -and (-Not (Test-Path "$localphpunitrundir/phpunit.xml"))
    $initBehat = ($TestRun.TestSpec.Behat) -and (-Not (Test-Path "$localbehatrundir/behat.yml"))

    # Initialize-Run
    if ($initPhpunit -or $InitBehat) {
        Write-Debug 'Starting Docker to initialize'
        if ($TestRun.Docker) {
            # $remoterundir = "$($TestRun.Paths.Remote.RunRoot)/$Run"
            $rundir = $TestRun.Paths.Remote.RunDir
            $moodleDir = $TestRun.Paths.Remote.MoodleDir
            $dataRoot = $TestRun.Paths.Remote.DataRoot
                
            $stack = New-Stack -Name 'init' -ComposeFiles $TestRun.Docker.ComposeFiles
            $result = $stack | Invoke-Stack -Sh "sudo chown -R docker $dataRoot" # put this in entrypoint

            if ($initBehat) {
                $result = $stack | Invoke-Stack -Pwsh 'Initialize-Behat' # TODO Add param CopyConfigToPath
                $result = $stack | Invoke-Stack -Sh "cp $dataroot/behatdata/behatrun/behat/behat.yml $rundir/behat/behat.yml"
                Write-Verbose 'Initialize-Behat complete'
            }
            
            if ($initPhpunit) {
                $result = $stack | Invoke-Stack -Pwsh 'Initialize-Phpunit' # TODO Add param CopyConfigToPath
                $result = $stack | Invoke-Stack -Sh "cp $moodledir/phpunit.xml $rundir/phpunit/phpunit.xml"
                Write-Verbose 'Initialize-Phpunit complete'
            }
            $null = $stack | Stop-Stack
        }
        else {
            $rundir = $TestRun.Paths.Local.RunDir
            $moodleDir = $TestRun.Paths.Local.MoodleDir
            $dataRoot = $TestRun.Paths.Local.DataRoot
            
            if ($initBehat) {
                Initialize-Behat
                Copy-Item "$dataroot/behatdata/behatrun/behat/behat.yml $rundir/behat/behat.yml"
                Write-Verbose 'Initialize-Behat complete'
            }
            
            if ($initPhpunit) {
                Initialize-PhpUnit -Force
                Copy-Item "$moodleDir/phpunit.xml $rundir/phpunit/phpunit.xml"
                Write-Verbose 'Initialize-Phpunit complete'
            }
        }
    }

    if ($TestRun.TestSpec.Phpunit) {
        $TestRun | Initialize-PhpunitRun
        Write-Verbose 'Phpunit configurations created'
    }

    if ($TestRun.TestSpec.Behat) {
        $TestRun | Initialize-BehatRun # -Reset:$Reset -Force:$Force
        Write-Verbose 'Behat configurations created'
    }

    # $TestRun.Tests = $TestRun | Get-Tests
    # $TestRun | ConvertTo-Json -Depth 10 | Out-File "$localrundir/testrun.json"
    # Write-Verbose "$($TestRun.Tests.Count) test segments selected"

    $TestRun
}