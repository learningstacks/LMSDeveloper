# Project Structure

- `lms_developer` - The directory to which this project was cloned

  - `/.devcontainer` -  Special directory used by VSCode when working with containers. See [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers).

  - `/.containers` - Defines the configuration of custom containers used in this project. See [Docker Containers](./docker.md).

  - `/lms` - The LMS codebase is cloned to this location. LMSTools and scripts expect the root of the LMS Git repository to be located here. See [LMS Structure](./lms_structure.md).

  - `/components.csv` - This file defines the details of all available components, particularly shared components. See [components.csv](./components_csv.md).

  - `/test_results` - When running unit tests using LMSTools (e.g., Invoke-PHPUnit), test results are logged to subdirectories under this folder.

  - `/LMSTools` - A Powershell module containing functions to aid development. THis module is auto imported into the user session when the container is launched, so the user can immediately start using the provided functions. See [LMSTools](../LMSTools/README.md).
