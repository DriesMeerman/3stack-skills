#!/bin/bash
# Run one review of the checked-out PR head and save it to a file.
#
#   review.sh <sol-medium|sol-high|opus> <pr-number> <out-dir> [--since <ref>]
#
# --since <ref> reviews only git diff <ref>...HEAD instead of the PR's base diff.
# REVIEW_GUIDE=<path> names the project's review guide. Without it the script looks in
# the usual places and reviews without a guide when it finds none.

# Run it from the PR's own worktree and wait for it to finish (up to 30 minutes).
# It prints the path of the review file. Steps and posting: review.md.
# Exit codes: 1 review failed, 2 bad state or arguments, 3 head already reviewed,
# 4 reviewer CLI not installed.
set -u

usage="usage: review.sh <sol-medium|sol-high|opus> <pr-number> <out-dir> [--since <ref>]"
reviewer=${1:-} pr=${2:-} out=${3:-} since=
if [ "${4:-}" = "--since" ]; then
  since=${5:-}
  [ -n "$since" ] && [ $# -eq 5 ] || { echo "$usage" >&2; exit 2; }
elif [ $# -gt 3 ]; then
  echo "$usage" >&2; exit 2
fi
case "$reviewer" in
  sol-medium) effort=medium cli=codex ;;
  sol-high) effort=high cli=codex ;;
  opus) effort=high cli=claude ;;
  *) echo "$usage" >&2; exit 2 ;;
esac
[ -n "$pr" ] && [ -n "$out" ] || { echo "$usage" >&2; exit 2; }
command -v "$cli" > /dev/null || { echo "$cli is not installed." >&2; exit 4; }
mkdir -p "$out" || exit 2

head=$(gh pr view "$pr" --json headRefOid --jq .headRefOid) || exit 2
base=$(gh pr view "$pr" --json baseRefName --jq .baseRefName) || exit 2
if [ "$(git rev-parse HEAD)" != "$head" ]; then
  echo "HEAD is not the PR head $head. Push, or check out the PR branch, then retry." >&2
  exit 2
fi
if [ -n "$(git status --porcelain)" ]; then
  echo "The worktree has uncommitted changes. Commit and push them first." >&2
  exit 2
fi

short=${head:0:7}
review="$out/review-$reviewer-$short.md"
log="$out/review-$reviewer-$short.log"
if [ -s "$review" ] && [ "${REVIEW_AGAIN:-}" != 1 ]; then
  echo "This head was already reviewed: $review" >&2
  echo "Set REVIEW_AGAIN=1 only when asked to review the same head again." >&2
  exit 3
fi

git fetch -q origin "$base" || exit 2
if [ -n "$since" ]; then
  git rev-parse --verify -q "$since^{commit}" > /dev/null || { echo "Unknown ref for --since: $since" >&2; exit 2; }
  diffbase=$since
else
  diffbase=origin/$base
fi

guide_file=${REVIEW_GUIDE:-}
if [ -z "$guide_file" ]; then
  for f in docs/reviews/code-review-guide.md REVIEWING.md docs/code-review.md; do
    [ -f "$f" ] && { guide_file=$f; break; }
  done
fi
case "$guide_file" in
  *\"*|*\\*) echo "The review guide path may not hold quotes or backslashes." >&2; exit 2 ;;
esac
if [ -n "$guide_file" ]; then
  [ -f "$guide_file" ] || { echo "Review guide not found: $guide_file" >&2; exit 2; }
  read_guide="First read $guide_file and apply its patterns and checklist. Then read"
else
  read_guide="Read"
fi

# One text for both reviewers. No double quotes or backslashes: Codex parses it as a TOML string.
guide="Review this change for defects only. $read_guide the diff and the code around it. Do not run tests, builds, installs or anything that needs the network or opens a port. The author runs the tests. Report only problems in the changed code, most severe first. For each one give a priority from P0 to P3, the path relative to the repo root with the line, what goes wrong, a concrete failure scenario and a suggested fix. Leave out how you ran, tool or sandbox problems, and what you could not check. If you find nothing, say No findings."

limit=1800 # seconds
# Drop API keys so each CLI uses its own login (ChatGPT for Codex, claude.ai for Claude)
# instead of billing an API key. Nothing here reads a token.
run() { env -u ANTHROPIC_API_KEY -u OPENAI_API_KEY perl -e 'alarm shift; exec @ARGV' "$limit" "$@"; }

if [ "$reviewer" = opus ]; then
  run claude -p \
    --model claude-opus-5-5 --effort "$effort" \
    --tools Read,Grep,Glob,Bash \
    --allowedTools Read Grep Glob 'Bash(git diff:*)' 'Bash(git log:*)' 'Bash(git show:*)' \
    --permission-mode dontAsk --no-session-persistence --output-format text \
    "$guide The change is git diff $diffbase...HEAD. Write each finding as: - [P1] Short title — path/to/file.ts:63, then the scenario and fix on the next lines." \
    > "$review" 2> "$log" < /dev/null
else
  run codex exec review --base "$diffbase" \
    -m gpt-6.1-sol \
    -c "model_reasoning_effort=\"$effort\"" \
    -c 'sandbox_mode="read-only"' \
    -c 'approval_policy="never"' \
    -c "developer_instructions=\"$guide\"" \
    --ephemeral --json -o "$review" \
    > "$log" 2>&1 < /dev/null
fi
status=$?

if [ "$status" -ne 0 ] || [ ! -s "$review" ]; then
  echo "Review failed (exit $status). Log: $log" >&2
  rm -f "$review"
  exit 1
fi
echo "$review"
