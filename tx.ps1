$dir = '/usr/local/etc/php/conf.d'
$enabled = 'docker-php-ext-xdebug.ini'
$disabled = 'docker-php-ext-xdebug.ini.disabled'

if (Test-Path "$dir/$enabled") {
    Rename-Item "$dir/$enabled" $disabled
    Write-Host 'xdebug disabled'
}
elseif (Test-Path "$dir/$disabled") {
    Rename-Item "$dir/$disabled" $enabled
    Write-Host 'xdebug enabled'
}
else {
    Write-Error 'File not found'
}
