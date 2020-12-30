# Managing Components

This section describes the procedures for adding, updating and removing components.

Two general classes of components are recognized:

- [Managing Components](#managing-components)
  - [Shared Components](#shared-components)
    - [Add a shared component to the LMS](#add-a-shared-component-to-the-lms)
    - [Pull Upstream Changes](#pull-upstream-changes)
    - [Customize a Shared Component](#customize-a-shared-component)
    - [Remove a Shared Component](#remove-a-shared-component)
    - [Push Changes to a Shared Component](#push-changes-to-a-shared-component)
  - [Exclusive Components](#exclusive-components)
    - [Add an Exclusive Component](#add-an-exclusive-component)
    - [Update an Exclusive Component](#update-an-exclusive-component)
    - [Remove an Exclusive Component](#remove-an-exclusive-component)
    - [Convert an Exclusive Component to Shared](#convert-an-exclusive-component-to-shared)
  - [Installing components in DEV2 for Evaluation](#installing-components-in-dev2-for-evaluation)

## Shared Components

Shared Components are managed in external Git repositories and may be used by projects other than the LMS. These components are added and updated from their external (upstream) repository.

### Add a shared component to the LMS

New components are added to the LMS by adding that component as a Git subtree. This allows updates to be incorporated and changes to be pushed back when necessary. The LMSTools Powershell module in this project provides the Add-LMSComponent command.

Every shared component to be added to the LMS must first be defined in the components.csv file. Once added thr Add-LMSComponent command will add that component as a Git Subtree.

Examples:

``` powershell
## Add local_foo at latest commit on master branch
Add-LMSComponent local_foo master

## Add local_foo at specified tag
Add-LMSComponent local_foo v4.1.1
```

### Pull Upstream Changes

Once added via Add-LMSComponent, subsequent executions of the Add-LMSComponent command will pull the specified version of the component into the LMS.

Examples

``` powershell
## Update local_foo to the latest version on its master branch
Add-LMSComponent local_foo master

# Update moodle to MOODLE_310_STABLE
Add-LMSComponent moodle MOODLE_310_STABLE

# Downgrade Moodle
Add-LMSComponent moodle MOODLE_39_STABLE
```

### Customize a Shared Component

In some cases a shared component may need to be modified to fix a bug or add a feature, while still retaining the ability ti pull in upstream changes.

1. Create a branch to manage the changes.

2. Directly modify the component code in the lms codebase.

3. Commit ands push changes to GitLab.

4. When upstream changes are to be incorporated follow the procedure for pulling upstream changes for a shared component.

5. Fix any conflicts that arise from the pull, commit the changes and proceed.

### Remove a Shared Component

Removing a component requires only deleting the component directory and removing any remote information.

Example

``` powershell
## Remove component local_foo installed at moodle/local/foo
cd lms
git rm -rf moodle/local/foo
git add .
git commit -m "Remove local_foo"
Remove-LMSRemote local_foo
```

> A Remove-LMSComponent command could be, but has not yet been, implemented.

### Push Changes to a Shared Component

It is possible to push changes made to a Shared Component back upstream for the component maintainers to consider for adding to the upstream repository. This is how community changes are pushed back upstream for Open Source components. This process uses the Git subtree split command, but the details are not documented here.

## Exclusive Components

Exclusive Components are those exclusive to the LMS. They are not managed in external repositories, even though they may have been first added to the LMS from an external repository. Since they are exclusive to the LMS they are updated only within the LMS codebase itself.

### Add an Exclusive Component

1. Create a branch to manage changes.
2. Create the component directory and files as needed.
3. Test, push and merge.

### Update an Exclusive Component

### Remove an Exclusive Component

Same as [Remove a Shared Component](#remove-a-shared-component).

### Convert an Exclusive Component to Shared

Any subdirectory in the LMS codebase can be split out and pushed to a remote repository using the Git subtree split command. This procedure is not detailed here.

## Installing components in DEV2 for Evaluation

In some cases we may wish to install a plugin in DEV2 to allow testing by the client, but we do not want to include this component in the deployed baseline.

1. Clone the component directly from its repository (do not add as a subtree).

2. Edit the .git\info\exclude file and enter the pathname of the installed location of the component. This path is relative to the lms directory.

Example: Add component format_fntabs from URL `https://github.com/ned-code/moodle-format_fntabs.git` moodle/course/formats/fntabs for testing:

1. Change directory to `E:\wwwroot\CLI_Engage-DEV2_LMS\httpdocs\lms`
2. Clone the source repository to the desired location

    git clone `https://github.com/ned-code/moodle-format_fntabs.git moodle/course/formats/fntabs` moodle/course/formats/fntabs

3. Edit `E:\wwwroot\CLI_Engage_LMS\httpdocs\lms\.git\info\exclude` and add the line `/moodle/course/formats/fntabs` (note the leading slash character).

This will cause git to ignore the added component in this project only (DEV2).

Later, if the component is to be added to the deployable baseline the directory can be deleted, the line removed from the exclude file, and the component can be added to the baseline using the Add-Component method.
