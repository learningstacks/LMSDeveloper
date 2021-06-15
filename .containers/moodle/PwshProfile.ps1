Import-Module -Name /app/LMSTools -Force
$Env:PATH = '/app/lms/moodle/vendor/bin:' + $Env:PATH

$phpconfigs = '/usr/local/etc/php/conf.d'
$xdebugenabledconfig = 'docker-php-ext-xdebug.ini'
$xdebugdisabledconfig = 'docker-php-ext-xdebug.ini.disabled'

function Disable-Xdebug {
    if (-Not (Test-Path $phpconfigs/$xdebugenabledconfig)) {
        Write-Host 'xdebug disabled'
    }
    elseif (Test-Path $phpconfigs/$xdebugdisabledconfig) {
        # Already have a disabled copy, just delete the enabled version
        sudo pwsh -Command Remove-Item $phpconfigs/$xdebugenabledconfig
        Write-Host 'xdebug disabled'
    }
    else {
        sudo pwsh -Command Rename-Item $phpconfigs/$xdebugenabledconfig $xdebugdisabledconfig
        Write-Host 'xdebug disabled'
    }
}

function Enable-Xdebug {    
    if (Test-Path $phpconfigs/$xdebugenabledconfig) {
        Write-Host 'xdebug enabled'
    }
    elseif (Test-Path $phpconfigs/$xdebugdisabledconfig) {
        sudo pwsh -Command Rename-Item $phpconfigs/$xdebugdisabledconfig $xdebugenabledconfig
        Write-Host 'xdebug enabled'
    }
    else {
        Write-Error 'xdebug config file not found'
    }
}

function Test-Xdebug {
    $xon = php -v | Select-String 'with Xdebug'
    if ($xon) {
        Write-Host "Xdebug enabled $xon"
    }
    else {
        Write-Host 'Xdebug disabled'
    }
}

Test-Xdebug