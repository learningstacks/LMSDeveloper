# LMS Structure

The LMS codebase has been restructured using subtrees rather than submodules. This provides a number of benefits but also impacts how the Developer works with the codebase.

- Upgrading Moodle can be done with a single command. The Developer no longer has to painstakingly rebuild all submodules on top of a new Moodle release.

- Since the codebase is a single structure without submodules, Merge Requests show all changes and can be meaningfully reviewed and commented prior to approving the MR.

- Deployment is simplified: Removed submodules do not have to be manually deleted; Submodule update is not required.

- Working on a feature that spans components does not require separately branching and managing changes to each submodules. The changes are managed ina  single feature branch at the LMS level.

- It is a bit harder to determine if a component has changed since last incorporated.

- Pushing changes made to a shared component requires use of the Git subtree split command.