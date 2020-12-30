@{
    RootModule         = 'LMSTools.psm1'
    ModuleVersion      = '0.0.1'
    GUID               = 'a9957387-fffa-43b9-a581-a69c35efdba2'
    Author             = 'Terry Campbell'
    CompanyName        = 'Learning Stacks LLC'
    Copyright          = ''
    Description        = 'Contains function for working with the CLIEngage LMS'
    PowerShellVersion  = '6.0'
    RequiredModules    = @()
    RequiredAssemblies = @()
    NestedModules      = @()
    FunctionsToExport  = @(
        'Add-LMSComponent'
        'Add-LMSRemote'
        'Remove-LMSRemote'
        'Initialize-PHPUnit'
        'Invoke-PHPUnit'
        'Initialize-Behat'
        'Invoke-Behat'
        'Get-BehatSummary'
    )
    CmdletsToExport    = @()
    VariablesToExport  = '*'
    AliasesToExport    = '*'
}
