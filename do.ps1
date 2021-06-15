
param (
    [Parameter(ValueFromRemainingArguments = $true)][string]$Exp
)
$Exp
exit
Set-Content /app/do.log $exp
$stdout = New-TemporaryFile
$stderr = New-TemporaryFile
# $result = Invoke-Expression $exp > $stdout 2> $stderr
$result = @{
    ExitCode = $LASTEXITCODE
    StdOut = [string]$Exp
    StdErr = [string](Get-Content $stderr)
}
# $result = @{
#     ExitCode = $LASTEXITCODE
#     StdOut = [string](Get-Content $stdout)
#     StdErr = [string](Get-Content $stderr)
# }

Remove-Item $stdout
Remove-Item $stdErr
$result | ConvertTo-Json -Depth 2