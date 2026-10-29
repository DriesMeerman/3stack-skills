# Repository instructions

This repository collects skills for use by multiple agents: skills imported from upstream, and skills authored or adapted here.

## Imports

- Store each skill at `skills/<name>/SKILL.md`, with the directory name matching the skill's frontmatter `name`.
- Preserve upstream instructions and existing frontmatter. Do not rewrite, reformat, renumber, or otherwise edit imported skills.
- Add only provenance metadata to imported frontmatter. Use `metadata.source` for the original skill URL and `metadata.source-commit` for the full upstream commit SHA. Preserve any existing metadata keys.
- Copy supporting files referenced by a skill, preserving relative paths.
- Include the applicable upstream license and copyright notice with each imported skill. Do not apply one imported skill's license to the whole collection.
- Update the README's skill table when adding or removing a skill.

## Authored skills

- Store them the same way, at `skills/<name>/SKILL.md`, with no `metadata.source`.
- Keep them generic. No project names, private repo details, people's names, issue numbers or machine-specific paths. Read project specifics from the project's own agent instructions at run time; `skills/start-work/project-rules.md` lists what to look up.
- A skill adapted from licensed work keeps that work's license notice in its own directory, so each skill can be copied on its own.
- Link to other skills by relative path (`../<name>/SKILL.md`), and keep every link pointing at a file in this repo.
- Update the README's skill table when adding or removing a skill.

## Verification

Compare every imported file with its source at the recorded commit. For `SKILL.md`, removing the added provenance metadata must reproduce the original file byte for byte. Supporting files and licenses must match their sources byte for byte.

For authored skills, check that every relative link resolves, that scripts pass a syntax check (`bash -n`, `node --check`), and that no project-specific names remain.

## Agent use

Each agent must load the skills it needs. Preserve invocation controls supplied by upstream skills. Keep agent-specific installation settings outside the skill files.
