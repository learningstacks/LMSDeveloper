
function Get-Tests {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0
        )][hashtable]$TestRun,

        [Parameter()][ScriptBlock]$FilterSpec = { $true }

    )

    begin {
    }

    process {
        $RunDir = $TestRun.Paths.Local.RunDir

        if (-Not (Test-Path -PathType Container -Path $RunDir)) {
            throw "$RunDir does not exist or is not a directory"
        }

        $tests =  & {
            $behat = Get-ChildItem -Directory -Path "$RunDir/behat" -Recurse | Where-Object { Test-Path "$_/behat.yml" } | ForEach-Object {
                @{
                    Type           = 'behat'
                    RunRelativeDir = [System.IO.Path]::GetRelativePath($RunDir, $_ ) 
                } 
            }
            $behat = $behat | Where-Object $TestRun.TestSpec.Behat.Filter

            $phpunit = Get-ChildItem -Directory -Path "$RunDir/phpunit" -Recurse | Where-Object { Test-Path "$_/phpunit.xml" } | ForEach-Object {
                @{
                    Type           = 'phpunit' 
                    RunRelativeDir = [System.IO.Path]::GetRelativePath($RunDir, $_ ) 
                } 
            }
            $phpunit = $phpunit  | Where-Object $TestRun.TestSpec.Phpunit.Filter

            $behat
            $phpunit
        }

        $tests
    }
}