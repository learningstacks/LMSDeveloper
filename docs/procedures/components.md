# Managing Components

- [Managing Components](#managing-components)
  - [Component Types](#component-types)
  - [Git-sourced Components](#git-sourced-components)
    - [Procedure: Add a Git-sourced component](#procedure-add-a-git-sourced-component)
    - [Procedure: Update a previously added Git-sourced component from its upstream source](#procedure-update-a-previously-added-git-sourced-component-from-its-upstream-source)
    - [Procedure: Customize a Git-sourced component](#procedure-customize-a-git-sourced-component)
    - [Procedure: Incorporate upstream updates into a customized Git-sourced component](#procedure-incorporate-upstream-updates-into-a-customized-git-sourced-component)
    - [Procedure: Remove a Git-sourced component](#procedure-remove-a-git-sourced-component)
    - [Procedure: Push changes to a Git-sourced component back upstream](#procedure-push-changes-to-a-git-sourced-component-back-upstream)
  - [LMS-exclusive Components](#lms-exclusive-components)
    - [Procedure: Add a LMS-exclusive component](#procedure-add-a-lms-exclusive-component)
    - [Procedure: Update a LMS-exclusive component](#procedure-update-a-lms-exclusive-component)
    - [Procedure: Customize a LMS-exclusive component](#procedure-customize-a-lms-exclusive-component)
    - [Procedure: Remove a LMS-exclusive component](#procedure-remove-a-lms-exclusive-component)
    - [Procedure: Convert an Exclusive Component to Shared](#procedure-convert-an-exclusive-component-to-shared)
  - [Zip-sourced components](#zip-sourced-components)
    - [Procedure: Add a Zip-sourced component](#procedure-add-a-zip-sourced-component)
    - [Procedure: Update a previously added Zip-sourced component from its upstream source](#procedure-update-a-previously-added-zip-sourced-component-from-its-upstream-source)
    - [Procedure: Customize a Zip-sourced component](#procedure-customize-a-zip-sourced-component)
    - [Procedure: Incorporate upstream updates into a customized Zip-sourced component](#procedure-incorporate-upstream-updates-into-a-customized-zip-sourced-component)
    - [Procedure: Push changes to a Zip-sourced component back upstream](#procedure-push-changes-to-a-zip-sourced-component-back-upstream)
    - [Procedure: Remove a Zip-sourced component](#procedure-remove-a-zip-sourced-component)
  - [Special procedures](#special-procedures)
    - [Procedure: Install component in DEV2 for Evaluation](#procedure-install-component-in-dev2-for-evaluation)

This section describes the procedures for adding, updating and removing LMS components.

## Component Types

There are several component scenarios that each have distinct management procedures:

1. Git-sourced components: Components managed in and installed and updated from external Git repositories.

2. Zip-sourced components: Components that can be installed only from Zip archives.

3. LMS-exclusive components: Components managed only within the LMS codebase itself.

## Git-sourced Components

Git-sourced components are those available from upstream Git repositories (e.g., GitHub) that can be directly installed and updated from those repositories. These components are added to the LMS and updated using Git subtree methods. Moodle itself is one of these components.

A singular advantage of the subtree approach is that parent components can be updated with a single command without impacting nested components.

For example, the LMS contains these components in a hierarchy:

  | Component | Prefix (install path in LMS codebase) |
  | ---- | ---- |
  | moodle | /moodle |
  | mod_customcert | /moodle/mod/customcert |
  | customcertelement_corecompetencies | /moodle/mod/customcert/element/corecompetencies |

The components moodle and mod_customcert are installed as subtrees directly from their GitHub repositories, while customcertelement_corecompetencies is a custom component managed directly in the LMS codebase. Installing moodle as a subtree allows it to be updated via a simple Add-LMSComponent command without impacting any of the installed plugins at any level. The alternative requires that the developer rebuild the LMS each time moodle is updated by reinstalling every plugin on top of the new moodle version. The same goes for mod_customcert, it can be updated without impacting customcertelement_corecompetencies.

### Procedure: Add a Git-sourced component

1. Update the components.csv file to define the component name, prefix and Git repository URL.
2. Execute the LMSTools powershell module Add-LMSComponent command. Examples:

    ``` powershell
    ## Add local_foo at latest commit on master branch
    Add-LMSComponent local_foo master

    ## Add local_foo at specified tag
    Add-LMSComponent local_foo v4.1.1
    ```

### Procedure: Update a previously added Git-sourced component from its upstream source

1. Execute the LMSTools powershell module Add-LMSComponent command. Examples:

    ``` powershell
    ## Update local_foo to the latest version on its master branch
    Add-LMSComponent local_foo master

    # Update moodle to MOODLE_310_STABLE
    Add-LMSComponent moodle MOODLE_310_STABLE

    # Downgrade Moodle
    Add-LMSComponent moodle MOODLE_39_STABLE
    ```

### Procedure: Customize a Git-sourced component

In some cases a component sourced from GitHub or other upstream repository must be modified, wither to fix a bug or add a feature. These changes are made directly in the LMS codebase.

1. Create a branch to manage the changes.

2. Directly modify the component code in the LMS codebase.

3. Commit ands push changes to GitLab.

### Procedure: Incorporate upstream updates into a customized Git-sourced component

After customizing a Git-sourced components we may still want to merge in upstream changes. This process is the same as for updating the component with the exception that changes we made may conflict with upstream changes. In this case the Developer must resolve all conflicts before LMS changes can be pushed.

1. Create a branch to manage the changes.

2. Pull the upstream component changes using Add-LMSRemote.

3. Fix any conflicts that arise from the pull using standard Git conflict resolution techniques.

4. Commit the changes and push to GitLab.

### Procedure: Remove a Git-sourced component

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

### Procedure: Push changes to a Git-sourced component back upstream

It is possible to push changes made to a Shared Component back upstream for the component maintainers to consider for adding to the upstream repository. This is how community changes are pushed back upstream for Open Source components. This process uses the Git subtree split command, but the details are not documented here.

## LMS-exclusive Components

Exclusive Components are those exclusive to the LMS. They are not managed in external repositories, even though they may have been first added to the LMS from an external repository. Since they are exclusive to the LMS they are updated only within the LMS codebase itself.

### Procedure: Add a LMS-exclusive component

1. Create a branch to manage changes.
2. Update components.csv to define the component name and prefix, leaving the OriginURI blank.
3. Create the component directory at the prefix location.
4. Code and test all required component files.
5. Commit, push, create Merge Request, etc. as for any LMS change.

### Procedure: Update a LMS-exclusive component

All changes to LMS-exclusive components occur directly in the LMS codebase.

1. Create a branch to manage changes.
2. Edit component files as needed, test.
3. Commit, push, create Merge Request, etc. as for any LMS change.

### Procedure: Customize a LMS-exclusive component

Same procedure as Update a LMS-exclusive component.

### Procedure: Remove a LMS-exclusive component

Same procedure as Remove a Git-sourced component.

### Procedure: Convert an Exclusive Component to Shared

Any subdirectory in the LMS codebase can be split out and pushed to a remote repository using the Git subtree split command. This procedure is not detailed here.

## Zip-sourced components

Some third party components (e.g., logstore_xapi) are available from upstream only as Zip archives, they cannot be directly installed from Git repositories.

### Procedure: Add a Zip-sourced component

1. Create a branch to manage changes.
2. Update components.csv to define the component name and prefix, leaving the OriginURI blank.
    > We may want to consider providing a link to the upstream repository from which the Zip arhive was downloaded.
3. Unzip the archive into the directory at the defined location.
4. Commit, push, create Merge Request, etc. as for any LMS change.

### Procedure: Update a previously added Zip-sourced component from its upstream source

1. Create a branch to manage changes.

2. Download the updated archive.

3. Completely replace the original files and directories with the downloaded archive.

    > Do not simply copy the new set of files over the existing set. This may
    > leave behind files that should have been removed which may cause errors.
    > Also note that if there are sub-components under the component to be updated they
    > need to be preserved.
    >
    > One way to manage this is to unzip the updated archive into a temporary directory then use
    > a directory and file diff tool (e.g., Beyond Compare, kdiff3, meld) to ensure the resulting
    > codebase exactly matches the downloaded archive contents.
    >
    > Alternatively, delete the current directory and files and reinstall the archive into that same
    > path.

4. Unzip and the archive into the directory at the defined location.

5. Commit, push, create Merge Request, etc. as for any LMS change.

### Procedure: Customize a Zip-sourced component

Edit the code in place as for procedure Update a LMS-exclusive component.

### Procedure: Incorporate upstream updates into a customized Zip-sourced component

In this case we have to merge the changes introduced by the upstream developers with the changes we have made locally.

Several approaches are possible, but the simplest is to use a directory and file diff tool (e.g., Beyond Compare, kdiff3, meld) to compare the current and updated source and merge upstream updates into the codebase.

### Procedure: Push changes to a Zip-sourced component back upstream

Since the codebase does not track the upstream Git repository the developer will have to clone the upstream repository, make the changes, push a new branch upstream, and submit a Pull Request. Details are not documented here.

### Procedure: Remove a Zip-sourced component

Same procedure as Remove a Git-sourced component, just delete the component directory.

## Special procedures

### Procedure: Install component in DEV2 for Evaluation

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
