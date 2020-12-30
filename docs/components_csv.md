# File: components.csv

The components.csv file defines all components that are available to be added to the LMS as subtrees. In its initial form it defines all components that make up the current LMS. The initial build of the LMS added these components as subtrees.

LMSTools depend on all components to be defined in this file. For example, when running Behat tests the user can specify component groups (e.g., ELIS) to be tested. This file associates components with groups.

This file also allows components to be referred to by name rather than having to provide all details for each command.

## Columns in this file

- `Name` - The component name. For Moodle plugins must be the component name used in the version file for that plugin (e.g., mod_questionnaire).

    >For Moodle the name is "moodle".

- `Group` - Associates the component with one or more groups (e.g., custom, shared, elis). Groups can be used for selecting tests to be run using LMSTools.

- `Prefix` - The relative path to the install location of the component. The prefix "moodle" is added to all prefixes when adding a component. For the mod_questionnaire plugin the prefix would be mod/questionnaire.

- `OriginUri` The URL to the Git repository containing the component code. OriginUri is required only for shared components, or any component being added from an existing Git repository.

- `Notes` - Any commentary on the component.
