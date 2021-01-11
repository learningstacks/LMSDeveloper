# LMSTools

The LMSTools Powershell module provides a number of functions to aid in developing, testing and managing the CLIEngage LMS.

To see a list of available commands with synopsis:

```powershell
Get-Command -Module LMSTools | Get-Help | Select-Object -Property Name,Synopsis
```

To get detailed help on each command, use the Get-Help `<command>` function.

```powershell
Get-Help Add-Component -Full
```

When VSCode launches and opens the project in the container, the module is imported into the user session and the commands are immediately available. In Windows or WSl the user can import the module by using the powershell command `Import-Module ./LMSTools` from the root of this project. This command can also be added to the users Powershell profile to import the module on login.

This module provides the following commands. For detailed help on any function type (in a Powershell terminal) `Get-Help <command> -Full`.

## Avaliable Functions

### Codebase Management Functions

- `Add-LMSComponent` - Adds a component from a remote Git repository to the LMS as a subtree.

- `Add-LMSRemote` - Adds a Git remote referencing the upstream Git repository of a component.

- `Remove-LMSRemote` - Removes a previously added remote and all associated tags. Does not affect the code.

### Testing Functions

- `Initialze-PHPUnit` - Convenience function to run the Moodle PHPUnit init script.

- `Invoke-PHPUnit` - Initializes PHPUnit if required, runs Moodle PHPUnit, generates a CSV file with test results for analysis. Allows selection of alternate configuration files.

- `Publish-PHPUnitTestReport` - Parse the junit.xml files produced by the PHPUnit test run and generate a results.csv file usable in Excel to review test results.

- `Initialize-Behat` - Convenience function to run the Moodle Behat init script.

- `Invoke-Behat` - Initializes Behat if required, runs Behat tests, generates a test report summarizing results and listing failures. Allows selection of specific components and groups of components.

- `Publish-BehatTestReport` - Parse the Behat test results and assemble a text file summarizing results and listing failures.


### Other Functions

- `Enable-XDebug` - Enables XDebug. Linux only.

- `Disable-XDebug` - Disables XDebug. Improves test performance. Called by Invoke-PHPUnit and Invoke-Behat. Linux only.
