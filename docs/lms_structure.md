# LMS Structure

The LMS codebase has been restructured using subtrees rather than submodules. This provides a number of benefits over the use of submodules.

Upgrading Moodle can be done with a single command. The Developer no longer has to painstakingly rebuild all submodules on top of a new Moodle release.

    ```powershell
    # e.g., Update Moodle to latest 39
    Add-Component moodle MOODLE_39_STABLE
    ```

Since the codebase is a single structure without submodules, Merge Requests show all changes and can be meaningfully reviewed and commented prior to approving the MR. Working on a feature that spans components does not require separately branching and managing changes to each submodules. The changes are managed in a single feature branch at the LMS level.

Deployment is simplified: Removed submodules do not have to be manually deleted; Submodule update is not required.

The structure of the LMS codebase is a bit different, as Moodle itself is added as a subtree.
