---
name: leaving-pr-comments
description: Mark and format the GitHub comments a skill posts on the owner's account. Use for every PR or issue comment posted from a skill (review, ready, merge-ready, start-work, start-group, refine, overnight, full-send, issue-triage). Not for a one-off comment the owner asks for directly.
---

# Leaving PR comments

Adapted from [tstack](https://github.com/t3dotgg/tstack) (MIT, see
[TSTACK-LICENSE](TSTACK-LICENSE)).

Agents post on GitHub with the owner's account, so a reader cannot tell who wrote a
comment. The owner is the person signed in to `gh`. Get their name once per session with
`gh api user --jq '.name // .login'`. Start every comment a skill posts with this callout:

```md
> [!NOTE]
> 🤖 **<model> responding on behalf of <owner>**

The comment starts here.
```

Use the public name of the model that wrote the comment, as the harness reports it, for
example `Claude Opus 5.5` or `Claude Haiku 5.5`. If the harness does not expose a model,
use the harness name. Do not guess.

## Where it applies

- PR and issue comments posted from a skill: reviews, "Review fixes", the ready line, thread
  replies, explanations before resolving a thread, merge-ready's failure and issue comments,
  the `needs-human` comments from start-work, start-group, the refine skills and
  issue-triage.
- Review bodies too. The callout goes first and the `**Codex review (...)**` or
  `**Opus review (...)**` header follows it on its own line. ready.md finds reviews by that
  header after the callout. Inline review comments get the callout too.

It does not apply to a comment the owner asks for directly ("post a comment on #12 that
says ..."), PR descriptions, issue bodies, commit messages, or text the owner asked to post
word for word.

## Writing the comment

Keep the callout to those two lines and the comment outside it. No rule, heading,
signature or second attribution. Write the comment in [unslop](../unslop/SKILL.md) style:

- Lead with the conclusion.
- Cite the code, behaviour, check or reproduction.
- Keep it short, with no thanks or status narration.
- Separate what you checked from what you think.

Check the whole comment, quotes included, for secrets and private details before posting.
After posting, check that GitHub returned the comment or review URL. Resolve a review thread
only after its reply posted.
