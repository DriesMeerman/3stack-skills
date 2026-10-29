# Ready to merge

Shared by [review.md](review.md) and [merge-ready](../merge-ready/SKILL.md). The label
`ready-to-merge` tells the owner and `/merge-ready` that a PR can go in. GitHub does not let
the author approve their own PR, and the agents post as the owner, so the label is the
signal instead of an approval.

## The rules

A draft PR is never ready. A PR is ready when it is out of draft and all of these hold:

1. The latest Sol or Opus review covers the current PR head: its `commit_id` equals
   `headRefOid`. Commits after the review are allowed only when each one is a review fix
   with a resolved thread and a test. A fix that changes only docs or Markdown needs no
   test.
2. Every review thread is resolved, and the "Review fixes" comment is posted. A review with
   no findings needs neither.
3. The author ran the project's test command on the current head and it passed
   ([project-rules.md](project-rules.md)). The "Review fixes" comment records the result, or
   the ready line does when there are no fixes. When CI runs on pull requests, every
   required check on the head is green too. When it does not, the PR needs no CI result:
   the merge-ready train runs the full suite before anything merges.
4. The PR is mergeable with its base: `mergeable` is `MERGEABLE`, not `CONFLICTING`.
5. No "Needs your decision" or "Left for the owner" item is unanswered. An owner answer
   given in the PR or in the session counts once the PR body or a comment records it.
6. For a stacked PR, the base PR is merged or itself labelled `ready-to-merge`.

## Checking them

`<n>` is the PR number. `gh api` fills in `{owner}` and `{repo}` from the current checkout.

```sh
gh pr view <n> --json isDraft,headRefOid,baseRefName,mergeable,labels,files,body,statusCheckRollup
gh api repos/{owner}/{repo}/pulls/<n>/reviews --jq '[.[] | select(.body | test("^(>[^\\n]*\\n)*\\n*\\*\\*(Codex|Opus) review"))] | last | {commit_id, submitted_at}'
gh api repos/{owner}/{repo}/pulls/<n>/commits --jq '.[] | [.sha[0:7], .commit.message | split("\n")[0]] | @tsv'
gh api graphql -F owner='{owner}' -F name='{repo}' -F n=<n> -f query='query($owner: String!, $name: String!, $n: Int!) { repository(owner: $owner, name: $name) { pullRequest(number: $n) { reviewThreads(first: 100) { nodes { isResolved } } } } }' --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved | not)] | length'
gh pr view <n> --comments
```

`mergeable` can read `UNKNOWN` for a minute after a push. Ask again before deciding.

## Labelling

Create the label once if it is missing:

```sh
gh label create ready-to-merge --color 0e8a16 --description "Reviewed, local tests pass, no open owner questions"
```

When all rules hold, add `gh pr edit <n> --add-label ready-to-merge` and say which checks
passed. Put it as the last line of the "Review fixes" comment:

```
Ready to merge: review covers the head, all threads resolved, tests pass locally, no conflicts, no open owner questions.
```

The review body may start with the [leaving-pr-comments](../leaving-pr-comments/SKILL.md)
callout; the query above skips it. The ready line, like every comment a skill posts, starts
with that callout.

With no findings there is no "Review fixes" comment, so post that line alone with
`gh pr comment`. Name the run that applied, such as "full suite passes locally" or "CI is
green on the head", and "base PR #<m> is ready" for a stacked one. Leave out how the review
ran.

Take the label off with `gh pr edit <n> --remove-label ready-to-merge` as soon as a rule stops
holding: the PR goes back to draft, a new push that is not a review fix, a new comment or
question from anyone, a conflict with the base, a train that fails on the PR. Put it back
only after the rules hold again, which after a non-fix push means a new review of the new
head.
