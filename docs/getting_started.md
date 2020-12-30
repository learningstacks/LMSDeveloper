# Getting Started

This project is designed and documented for a development environment consisting of

- Windows 10
- Windows Subsystem for Linux version 2 (WSL2)
- Powershell 7
- VSCode
- Docker Desktop

Optional components include

- Windows 10 X-Server
- PHPStorm
- Smartgit

## Setup Windows 10

1. [Install Windows Subsystem for Linux version 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

    > The Author works with Ubuntu-18.04.

2. [Install Powershell on the WSL2 distribution you setup in the previous step]. See [Installing PowerShell on Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1).

3. Install Docker Desktop and configure it to use the WSL2 backend. See [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/#develop-with-docker-and-wsl-2)

4. Install VSCode on Windows. See [Setting up Visual Studio Code](https://code.visualstudio.com/docs/setup/setup-overview).

5. Configure VSCode for remote development for both WSL2 and Docker Containers. See TBD.

6. Clone the lms_developer project to your working location

    ```powershell
    git clone https://gitpapl1.uth.tmc.edu/CLI_Engage_Moodle/lms_developer.git
    ```

    For best performance clone this directly to a directory on your WSL2 distribution rather than Windows.

7. Clone the lms codebase to the lms directory under the lms_developer project.

    ```powershell
    git clone https://gitpapl1.uth.tmc.edu/CLI_Engage_Moodle/cliengage_lms.git lms
    ```

8. (Optional) For consistency you can also install the same version of Powershell on Windows, see [Installing PowerShell on Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1). Note that powershell is now available in the Microsoft Store.

## Notes

- This project also works with PHPStorm. Configuring PHPStorm is not documented here.
- SmartGit is recommended as a Git management tool.
- You can configure an X Serbver on windows and install PHPStorm and SMartgit in WSL2 for best performance.

## Recommended VSCode extensions