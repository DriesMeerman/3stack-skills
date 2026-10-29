---
name: half-send
description: Same work as full-send, but stop with the PR labelled ready-to-merge for the owner or merge-ready to merge. Never merges. Use when the owner says "half send". The overnight skills run every task this way.
---

# Half send

Adapted from [tstack](https://github.com/t3dotgg/tstack) (MIT, see
[TSTACK-LICENSE](TSTACK-LICENSE)).

Do the work in [full-send](../full-send/SKILL.md) (its steps, testing permission, proof
rules, review and asking rules), but stop when the PR is ready. A "half send" request
grants that work on its own, without a separate "full send". Its merge permission does not
apply. The rules below win.

## No merging

You may commit, push, merge `origin/main` into the branch and fix conflicts on this task's
branch. Never merge, enable auto-merge, push to `main`, force-push, or ask another agent to
merge. Merging happens through [merge-ready](../merge-ready/SKILL.md) or by the owner.

## Stop at the gate

Use full-send's merge gate as the readiness check, and replace its merge and report steps
with a handoff. Proof and review must cover the final diff. Recheck behaviour changes and
conflict fixes before the handoff.

Fetch `origin/main` and check the live PR: head, base, `mergeable`, labels, review threads.
Confirm it is open, not a draft, and labelled `ready-to-merge`. If someone merged it, say so
instead.

- **Ready:** the gate passes and the label is on. Leave the PR open.
- **Waiting on its base:** a stacked PR whose base is labelled but not merged. Label it
  once its base is labelled (ready.md rule 6).
- **Blocked:** what stops it, what you tried, and what is needed. Follow full-send's rules
  for asking.

Report the PR link, the final head, the verdict, the proof, the review result and what is
still open. Say that the PR is open and unmerged.
