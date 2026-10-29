---
name: file-pr
description: Open a short draft PR that leads with the problem, not a list of changes. Use when the owner asks to file, open or create a PR, and from full-send and half-send.
---

# File PR

Adapted from [tstack](https://github.com/t3dotgg/tstack) (MIT, see
[TSTACK-LICENSE](TSTACK-LICENSE)). Apply [unslop](../unslop/SKILL.md).

Before filing, check whether this branch already has a PR. Read the diff against its base
(usually `origin/<default branch>`, or the base PR's branch for a stacked PR) and check it
matches the goal.

Titles become the merge commit's description, so follow the repo's style. Read the last
twenty with `gh pr list --state merged --limit 20 --json title --jq '.[].title'` and match
them. Without a clear style, write `Area: what changed for the user` or a plain sentence,
with the issue number when there is one. Say why the change matters, not how:

- Bad: `perf(server): negotiate permessage-deflate on the websocket`
- Good: `Cut websocket frames by 70% with compression`

Open the body with the problem as the owner described it, then the solution in a few
lines. Do not lead with a list of files or functions. Add `Closes #n` for the issue it
finishes, or `Part of #n` when work is left. Add one line saying how you proved the change.
Put choices the owner should check under "Needs your decision", and nothing there when
there are none. End with the attribution the session gives for PR descriptions.

Before you submit, check the title and body for secrets, tokens and private details.

Open it as a draft, `gh pr create --draft --body-file <file>`. The review in
[review.md](../start-work/review.md) follows, then `gh pr ready <n>`. If `gh pr create`
fails because the GraphQL rate limit is used up, open it through REST with
`gh api repos/{owner}/{repo}/pulls -f title=... -f head=... -f base=... -F draft=true -F body=@<file>`.

Do not post a follow-up comment unless the flow asks for one. Format any comment with
[leaving-pr-comments](../leaving-pr-comments/SKILL.md).
