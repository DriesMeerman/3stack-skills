---
name: midnight-oil
description: Overnight, without a wave count. Keeps starting start-group waves and refining new work until 07:00, with one merge after the fourth wave. Use for /midnight-oil or /midnight-oil until <HH:MM>.
---

# Midnight oil

Run [overnight](../overnight/SKILL.md) with one change: it stops on the clock, not after a
number of waves. Every overnight rule holds unless this file says otherwise.

## Arguments

- `/midnight-oil`: work until 07:00.
- `/midnight-oil until <HH:MM>`: work until that time.

## Keep going until the time limit

- Keep starting waves. A wave starts only if it can finish by the time limit: no wave
  starts in the last hour (after 06:00 for a 07:00 limit).
- When agent-ready work runs out, refine more (overnight step 2) and plan the next wave from
  it. Running out of work is not a reason to stop while there is time left.
- In the last hour, refine issues and answer review comments on open PRs, but start no new
  task.
- Stop at the time limit. Agents still running finish their current step and report.

## Merge

The one merge-ready run happens after the fourth wave, not at the end, so later waves can
build on merged work instead of stacking on open PRs. It is still the only merge.

At the time limit, run merge-ready once more without a go-ahead: it builds a train from the
PRs labelled since, runs it and reports without merging. The owner merges those.

## Report

Overnight step 5, plus the result of the closing train.
