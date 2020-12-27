# 1. CLIEngage LMS Development

## 1.1. Introduction

This project provides development tools for working with the CLIEngage_LMS. It is designed to work best using Windows 10 with the Windows Subsystem for Linux version 2 (WSL2), Docker Containers, and VSCode. It is also designed to work with the LMS codebase restructured to use subtrees for shared modules rather than submodules.

- [1. CLIEngage LMS Development](#1-cliengage-lms-development)
  - [1.1. Introduction](#11-introduction)
    - [1.1.1. Git Subtrees](#111-git-subtrees)
    - [1.1.2. Docker Containers](#112-docker-containers)
  - [1.2. Getting Started](#12-getting-started)
    - [1.2.1. Setup Windows 10](#121-setup-windows-10)
    - [1.2.2. Recommended VSCode extensions](#122-recommended-vscode-extensions)
    - [1.2.3. Project Structure](#123-project-structure)
  - [1.3. Development Procedures](#13-development-procedures)
    - [1.3.1. Github Flow](#131-github-flow)
    - [1.3.2. LMSTools](#132-lmstools)
    - [1.3.3. components.csv](#133-componentscsv)
    - [1.3.4. Managing Shared Components](#134-managing-shared-components)
      - [1.3.4.1. Add a shared component](#1341-add-a-shared-component)
      - [1.3.4.2. Incorporate shared component updates](#1342-incorporate-shared-component-updates)
      - [1.3.4.3. Customize a shared component](#1343-customize-a-shared-component)
    - [1.3.5. Managing Custom Components](#135-managing-custom-components)
      - [1.3.5.1. Create a new custom component](#1351-create-a-new-custom-component)
    - [1.3.6. Remove a Component](#136-remove-a-component)
    - [1.3.7. Installing components in DEV2 for testing](#137-installing-components-in-dev2-for-testing)
    - [1.3.8. Managing baselines and deployments](#138-managing-baselines-and-deployments)
      - [1.3.8.1. Deploy master branch to DEV2](#1381-deploy-master-branch-to-dev2)
      - [1.3.8.2. Deploy Release Candidates to UAT](#1382-deploy-release-candidates-to-uat)
      - [1.3.8.3. Deploy Releases to PROD](#1383-deploy-releases-to-prod)
  - [1.4. References](#14-references)

### 1.1.1. Git Subtrees

The LMS codebase has been restructured using subtrees rather than submodules. This provides a number of benefits but also impacts how the Developer works with the codebase.

- Upgrading Moodle can be done with a single command. The Developer no longer has to painstakingly rebuild all submodules on top of a new Moodle release.

- Since the codebase is a single structure without submodules, Merge Requests show all changes and can be meaningfully reviewed and commented prior to approving the MR.

- Deployment is simplified: Removed submodules do not have to be manually deleted; Submodule update is not required.

- Working on a feature that spans components does not require separately branching and managing changes to each submodules. The changes are managed ina  single feature branch at the LMS level.

- It is a bit harder to determine if a component has changed since last incorporated.

- Pushing changes made to a shared component requires use of the Git subtree split command.

### 1.1.2. Docker Containers

This project is designed to be used with Docker containers. Developing with containers provides a number of advantages:

- Testing with a different PHP version is as simple as changing an environment variable and restarting the containers

- You do not need to install any applications other than Docker on your PC.

- The Docker-Compose.yml file included in this projects configures and connects all containers required to develop the LMS and run PHPUnit and Behat tests. It also configures a a mail catcher program to allow testing of email processes.

You can develop without containers by installing and configuring IIS, MySQL, Selenium, PHP
and other tools directly in Windows 10, although this is complex to set up and less flexible and is not documented here.

## 1.2. Getting Started

This project is designed and documented for a development environment consisting of

- Windows 10
- Windows Subsystem for Linux version 2 (WSL2)
- Powershell 7
- VSCode
- Docker Desktop

Optional components include

- Windows 10 X-Server

### 1.2.1. Setup Windows 10

1. Install Powershell core

2. Install  Windows Subsystem for Linux version 2. See [Windows Subsystem for Linux Installation Guide for Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

3. Install Powershell on the WSL2 distribution you setup in the previous step. See [Installing PowerShell on Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1).

4. Install Docker Desktop and configure it to use the WSL2 backend. See [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/#develop-with-docker-and-wsl-2)

5. Install VSCode on Windows. See [Setting up Visual Studio Code](https://code.visualstudio.com/docs/setup/setup-overview).

6. Configure VSCode for remote development for both WSL2 and Docker Containers. See TBD.

7. Clone the lms_developer project from `https://gitpapl1.uth.tmc.edu/CLI_Engage_Moodle/lms_developer.git`. For best performance clone this directly to WSL2 storage rather than Windows.

8. Clone the lms codebase to the lms directory under the lms_developer project.

For consistency you can also install the same version of Powershell on Windows, see [Installing PowerShell on Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1). Note that powershell is now available in the Microsoft Store.

It can also be used with PHPStorm. Configuring PHPStorm is documented here.

SmartGit is recommended as a Git management tool. Alternatively you can use the command line.

### 1.2.2. Recommended VSCode extensions

### 1.2.3. Project Structure

- `lms_developer`
  - `/.devcontainer` -  Special directory used by VSCode when working with containers. See [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers).
  - `/.containers` - Defines the configuration of custom containers used in this project.
  - `/lms` - The LMS codebase is cloned to this location. LMSTools and scripts expect the root of the LMS Git repository to be located here.
  - `/components.csv` - This file defines the details of all available components, particularly shared components. See [components.csv](#133-componentscsv).
  - `/test_results` - When running unit tests using LMSTools (e.g., Invoke-PHPUnit), test results are logged to subdirectories under this folder.
  - `/LMSTools` - A Powershell module containing functions to aid development. THis module is auto imported into the user session when the container is launched, so the user can immediately start using the provided functions.

## 1.3. Development Procedures

This section provides instructions for performing specific Development procedures.

### 1.3.1. Github Flow

The recommended development workflow follows the [Github Flow](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/github-flow) model.

- The master branch is protected in GitLab and can be updated only via Merge Request. The master branch is always deployed to DEV2 when it is updated.

- All development should occur on the Developers PC in a feature ot issue branch. All changes should be full tested before pushing to GitLab and submitting a Merge Request.

- Merge Requests are intended to be reviewed and approved by at least one other Developer before approving the Merge Request. This is intended to ensure that changes to not regress fixes made by other developers.

> Other alternatives include the [GitLab Flow](GitLab Flow) model.

### 1.3.2. LMSTools

This project contains a Powershell module in the LMSTools directory.

### 1.3.3. components.csv

The components.csv file defines all components that are added to the LMS as subtrees. In its initial form it defines all components that make up the current LMS. The initial build of the LMS added these components as subtrees.

Going forward however, only shared components, those being managed in separate Git repositories need to be defined here. Custom components that are used exclusively in the LMS do not need to be managed in external repositories.

Any component to be added to the LMS must first be defined in this file.
LMSTools look up component details in this file by name.

Columns in this file:

- `Name` - The component name. For Moodle plugins must be the component name used in the version file for that plugin (e.g., mod_questionnaire).

    >For Moodle the name is "moodle".

- `Prefix` - The relative path to the install location of the component. The prefix "moodle" is added to all prefixes when adding a component. For the mod_questionnaire plugin the prefix would be mod/questionnaire.

- `OriginUri` The URL to the Git repository containing the component code.

### 1.3.4. Managing Shared Components

Shared components are used in projects other than the LMS. Shared components include components pulled in from GitHub, as well as custom components that are shared between the LMS and other systems (less likely). Important distinctions when working with shared components:

- Changes made to the component by others may need to be pulled into the LMS, For example, updates made to GitHub components.

- Changes made to the components locally may have to be pushed back to the shared component for use by others.

#### 1.3.4.1. Add a shared component

New components are added to the LMS by adding that component as a Git subtree. This allows updates to be incorporated and changes to be pushed back when necessary. The LMSTools Powershell module in this project provides the Add-LMSComponent command.

Every shared component to be added to the LMS must first be defined in the components.csv file. Once added thr Add-LMSComponent command will add that component as a Git Subtree.

Examples:

``` powershell
## Add local_foo at latest commit on master branch
Add-LMSComponent local_foo master

## Add local_foo at specified tag
Add-LMSComponent local_foo v4.1.1
```

#### 1.3.4.2. Incorporate shared component updates

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

#### 1.3.4.3. Customize a shared component

In some cases a shared component may need to be modified to fix a bug or add a feature, while still retaining the ability ti pull in upstream changes.

1. Create a branch to manage the changes.

2. Directly modify the component code in the lms codebase.

3. Commit ands push changes to GitLab.

4. When upstream changes are to be incorporated follow the procedure for pulling upstream changes for a shared component.

5. Fix any conflicts that arise from the pull, commit the changes and proceed.

### 1.3.5. Managing Custom Components

Custom components are those that are unique to the LMS and not expected to be shared with other projects. These components can be managed entirely within the LMS codebase and do not need to be setup as separate Git repositories. For example, the ELIS components no longer need to be managed separately in GitLab.

> If necessary, any directory tree within the LMS can be split out as a separate component that can be pushed to a separate repository. This procedure is not documented here. See Git subtree split documentation for details.

#### 1.3.5.1. Create a new custom component

1. Create a branch to manage changes.
2. Create the component directory and files as needed.
3. Test, push and merge.

### 1.3.6. Remove a Component

Removing a component requires only deleting the component directory and removing any remote information. This applies to shared and custom components.

Example

``` powershell
## Remove component local_foo installed at moodle/local/foo
cd lms
git rm -rf moodle/local/foo
git add .
git commit -m "Remove local_foo"

# Use LMSTools to clean up any remote information related to the component
# Applies only to shared components
Remove-LMSRemote local_foo
```

### 1.3.7. Installing components in DEV2 for testing

In some cases we may wish to install a plugin in DEV2 to allow testing by the client, but we do not want to include this component in the deployed baseline.

1. Clone the components directly from its repository (do not add as a subtree).
2. Edit the .git\info\exclude file and enter the pathname of the installed location of the component. This path is relative to the lms directory.

Example: Add component format_fntabs from URL `https://github.com/ned-code/moodle-format_fntabs.git` moodle/course/formats/fntabs for testing:

1. Change directory to `E:\wwwroot\CLI_Engage-DEV2_LMS\httpdocs\lms`
2. Clone the source repository to the desired location

    git clone `https://github.com/ned-code/moodle-format_fntabs.git moodle/course/formats/fntabs` moodle/course/formats/fntabs

3. Edit `E:\wwwroot\CLI_Engage_LMS\httpdocs\lms\.git\info\exclude` and add the line `/moodle/course/formats/fntabs` (note the leading slash character).

This will cause git to ignore the added component in this project only (DEV2).

Later, if the component is to be added to the deployable baseline the directory can be deleted, the line removed from the exclude file, and the component can be added to the baseline using the Add-Component method.

### 1.3.8. Managing baselines and deployments

#### 1.3.8.1. Deploy master branch to DEV2

The master branch is deployed to DEV2 whenever it is updated. The only way to update this branch in GitLab is via Merge Request.

All development should take place on the Developer's PC in a feature or other branch. Once the changes to be deployed have been thoroughly tested:

1. Push the feature branch to GitLab

2. Create a Merge Request that will merge this branch into the Master branch.

3. Assign the reviewer/approver.

4. The reviewers reviews all changes that will be introduced by the Merge and either approves the Merge or comments on the Merge.

5. The Developer makes changes as required and re-pushes the feature branch. This will update the Merge Request.

6. Once approved, the master branch is updated in GitLab and it is automatically deployed to DEV2.

#### 1.3.8.2. Deploy Release Candidates to UAT

Release Candidates are identified by adding and pushing a tag whose name matches the regular expression.
/^CLI_[0-9]+\.[0-9]+\.[0-9]-RC.*$/. Examples include CLI_6.0.0-RC1-Alpha, CLI_6.0.1-RC1.

This example will identify the currently checked out commit as Release Candidate CLI_6.0.1-RC1, will push that tag to GitLab which will then create a UAT deployment pipeline.

``` powershell
# Identify production release 6.0.1 and trigger the deployment pipeline
git tag CLI_6.0.1-RC1 -m "Release 6.0.1 candidate 1"
git push origin CLI_6.0.1-RC1
```

When the time comes to actually deploy the release candidate to UAT:

1. Access GitLab.
2. View pipeline for the cliengage_lms project.
3. Manually trigger the pipeline.

#### 1.3.8.3. Deploy Releases to PROD

Releases are identified by adding and pushing a tag whose name matches the regular expression.
/^CLI_[0-9]+\.[0-9]+\.[0-9]$/. Examples include CLI_6.0.0, CLI_6.0.1.

This example will identify the currently checked out commit as Production Release 6.0.1, will push that tag to GitLab which will then create a production deployment pipeline.

``` powershell
# Identify production release 6.0.1 and trigger the deployment pipeline
git tag CLI_6.0.1 -m "Release 6.0.1"
git push origin CLI_6.0.1
```

When the time comes to actually deploy the release:

1. Access GitLab.
2. View pipeline for the cliengage_lms project.
3. Manually trigger the pipeline.

## 1.4. References

- [Git Subtree Survival Tips](https://www.sourcefield.nl/post/git-subtree-survival-tips/) provides some tips for working with subtrees.
- [VSCode - Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)

[VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview.
