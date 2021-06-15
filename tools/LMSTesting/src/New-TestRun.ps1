# class PathSet {
#     [string]$Root
#     [string]$DataRoot
#     [string]$LMSGitDir
#     [string]$MoodleDir
#     [string]$RunRoot
#     [string]$RunDir
# }
# class Foo {
#   [ValidateNotNullOrEmpty()][string]$RunName
#   [PathSet]$PathsLocal
#   [PathSet]$PathsRemote
#   [hashtable]$Docker
#   [hashtable]$TestSpec
# }

class TestRun {
    [ValidateNotNullOrEmpty()][string]$RunName
    [hashtable]$Paths
    [hashtable]$Docker
    [hashtable]$TestSpec
    [hashtable]$Site # redundant
}

function BuildBehat($BuildDir, $SegmentBy, $FilterSpec) {

}

function BuildPhpunit($BuildDir, $SegmentBy, $FilterSpec) {

}

function BuildTestRun {

}
function New-TestRun {
    [CmdletBinding()]
    param (
        [Parameter(
            ParameterSetName = 'runname',
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]$RunName,

        [Parameter()][hashtable]$Site = (Get-Site),

        [Parameter()]
        [hashtable]$TestSpec = @{
            CommitRef = 'master'
            Phpunit   = @{
                SegmentBy = 'Group'
                Filter    = { $true }
            }
            Behat     = @{
                SegmentBy = 'Component'
                Filter    = { $true }
            }
        },

        # [Parameter()]
        # [string]$PhpunitBy,

        # [Parameter()]
        # [string]$BehatBy,

        # [Parameter()]
        # [ScriptBlock]$FilterSpec = { $true },


        [switch]$Reset,

        [switch]$Force
    )

    $Site.Paths.Local.RunDir = "$($Site.Paths.Local.RunRoot)/$RunName"
    if ($Site.Paths.Remote) {
        $Site.Paths.Remote.RunDir = "$($Site.Paths.Remote.RunRoot)/$RunName"
    }

    # Prepare, reset, verify
    $testrun = [TestRun]::New()
    $testrun.RunName     = $RunName
    $testrun.TestSpec = $TestSpec
    $testrun.Paths = $Site.Paths
    if ($Site.Docker) {
        $testrun.Docker = $Site.Docker
    }

    $testrun = Initialize-TestRun -TestRun $testrun -Reset:$Reset -Force:$Force
    
    $testRun

}