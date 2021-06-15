@{
    RootModule         = 'LMSTesting.psm1'
    ModuleVersion      = '0.1.0'
    GUID               = 'a9957387-fffa-43b9-a581-a69c35efdba2'
    Author             = 'Terry Campbell'
    CompanyName        = 'Learning Stacks LLC'
    Copyright          = '(c) Learning Stacks LLC. All rights reserved.'
    Description        = 'Contains functions for working with the Moodle LMS'
    PowerShellVersion  = '7.0'
    RequiredModules    = @(
        (Join-Path $PSScriptRoot "../../LMSTools")
    )
    RequiredAssemblies = @()
    NestedModules      = @()
    FunctionsToExport  = @(
        '*'
    )
    CmdletsToExport    = @()
    VariablesToExport  = '*'
    AliasesToExport    = '*'
    PrivateData        = @{
        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @(
                "Moodle"
            )

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
