function Get-Site {
    $lmsconfig = Get-LmsConfig
    # # $global:localroot = Split-Path $PSScriptRoot -Parent
    # # $global:moodledir = Join-Path $localroot 'lms/moodle'
    # # $global:localdataroot = Join-Path $localroot 'lms/data'
    # # $global:localrunsdir = Join-Path $localroot 'testruns'
    # # $phpdir = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\server\php\php-7.2.34-nts-Win32-VC15-x64')).ToString()
    # # $paths = $Env:PATH -split ';' | Where-Object { ($_ -notmatch 'php ') -and ($_.trim() -ne '') }
    # # $Env:PATH = (@($phpdir) + $paths) -join ';'
    
    # $site = @{}
    # $site.Local = @{
    #     Root    = $localroot
    #     RunRoot = "$localroot/test_runs"
    # }
        
    # $site.Remote = @{
    #     Root    = $localroot
    #     RunRoot = "$localroot/test_runs"
    # }
            
    # $site.LocalRoot = $localroot
    # $site.LocalRunRoot = "$localroot/test_runs"
    # $site.docker = @{
    #     ComposeFiles   = @(
    #         "$LocalRoot/dc_test2.yml"
    #     )
    #     RemoteRoot     = $remoteroot
    #     RemoteRunRoot  = "$remoteroot/test_runs"
    #     RemoteDataRoot = '/appdata'
    # }
                    
    $remoteRoot = '/app'
    $localRoot = $lmsconfig.LocalRoot

    $site = @{
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
            ComposeFiles = @(
                "$LocalRoot/dc_test2.yml"
            )
            Service = 'moodle'
        }
    }

    $site
}