$localroot = $PSScriptRoot
$remoteroot = '/app'

@{
    Paths  = @{
        Local  = @{
            Root      = $localroot
            RunRoot   = "$localroot/test_runs"
            LmsGitDir = "$LocalRoot/lms"
            MoodleDir = "$LocalRoot/lms/moodle"
            DataRoot  = $null
        }
        Remote = @{
            Root      = $remoteroot
            RunRoot   = "$remoteroot/test_runs"
            LmsGitDir = "$remoteroot/lms"
            MoodleDir = "$remoteroot/lms/moodle"
            DataRoot  = '/appdata'
        }
    }
    Docker = @{
        ComposeFiles   = @(
            "$LocalRoot/dc_test2.yml"
        )
    }
}