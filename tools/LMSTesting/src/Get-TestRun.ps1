function Get-Run {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0
        )][String]$RunName,

        [hashtable]$Site = (Get-Site)
    )

    $LocalRunDir = "$($global:runsdir)/$RunName"

    @{
        RunSpec  = @{
            Phpunit = @{
                $MasterFile  = ''
                $Segments    = @(

                )
                $Initialized = $null
                $Started     = $null
                $Finished    = $null
                $Results     = @{
                    $Details = @{

                    }
                }
            }
        }
        $Dirs    = @{
            Local   = @{
                # $Root
                # $RunDir
                # $MoodleDir
                # $LmsGitDir
            }
            $Renote = @{
                # $Root
                $Docker = @{

                }
            }
        }
        Name     = $RunName
        LocalDir = $LocalRunDir
        Phpunit  = @{
            TeamCityFile = "$LocalRunDir/phpunit/teamcity.log"
        }
    }
}