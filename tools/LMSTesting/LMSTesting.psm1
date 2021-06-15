using namespace System.Collections
using namespace System.Xml

Get-ChildItem (Join-Path $PSScriptRoot "classes" "*.ps1") -Recurse | ForEach-Object {
    . $_
}

Get-ChildItem (Join-Path $PSScriptRoot "src" "*.ps1") -Recurse | ForEach-Object {
    . $_
}