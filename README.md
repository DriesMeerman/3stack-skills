# Skills

A collection of skills I share with my agents.

Each skill lives in `skills/<name>/SKILL.md` and uses the [Agent Skills format](https://agentskills.io/specification). Imported instructions and existing frontmatter stay as written upstream. Added source metadata records the original URL and the exact upstream commit.

## Available skills

| Skill | Purpose | Original source |
| --- | --- | --- |
| [unslop](skills/unslop/SKILL.md) | Remove AI writing patterns. | [cursor/plugins](https://github.com/cursor/plugins/blob/main/pstack/skills/unslop/SKILL.md) |

## Use with agents

Clone this repository:

```sh
git clone https://github.com/DriesMeerman/skills.git
```

Copy or link the whole `skills/unslop` directory into your agent's configured skills directory. Keep bundled licenses and any supporting files with the skill. Repeat for each agent, or configure them to read the same shared directory.

For agents that accept skill files directly, ask them to load `skills/unslop/SKILL.md`. Make each agent load the skill it needs. Loading a skill into one agent does not establish that another agent has loaded it.

Unslop retains its upstream `disable-model-invocation: true` setting. Invoke it explicitly in clients that honor that setting.

## Add a skill

Create `skills/<name>/` and copy the upstream `SKILL.md` and any supporting files it needs. Preserve existing content, filenames, relative references, and license notices. Add attribution under the frontmatter's `metadata` mapping:

```yaml
metadata:
  source: https://github.com/owner/repo/blob/main/path/to/SKILL.md
  source-commit: "<full upstream commit SHA>"
```

If the skill already has `metadata`, add these keys to that mapping. Update the table above after importing a skill.

## Licenses

Imported skills retain their upstream licenses. Unslop is distributed under the MIT license, with the original notice in [skills/unslop/LICENSE](skills/unslop/LICENSE).
