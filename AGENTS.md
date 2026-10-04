# Repository instructions

This repository collects upstream skills for use by multiple agents.

## Imports

- Store each skill at `skills/<name>/SKILL.md`, with the directory name matching the skill's frontmatter `name`.
- Preserve upstream instructions and existing frontmatter. Do not rewrite, reformat, renumber, or otherwise edit imported skills.
- Add only provenance metadata to imported frontmatter. Use `metadata.source` for the original skill URL and `metadata.source-commit` for the full upstream commit SHA. Preserve any existing metadata keys.
- Copy supporting files referenced by a skill, preserving relative paths.
- Include the applicable upstream license and copyright notice with each imported skill. Do not apply one imported skill's license to the whole collection.
- Update the README's skill table when adding or removing a skill.

## Verification

Compare every imported file with its source at the recorded commit. For `SKILL.md`, removing the added provenance metadata must reproduce the original file byte for byte. Supporting files and licenses must match their sources byte for byte.

## Agent use

Each agent must load the skills it needs. Preserve invocation controls supplied by upstream skills. Keep agent-specific installation settings outside the imported skill files.
