---
name: refine-issue
description: Check whether an open issue is ready for a coding agent and label it agent-ready or needs-human. Use for /refine-issue <n> or /refine-issue --open.
---

# Refine issue

Decide for each open issue whether a coding agent can finish it without asking
anything, and label it. Apply [unslop](../unslop/SKILL.md) to every comment, table and
report you write. Read the project's rules first
([project-rules.md](../start-work/project-rules.md)).

- `agent-ready`: an agent can finish the issue alone. It has a clear end point.
- `needs-human`: an owner decision, outside setup or missing information blocks it.

Use it as `/refine-issue 214` for one issue or `/refine-issue --open` for every open
issue. `start-work` and `start-group` pick only issues labelled `agent-ready`.
To answer the needs-human questions on one page, use
[issue-triage](../issue-triage/SKILL.md). To pick the most important issues and fill in
their missing sections, use [refine-issues](../refine-issues/SKILL.md).

## 1. Read the issue

```sh
git fetch origin
gh issue view <n> --json number,title,body,labels,comments,milestone
```

Read the body, every comment, each linked issue or PR, and the files the issue names.
Check that each named path exists on `origin/main` with `git cat-file -e origin/main:<path>`.
A path that moved or never existed counts as a missing touch point.

Skip epics and milestone trackers, which are not work items. An epic has a title that
starts with "Epic:" or lists other issues as its checklist. Say it was skipped.

## 2. Run the checklist

Answer each check with yes or no. Do not score. Record which checks fail.

1. The problem is stated in one or two sentences.
2. The issue picks one concrete solution. A list of options is an open choice.
3. A **Done when** section lists runnable checks: test files, commands or a named
   scenario.
4. Touch points name files or modules. When a parity rule in the project's instructions
   covers the change, they name every place the rule requires.
5. Out of scope is stated.
6. Dependencies are closed, or the issue names the open one as its stack base.
7. The work fits one PR.
8. The issue suggests an implementer level that follows the rule below.
9. No owner question is open in the body or the comments.
10. The tests need no real messages, paid inference or GitHub mutations.

### Implementer level

Opus when any of these holds:

- Money, billing, spend caps or usage accounting.
- A schema change or a migration.
- Auth, sessions, tokens, permissions or redaction of secrets.
- Path safety, file writes outside a sandbox, or user data.
- Concurrency, restarts, shutdown or durable state.
- Code a project parity rule covers.
- CI gating, such as path filters or which jobs run.
- A mistake would pass tests and fail silently.
- More than about 300 lines of non-test code.

Sonnet only for docs, copy and skill text, a UI on an API that already exists, a
one-file fix whose test the issue describes, a mechanical change that follows a named
earlier PR, or a read-only route that reuses existing auth helpers and adds no
aggregation. An issue with any Opus trigger never gets Sonnet. A mixed issue gets a split
line, such as "Opus for the route, Sonnet for the page". When unsure, pick Opus.

Why: an Opus session costs about 1.3 to 1.7 times a Sonnet one, because most tokens are
cache reads. Sonnet PRs on risky areas tend to need follow-up PRs, so Opus pays for itself
when it saves one fix round.

## 3. Check the needs-human triggers

Any one of these makes the issue `needs-human`, even when the checklist passes:

- Credentials, or config the agent cannot write (secrets, `.env`, production config).
- A paid service or a new machine.
- Production, live services, live data or anything else project-rules.md puts off limits.
- A product or policy choice: user-facing copy, access rules, which models or vendors to
  use, a security trade-off.
- Several options with no pick, or comments that disagree.
- Work in another repo, or a broad refactor.

## 4. Decide

- `needs-human` when a trigger applies or any check fails, except as the next point
  says.
- `agent-ready` when no trigger applies and every check passes.
- One exception. If check 3 is the only failure and the issue lists acceptance tests, the
  verdict is `agent-ready` and the comment proposes a **Done when** section built from
  those tests.

Judge only what the issue and the repo show. Do not assume a missing section was
intended. When a missing part is small and obvious, such as an implementer level, put
the proposed text in the comment so the owner can accept it.

## 5. Apply the label

Create both labels once if they are missing:

```sh
gh label create agent-ready --color 0e8a16 --description "A coding agent can finish this without asking anything"
gh label create needs-human --color d93f0b --description "Blocked on an owner decision, outside setup or missing information"
```

Set one label and remove the other:

```sh
gh issue edit <n> --add-label agent-ready --remove-label needs-human
gh issue edit <n> --add-label needs-human --remove-label agent-ready
```

Post one short comment with `gh issue comment <n> --body-file <file>`. Start it with the
[leaving-pr-comments](../leaving-pr-comments/SKILL.md) callout.

For `agent-ready`, one line says it is ready, plus the proposed **Done when** section when
the exception in step 4 applies.

For `needs-human`, say what blocks the issue, then number what the owner must decide or
add:

```
Marked needs-human. An agent cannot finish this yet.

1. Decide which wording the confirmation prompt uses. The issue offers two. I recommend Short.
   Without an answer in a week, the issue stays blocked.
2. Add a speech API key to the deploy environment.
3. Cleanup for approval: close #414, which this issue replaces.
```

### Three kinds

Each numbered item is one of three kinds.

- `decision`: only the owner can answer, and the answer changes what gets built. A product
  or policy choice, a pick between options, a security trade-off.
- `chore`: only the owner can do it, because it needs their machine, their accounts, a key,
  money or a live service.
- `cleanup`: an agent can do it with `gh` or in the repo. Closing done issues, creating
  sub-issues, relabelling, moving a milestone, commenting.

Before you write a `chore`, ask whether an agent could do it with `gh` or in the repo. If
yes, write a `cleanup`. Closing, creating, labelling, moving milestones and commenting are
always `cleanup`, never a step for the owner.

Check each `chore` and `cleanup` step with `gh issue view <n> --json state,labels,milestone`
before you write it. Leave out a step that is already done, such as closing an issue that
is closed, and leave out the item when no step is left.

A `decision` names the option you recommend and says in one sentence what happens if
the owner does not answer within a week. For a reversible, low-stakes choice you may write
"Going with Short unless you object." and set `"default"` to that option's label. The
issue-triage page then shows it as an FYI below the open decisions.

### Who runs a cleanup

This skill never runs a cleanup itself, and never closes, assigns or merges. The owner
approves each cleanup, either on the [issue-triage](../issue-triage/SKILL.md) page or in the
session, and the agent that holds that approval runs it.

### The questions block

End every needs-human comment with a hidden block that holds the same items as JSON, on
one line, so [issue-triage](../issue-triage/SKILL.md) can show them as cards. For the
comment above:

```
<!-- agent-questions {"summary":"Voice replies for confirmations.","questions":[{"kind":"decision","type":"choice","prompt":"Which wording does the confirmation prompt use?","context":"Without an answer in a week, the issue stays blocked.","options":[{"label":"Short","detail":"One line.","recommended":true},{"label":"Long","detail":"Names the command."}]},{"kind":"chore","prompt":"Add a speech API key to the deploy environment.","why":"Voice replies need one.","steps":[{"where":"Deploy secrets","text":"Add SPEECH_API_KEY."}]},{"kind":"cleanup","prompt":"Close #414, which this issue replaces.","why":"Its work moved here.","do":[{"verb":"close","issue":414,"reason":"replaced by this issue"}]}]} -->
```

- One entry per numbered item, in the same order. Each has `kind` and `prompt`, plus
  the question fields of the issue-triage schema (`type`, `options`, `placeholder`,
  `context`). An optional `id` (lowercase letters, digits and dashes) keeps an answer
  attached when the list changes.
- `decision`: the owner picks an option or types an answer. `type` is `choice` or `text`.
  Mark the recommended option with `"recommended": true`. `default` is optional and must
  be one of the option labels.
- `chore`: give `why` (one line) and `steps`, each with `where`, `text` and an optional
  `cmd` for copying. When a choice decides the steps, give `options` and `stepsFor`, keyed
  by option label, instead of `steps`.
- `cleanup`: give `why` (one line) and `do`, a list of typed steps. The verbs:
  - `{"verb":"close","issue":414,"reason":"superseded by #418"}`
  - `{"verb":"label","issue":455,"add":["agent-ready"],"remove":["needs-human"]}`
  - `{"verb":"milestone","issue":422,"milestone":"v2"}`
  - `{"verb":"create","title":"...","body":"...","labels":[],"milestone":"..."}`
  - `{"verb":"comment","issue":418,"body":"..."}`

  A label holds no comma. `reason`, `add`, `remove`, `labels` and the `create` milestone
  are optional.
- Never put a key or other secret in the block. A chore that needs one says where it
  goes. The JSON must not contain `-->`.

Never edit the issue body unless the owner says so in the session.

Run the skill again after the issue changes. It rechecks everything, so an issue moves
from `needs-human` to `agent-ready` once the answers land. If the verdict and the missing
items are the same as the last run, post no second comment.

## 6. Batch mode

`--open` lists the issues with `gh issue list --state open --limit 1000 --json number,title,labels,body`
(count the result, and if it holds 1000 issues, say that older ones are missing) and runs
steps 1 to 4 on each issue that is not an epic and has no `on-hold` label. It changes
nothing at this point. Show one table:

```
| Issue | Verdict | Missing items |
| --- | --- | --- |
| #275 | needs-human | 1. Pick one of two options. |
| #268 | agent-ready | none |
```

Wait for the owner's go-ahead, then run step 5 on the issues the owner approved. If the
owner approves only some rows, touch only those. With more than five rows, offer
[issue-triage](../issue-triage/SKILL.md) to go through them on one page instead.

## 7. Report

Finish with the verdict for each issue, the labels created or changed, and any issue that
was skipped. Say so when nothing was applied.
