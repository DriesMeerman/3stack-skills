# Project rules

Shared by every skill in the work loop ([start-work](SKILL.md),
[start-group](../start-group/SKILL.md), [full-send](../full-send/SKILL.md),
[half-send](../half-send/SKILL.md), [merge-ready](../merge-ready/SKILL.md), the refine
skills and [overnight](../overnight/SKILL.md)). These skills work in any repo, so they read
the project's own rules instead of assuming them. Look these up once per session, before
the first change, and say in the report what you found and what you assumed.

## Where the rules live

Read the project's agent instructions first: `AGENTS.md`, `CLAUDE.md`, or the file either of
them points to. Then the README and `CONTRIBUTING.md`. A rule in those files wins over a
default on this page. When they do not answer something below, use the default and name it in
the report.

## What to find

- **Default branch.** `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`.
  The skills write `main`; read it as the default branch.
- **Test command.** What to run before pushing. Take it from the agent instructions. Without
  one, read `package.json` scripts, the `Makefile`, `justfile`, `pyproject.toml`, `Cargo.toml`
  or the CI workflow and pick the narrowest command that covers the changed files, plus the
  typecheck and lint the project has. Read the exit status, never only the summary line.
- **Full suite.** The command that runs everything, used by the merge-ready train. Usually the
  one CI runs.
- **Heavy commands.** If the project names a wrapper or lock for heavy commands, so only one
  runs at a time across agents, use it for every install, build and test run.
- **CI.** Whether workflows run on pull requests (`on: pull_request` in
  `.github/workflows/`), and whether one can be started by hand (`workflow_dispatch`) on a
  branch to run the full suite.
- **Review guide.** A file the reviewer reads first, if the project has one: the one the agent
  instructions name, or `docs/reviews/code-review-guide.md`, `REVIEWING.md` or
  `docs/code-review.md`.
- **Hot files.** Files many tasks touch, which get one writer per wave. Take the list from the
  agent instructions. Without one, treat as hot: migrations and schema files, central
  registries or routers, lockfiles, CI workflows, `AGENTS.md`, `CLAUDE.md` and skill files.
- **Off limits.** What agents never touch. Always: secrets and `.env` files, production or live
  services, live data directories, deploy credentials, and anything outside the repo. Add what
  the agent instructions list.
- **Parity rules.** A rule such as "a change to X also goes to Y and Z, with a test for each".
  Follow every such rule the project states.
- **Merge style.** `git log --merges --oneline -5 origin/main` shows whether the repo merges
  with merge commits. The skills merge with a merge commit; when the repo plainly squashes,
  stop and ask before the first merge.

## Always

- Never force-push, push to the default branch, or use `git stash` (worktrees share one stash
  list).
- Work on a branch, in its own worktree when the checkout has other work.
- Tests never send real messages, call paid inference, or mutate GitHub.
- Keep temp files in the session scratchpad, not in the repo.
