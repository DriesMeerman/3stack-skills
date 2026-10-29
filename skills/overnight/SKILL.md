---
name: overnight
description: Run start-group waves on their own while the owner is away, 4 waves by default, then one merge-ready train and merge at the end. Asks its questions once at the start, then works without asking. Use for /overnight, /overnight <waves> or /overnight until <HH:MM>.
---

# Overnight

Run [start-group](../start-group/SKILL.md) waves without the owner, then merge once. Apply
[unslop](../unslop/SKILL.md) to everything you write for the user, PR bodies and comments.
Every start-group, start-work, review and project rule still holds. This skill only adds
the schedule, the one merge and what to do when there is no one to ask.

## Arguments

- `/overnight`: 4 waves, one merge after the last.
- `/overnight <n>`: n waves, one merge after the last.
- `/overnight until <HH:MM>`: the last time a wave may start. The default is 06:00.

Times are the machine's local time. Read the clock with `date +%H:%M` before each wave and
never guess it.

## 1. Questions first, then no more

Survey and rank as in start-group. Show the task table for all waves (start-group
section 2), then ask every question in one round:

- approval to refine and run `p0` or `p1` issues that are not `agent-ready` yet
- approval for refinement during the run (step 2), for issues of any label
- anything in the table that needs an owner call

Do not ask about scope or review; the arguments and start-group settle them. After the
answers, the owner is away. Ask nothing more until the final report. Each later call
an agent cannot make goes in the report, with the issue relabelled `needs-human` (step 3).

Invoking this skill is the owner's go-ahead for one merge-ready run, at the end (step 4).
It covers nothing else: no merge before the last wave, and no second merge.

## 2. Run the waves

Run each wave as start-group sections 3 and 4 say: at most 4 agents on a laptop, one
worktree and branch each, owned paths, hot files with one writer per wave, stacks on open
base PRs, Sol high reviews and the `ready-to-merge` label.

Every agent runs its task as [half-send](../half-send/SKILL.md): it proves the change, files
the PR with [file-pr](../file-pr/SKILL.md), reviews it, and stops with the PR labelled and
unmerged. Give each agent the start-group briefing and tell it to follow half-send. Where
half-send says to ask the owner, the agent relabels its issue `needs-human` instead
(step 3).

- Before each wave, read the clock. Start no wave after the cutoff.
- Wait for agents through their completion notices. Do not poll or sleep.
- When agent-ready work runs out, or every next task would stack on more than one unmerged
  PR that changes the same hot file, run [refine-issues](../refine-issues/SKILL.md) on the
  next ranked issues in free slots. With the approval from step 1, apply its table
  without waiting at its step 4: rows with no owner questions get their sections and the
  `agent-ready` label, rows with questions go to `needs-human`. Without that approval, refine
  nothing and stop when the planned work is done. Plan the next wave from what it labels
  `agent-ready`.
- A small change outside an agent's owned paths, inside the task's scope, can be approved
  when no other agent in the wave owns that file. Note each one for the report.
- On macOS, wrap long local runs in `caffeinate -i` so the machine does not sleep, and keep
  it on power.

## 3. When something blocks

There is no one to ask, so leave the blocked part and go on with the rest.

- An agent that hits an owner decision relabels its issue `needs-human`, posts one short
  comment saying what blocks it, and stops. Plan its slot with other work.
- A tool call the permission mode denies stays denied. Do not route it through another
  agent or another command. Save what it would have done (an issue body, a checkbox) in the
  scratchpad and list it in the report.
- A stuck agent gets one message asking for its status. If it is still stuck, stop it and
  note it.

## 4. One merge at the end

When the last wave's PRs are open, reviewed and labelled, run
[merge-ready](../merge-ready/SKILL.md) with the go-ahead from step 1. Its rules all hold:
the train, at most two runs, nothing merges on red.

PRs labelled after that train wait for the owner. Do not start another merge.

## 5. Report

Finish with one report for the owner to read in the morning:

- the start-group table: PR, title, local test result, review result, ready label, open
  items
- the train: branch, result, what merged, what was dropped and why
- what needs the owner: `needs-human` issues and their questions, denied tool calls with
  the saved drafts (full scratchpad paths), choices agents made that they may want changed.
  Offer [issue-triage](../issue-triage/SKILL.md) to answer the questions on one page.
- labelled PRs waiting for their merge, in merge order
- why the run stopped: waves done, cutoff reached, or no work left that would not conflict
- review-run problems (tool errors, timeouts)
