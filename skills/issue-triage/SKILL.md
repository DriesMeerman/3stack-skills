---
name: issue-triage
description: Go through a repo's open GitHub issues, recommend what to do with each (ready for an agent, needs a decision, split, close, reprioritise), and put the recommendations on one local HTML page where the owner accepts or rejects each change, answers questions and adds notes. Then applies the pasted reply after a confirmed plan. Works in any repo with gh. Use for /issue-triage, /issue-triage <count>, /issue-triage <label or search> or /issue-triage apply <file>.
---

# Issue triage

Read the open issues, decide what each one needs, and let the owner settle the whole batch
on one page with a few clicks. Then fold the answers back into GitHub. Apply
[unslop](../unslop/SKILL.md) to every summary, option, comment and table you write.

- `/issue-triage` takes the top 10 open issues by rank.
- `/issue-triage <count>` takes another count. `all` takes every open issue.
- `/issue-triage <label or search>`, such as `/issue-triage bug` or
  `/issue-triage "label:needs-human"`, narrows the survey with `gh issue list --search`.
- `/issue-triage apply <file>` is the reply the page produces. Run section 6.

The skill writes nothing to GitHub before section 6, and nothing there without the owner's
go-ahead on the plan. It never merges, assigns, or edits code.

The page and its JSON live outside the repo, in
`${XDG_CACHE_HOME:-$HOME/.cache}/issue-triage/<owner>-<repo>/`, so triage leaves no files
in the project. Call that folder `<dir>` below.

## 1. Survey

```sh
git fetch origin 2>/dev/null
gh repo view --json nameWithOwner,defaultBranchRef
gh issue list --state open --limit 1000 --json number,title,labels,body,milestone,createdAt,updatedAt,url,comments
gh pr list --state open --limit 100 --json number,title,body,headRefName,closingIssuesReferences,url
gh label list --limit 200 --json name,description
```

Add `--search "<query>"` to the issue list when the owner gave a filter. If the list holds
1000 issues, say that older ones are missing. Read the project's agent instructions
(`AGENTS.md`, `CLAUDE.md`) and README for the labels and priorities the project uses.

## 2. Rank and pick

Leave out issues with an `on-hold` label and issues an open PR closes, and say how many.
Epics stay in, but get `keep` unless their checklist is done or stale.

Rank the rest:

1. Priority labels: `p0`, then `p1`, then the rest (or the project's own scheme).
2. Blockers: an issue that other issues or an epic's order wait on comes first.
3. `needs-human` issues where the owner has not answered yet, since this page is a quick
   way to answer them.
4. Age: oldest first.

Take the top 10, or the count the owner gave. Show the picks with one line each and the
next three below the cut. Go ahead unless the owner redirects. With more than 30 picks, say
the page will be long and offer to split it into batches.

## 3. Read and recommend

For each pick, read the body, every comment, each linked issue and PR, and the files the
issue names (check each path exists with `git cat-file -e origin/<default>:<path>`). With
more than four picks, hand the reading to read-only subagents, one per issue and at most 4
at once, each returning facts and a draft recommendation. You decide the verdicts and
write the text.

Run [refine-issue](../refine-issue/SKILL.md) steps 2 to 4 on each issue: the checklist,
the needs-human triggers and the verdict. Then give the issue one headline verdict:

- `ready`: an agent can finish it. Propose the missing sections (Done when, Touch points,
  Out of scope, Implementer) that the code answers, and the `agent-ready` label.
- `decide`: an owner decision or chore blocks it. Write the questions.
- `split`: it does not fit one PR. Propose one `create` per sub-issue and a label or
  comment on the parent.
- `close`: done, duplicated, replaced, or stale with no owner interest. Say which, with the
  evidence: the PR or commit that did it, the duplicate's number, the last activity date.
- `priority`: the labels are wrong for what the issue blocks or how often it bites. Propose
  the label change.
- `keep`: nothing to do now. Say why in one line. Use it sparingly; a page full of `keep`
  wastes the owner's time, so leave those issues off unless the owner asked for `all`.

An issue can carry both actions and questions. A `ready` issue with one small open choice
is `decide`.

When an issue is labelled `needs-human` and its latest refinement comment ends with an
`<!-- agent-questions {...} -->` block (refine-issue step 5), start from those questions:
decisions and chores become questions, and cleanups become actions. Drop the ones already
done.

### Actions

An action is one change the owner accepts or rejects with a click. Keep each to one
purpose, such as "Label agent-ready and add Done when", "Close as fixed by #412", or "Split
into three sub-issues". Mark the one you would take with `"recommended": true`. Put the
full text an action would write (a body section, a comment, a new issue's body) in
`preview`, so the owner can read it before accepting.

`do` holds the steps section 6 runs, in order. The verbs:

- `{"verb":"label","issue":455,"add":["agent-ready"],"remove":["needs-human"]}`
- `{"verb":"close","issue":414,"reason":"fixed by #412"}`
- `{"verb":"milestone","issue":422,"milestone":"v2"}`
- `{"verb":"create","title":"...","body":"...","labels":[],"milestone":"..."}`
- `{"verb":"comment","issue":418,"body":"..."}`
- `{"verb":"body","issue":418,"add":"## Done when\n\n- ..."}` appends sections to the body.

`add`, `remove`, `labels`, `reason` and the `create` milestone are optional. A label holds
no comma. A `close` always gets a `reason`, and section 6 posts it as a comment before
closing.

### Questions

Before you write a question that asks the owner to do something, ask whether an agent
could do it with `gh` or in the repo. If yes, it is an action, not a question. Keep each
question to one decision; split one that asks two things.

- A decision with known options: `"type":"choice"` and `options`, each with a short `label`
  (a few words, it is what the reply shows) and a one-line `detail` with the trade-off. Mark
  the one you recommend with `"recommended": true` and say why in its detail. Add "Something
  else" only when the real options are not known. Up to four short options render as cards,
  more as radio buttons; set `style` to `cards` or `radio` to force one. For a reversible,
  low-stakes choice, set `default` to the option you will take without an answer; the page
  preselects it and says so.
- An open answer (a name, wording, a number): `"type":"text"` with a `placeholder` that shows
  the shape of the answer.
- A chore only the owner can do (a key, an account, money, their machine):
  `"kind":"chore"` with `why` and `steps` (`where`, `text`, optional `cmd`). When a choice
  decides the steps, give `options` and `stepsFor` keyed by option label instead.

Add `context` when the question needs a fact to answer it, such as the current behaviour, a
file path or what a comment said. Two lines at most.

### The file

Give each item a one-line `summary` of what the issue is about and a `why` of one or two
lines for the verdict. Add an `intro` of two or three lines for the batch: how many issues,
what stood out, which ones to look at first.

```sh
dir="${XDG_CACHE_HOME:-$HOME/.cache}/issue-triage/$(gh repo view --json nameWithOwner --jq '.nameWithOwner | sub("/"; "-")')"
mkdir -p "$dir"
```

Write `<dir>/<YYYY-MM-DD>.json`. Add `-2`, `-3` when the file exists.

```json
{
  "title": "Issue triage, 29 Oct",
  "repo": "owner/repo",
  "intro": "Ten issues. Three are ready once their Done when lands, two look finished.",
  "items": [
    {
      "kind": "issue", "number": 57, "title": "Sessions survive restarts",
      "url": "https://github.com/owner/repo/issues/57",
      "labels": ["p1"],
      "verdict": "decide",
      "summary": "Where the web app keeps login sessions.",
      "why": "The code answers everything but the store. The issue lists two with no pick.",
      "actions": [
        {
          "title": "Add Done when and Touch points",
          "detail": "Tests in test/sessions.test.ts; touches src/sessions/ and the migration folder.",
          "preview": "## Done when\n\n- test/sessions.test.ts: a session outlives a restart\n\n## Touch points\n\n- src/sessions/store.ts",
          "recommended": true,
          "do": [{ "verb": "body", "issue": 57, "add": "## Done when\n\n- ..." }]
        }
      ],
      "questions": [
        {
          "type": "choice", "prompt": "Where do sessions live?",
          "options": [
            { "label": "SQLite", "detail": "Survives restarts. Same database as the rest.", "recommended": true },
            { "label": "Memory", "detail": "Simplest. Logs everyone out on restart." }
          ]
        },
        { "type": "text", "prompt": "How long does a session last?", "placeholder": "e.g. 30 days" }
      ]
    }
  ]
}
```

## 4. Build and open the page

```sh
node <skills>/issue-triage/render.mjs "$dir/<file>.json"
open "$dir/<file>.html"     # Linux: xdg-open
```

`<skills>` is the folder this skill was loaded from. The script checks the JSON and writes
the page next to it. Fix what it reports and run it again. When there is no local display,
give the full path instead of opening it.

Tell the owner the page is open, how many actions and questions it holds, and that the
reply block at the bottom goes back into this session. Then stop.

The page keeps answers in the browser, so closing it loses nothing. Each item has a notes
box, each choice has a note field for another answer, every question can be skipped, and
"Accept all recommended" accepts the recommended actions still undecided.

## 5. Read the reply

The reply looks like this:

```
/issue-triage apply /Users/me/.cache/issue-triage/owner-repo/2026-10-29.json

#57 A1 accept: Add Done when and Touch points
#57 Q1: SQLite
#57 Q1 note: reuse the main database
#57 Q2: 30 days
#57 note: also check the logout path
#61 A1 reject: Close as fixed by #412
#61 note: not fixed on Safari, keep it open

Overall note: skip anything about the old importer

Undecided: #63 A1, #63 Q1
```

Continuation lines of a long answer are indented by two spaces. Read the JSON file it
names to get each item's actions, questions and options back. Match `An` and `Qn` to the
item's lists in order.

Notes count as instructions for that item. A note can change an accepted action (rewrite
the text, add a step) or turn a rejected one into something else ("not fixed on Safari"
means: no close, and probably a comment with that finding). When a note or an answer can be
read more than one way, draft the likeliest reading and ask about it with the plan. Apply
the overall note to every item.

## 6. Plan, confirm, apply

For each item, work out what to write:

- Accepted actions: their `do` steps, changed as the notes say.
- Answered decisions: fold the answer into the body as
  [refine-issues](../refine-issues/SKILL.md) step 5 does (the picked option becomes the
  solution or the section the question was about; keep the owner's text and the problem
  statement), then rerun refine-issue steps 2 to 4 on the body as it will read. Every
  question answered and every check passing makes it `agent-ready`; otherwise it gets
  `needs-human` and a comment with the open questions and an `agent-questions` block
  (refine-issue step 5). Only use the `agent-ready` and `needs-human` labels where the
  owner accepted a label action or answered the item's questions.
- Done chores: note them in the comment.
- Rejected actions, skipped and undecided items: nothing changes.

Write nothing to GitHub yet. Show one table, then the full new text for each body edit,
comment and new issue below it:

```
| Item | Accepted | Answered | Writes |
| --- | --- | --- | --- |
| #57 | 1 of 1 | 2 of 2 | body: Done when, Touch points, solution; label agent-ready; comment |
| #61 | 0 of 1 | none | comment (Safari finding from your note) |
| #63 | undecided | 0 of 1 | none |
```

Wait for the owner's go-ahead. They may approve some rows only; touch only those. Then for
each approved row, one `gh` command per write, temp files in the session scratchpad:

1. Body: `gh issue view <n> --json body` again, append or edit, `gh issue edit <n> --body-file <file>`.
   If the body changed since the survey, show the difference and ask before writing.
2. Labels: `gh issue edit <n> --add-label ... --remove-label ...`. Create a missing label
   with `gh label create` first, using refine-issue step 5's colour and description for
   `agent-ready` and `needs-human`.
3. New issues: `gh issue create --title ... --body-file <file>` with any labels and milestone,
   then link them from the parent's comment.
4. Comments: `gh issue comment <n> --body-file <file>`, starting with the
   [leaving-pr-comments](../leaving-pr-comments/SKILL.md) callout.
5. Close: post the reason as a comment, then `gh issue close <n> --reason completed` (or
   `--reason "not planned"` for a duplicate or stale issue).

Check each command's output. On a failure, stop that item, keep the rest going, and report
it.

## 7. Report

Finish with a table of each item, what was accepted and answered, and what changed on
GitHub, with links to new issues and comments. List what is still undecided. Say so when
nothing was applied. Leave the files in `<dir>`; give its full path so the owner can delete
them or reopen the page.
