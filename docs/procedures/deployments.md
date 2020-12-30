# Managing baselines and deployments

## Branching and Labeling Practices

The recommended development workflow follows the [Github Flow](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/github-flow) model.

- The master branch is protected in GitLab and can be updated only via Merge Request. The master branch is always deployed to DEV2 when it is updated.

- All development should occur on the Developers PC in a feature ot issue branch. All changes should be full tested before pushing to GitLab and submitting a Merge Request.

- Merge Requests are intended to be reviewed and approved by at least one other Developer before approving the Merge Request. This is intended to ensure that changes to not regress fixes made by other developers.

> Other alternatives include the [GitLab Flow](GitLab Flow) model.
>
## DEV2 Deployments

The master branch is deployed to DEV2 whenever it is updated. The only way to update this branch in GitLab is via Merge Request.

All development should take place on the Developer's PC in a feature or other branch. Once the changes to be deployed have been thoroughly tested:

1. Push the feature branch to GitLab

2. Create a Merge Request that will merge this branch into the Master branch.

3. Assign the reviewer/approver.

4. The reviewers reviews all changes that will be introduced by the Merge and either approves the Merge or comments on the Merge.

5. The Developer makes changes as required and re-pushes the feature branch. This will update the Merge Request.

6. Once approved, the master branch is updated in GitLab and it is automatically deployed to DEV2.

## UAT Deployments

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

## PROD Deployments

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
