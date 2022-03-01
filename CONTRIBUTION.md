# Kinscape team contribution rules

## Branch names

### Story branch name

"Story branch" is a branch that was created for individual story/chore/bug.

Each story branch name should follow the template:

`TRACKER_STORY_ID/BRANCH_NAME`

- `TRACKER_STORY_ID` (required)
  - story id from Jira
- `BRANCH_NAME` (required)
  - meaningful branch name that shortly describes task
  - use hyphens (-) to separate words / numbers in branch name

**Examples:**
```
kin-45/new-translation-server
kin-123/increase-limit-pending-page
```

### Epic branch name

"Epic branch" is a branch that was created for entire epic. It may include
commits and pull requests from multiple Jira stories.

Each epic branch name should follow the template:

`epic-TRACKER_EPIC_ID/BRANCH_NAME`

- `TRACKER_EPIC_ID` (required)
  - epic id from Jira
- `BRANCH_NAME` (required)
  - meaningful branch name that shortly describes task
  - use hyphens (-) to separate words / numbers in branch name

**Examples:**

```
epic-kin-85/reapply-flow
```

## Contribution

### Labels

- use labels to provide more info on PR state (WIP, blocked, question, rebased, etc)

### Code review rules

- any changes should be contributed using pull-requests
  - pull-request should have two blocks
    - description of the feature or bug (e.g. with title `Description` for new
      features, `Problem` for bugs or issues etc.)
    - what was done (with title `Changes` for features, `Fixes` for bugs etc.)
- direct commits into `master`, `develop` or any epic branch are prohibited
- each pull-request should have at least one reviewer assigned
- use [github
  checklist](https://help.github.com/articles/basic-writing-and-formatting-syntax/#task-lists)
  to assign reviewers
- a person who created pull-request is responsible for picking and assigning reviewers
  - keeping pull-request not merged for a long time is bad and it's PR creator's
    responsibility to avoid it
  - may ping reviewers in any way after creation of pull-request and if needed
- any team member can assign himself to the list of reviewers by adding his
  name to checklist
- each assigned person once he/she did
  [review](https://help.github.com/articles/about-pull-request-reviews/) should
  mark checkbox item near his/her name and do one of the following actions
  depending on review results:
  - "Approve" if everything is OK
  - "Request changes" if some improvements should be applied before
    pull-request can be merged
  - provide "Comment" if some improvements could be applied but they are not
    required
  - one of "Approve" or "Request changes" actions is mandatory for first
    reviewer
  - "Dismiss review" usage is allowed only for own review
  - mark pull-request with "blocked", "question" or "WIP" label if it is blocked because of any
    reason (e.g. other pull-request, deployment of some feature to production
    etc.)
- any team member can merge pull-request if
  - at least half of people that were assigned reviewed and approved it
  - continuous integration build passed
  - all requested changes were resolved
  - there is no "WIP" label
- feature / epic branch should be deleted after pull request is merged

### Deployment flow

- pull-requests of individual features or epics should be done into `develop`
  branch
- after pull-request is merged into `develop`, code should be deployed to
  `staging`
- if everything is tested on `staging`, there should be created PR into
  `master` from `develop`
- after pull-request is merged into `master`
  - tag with a version number should be created and pushed to remote (e.g.
    `v0.3.10`)
  - code should be deployed to `production`
