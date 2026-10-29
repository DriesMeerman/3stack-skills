---
name: refine-issues
description: Go through the open issues, pick the most important ones that are not agent-ready yet, fill in what a coding agent needs from the code, and label each agent-ready or needs-human with the owner's questions. Use for /refine-issues or /refine-issues <count>.
---

# Refine issues

Pick the open issues that matter most and get each one to `agent-ready`, or to
`needs-human` with clear questions for the owner. [refine-issue](../refine-issue/SKILL.md)
checks one issue and labels it. This skill chooses which issues to take and does the
work the checklist asks for. Apply [unslop](../unslop/SKILL.md) to every issue body,
comment and table you write. Read the project's rules first
([project-rules.md](../start-work/project-rules.md)).

Use it as `/refine-issues` for the top 5 or `/refine-issues 3` for another count.
Afterwards, [start-work](../start-work/SKILL.md) and
[start-group](../start-group/SKILL.md) pick the `agent-ready` issues. To review the
proposals on a page with buttons and notes instead of a table, use
[issue-triage](../issue-triage/SKILL.md).

## 1. Survey

```sh
git fetch origin
gh issue list --state open --limit 1000 --json number,title,labels,body,milestone,createdAt,updatedAt
gh pr list --state open --limit 50 --json number,title,headRefName,baseRefName,isDraft,body
```

If the list holds 1000 issues, say that older ones are missing. Read the open epics:
their checklists and order sections tell you which issues block others.

## 2. Pick

Candidates are open issues that are not epics and have no `agent-ready` or `on-hold`
label. Leave out:

- issues with an open PR that closes or names them
- `needs-human` issues where the owner has not commented since the label was added
- issues whose last comment is a refinement comment and that have not changed since

Rank the rest as start-work does:

1. Labels: `p0`, then `p1`, then the rest.
2. Blockers: an issue that other issues or an epic's order wait on comes first.
3. Age: oldest first.

Take the top 5, or the count the owner gave. Show the picks with one line each on why,
and the next two below the cut. Go ahead unless the owner redirects.

## 3. Refine each pick

For each pick, run steps 1 to 4 of refine-issue: read the issue, run the checklist and
the needs-human triggers. Then sort every failed check into one of two kinds.

**The code answers it.** Do the work and write the missing part:

- **Done when**: name the test file to add or extend and the cases it covers, or the
  command to run. Find the test file next to the code the issue changes.
- **Touch points**: read the code and name the files and functions. Search for the
  feature's nouns and verbs, read the entry points and the code they call, check
  `git log` on those files for recent changes, and note the tests that cover them. Name
  every place a project parity rule requires.
- **Out of scope**: what nearby work the issue does not cover, taken from the issue,
  its epic and related issues.
- **Dependencies**: check each linked issue and PR, and say which are closed.
- **Fits one PR**: when it does not, propose the split as a `cleanup` with one `create`
  step per sub-issue. Do not file them yourself. Until the owner approves the cleanup, the
  issue is `needs-human`.
- **Implementer**: follow the implementer rule in refine-issue check 8.
- A named path that moved: give the current path.

**The owner answers it.** Leave the choice open and write the item. Any needs-human
trigger in refine-issue belongs here, as do open options and comments that disagree.
Give each item one of the three kinds in refine-issue step 5: `decision`, `chore` or
`cleanup`. Before you write a `chore`, ask whether an agent could do it with `gh` or in
the repo. If yes, it is a `cleanup`. Number the items. For a decision, give the options
in a line or two, say which you recommend and why in one sentence, and say what happens
if the owner does not answer within a week.

With more than two picks, hand the grounding to subagents: one Sonnet subagent per
issue, at most 4 at once on a laptop, read-only, each returning its proposed
sections and questions. You decide the verdicts and write the text.

The verdict follows refine-issue step 4, judged on the issue as it will read after your
additions. An issue with any owner question is `needs-human`.

## 4. Show the plan

Write nothing to GitHub yet. Show one table:

```
| Issue | Verdict | Body changes | Owner questions |
| --- | --- | --- | --- |
| #316 | agent-ready | adds Done when, Touch points | none |
| #321 | needs-human | adds Touch points | 1. One flag or two? Recommend one. |
```

Below it, give the full text of each new section. Wait for the owner's go-ahead. They
may approve some rows, change text or answer questions in the session. An answer
becomes part of the body, and the issue is rechecked.

## 5. Apply

For each approved row:

1. Update the body with `gh issue edit <n> --body-file <file>`. Keep the owner's text.
   Add the missing sections in refine-issue's order (problem, solution, Done when,
   touch points, out of scope, dependencies, implementer) and fix wrong paths. Never
   delete a section or rewrite the problem or solution. Put a proposal that would
   change them in the comment instead.
2. Set the label with refine-issue step 5. It creates both labels if they are missing.
3. Post one comment with `gh issue comment <n> --body-file <file>`, starting with the
   [leaving-pr-comments](../leaving-pr-comments/SKILL.md) callout. For `agent-ready`, one
   line that says it is ready and which sections were added. For `needs-human`, the
   numbered items from step 3 and the `agent-questions` block of refine-issue step 5.

Run one `gh` command per write. Keep temp files in the session scratchpad. A cleanup
runs only after the owner approves it, as "Who runs a cleanup" in refine-issue step 5 says.

## 6. Report

Finish with a table of each issue, its verdict and what changed on GitHub, plus the
issues below the cut. Say so when nothing was applied.
