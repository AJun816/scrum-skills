# AGENTS.md

Scrum Skills harness guide for coding agents working in this repository.
This file is a map, not a full manual.

## Quick Navigation

- Global usage: `README.md`
- Harness constraints: `skills/config/harness-playbook.md`
- Harness references: `skills/config/harness-references.md`
- Mandatory rules: `skills/config/mandatory-rules.md`
- Workflow details: `skills/config/workflow-guide.md`
- Setup/bootstrap logic: `skills/hooks/setup.sh`

## 1. Execution Contract

Follow a strict sequence for all non-trivial work:

1. Understand: read related files first, confirm scope and constraints.
2. Plan: produce a short task plan before large edits.
3. Implement: make focused, minimal, reversible changes.
4. Verify: run checks/scripts and confirm behavior.
5. Persist: update docs or progress artifacts if workflow changed.

Do not skip directly from prompt to large code generation.

## 2. Context Discipline

- Keep active context compact; avoid loading unrelated files.
- Prefer progressive disclosure: read root docs, then module docs, then file-level details.
- If discussion or working context gets too long/noisy, summarize and continue from the summary.

## 3. Persistent Memory

Use repository artifacts as source of truth, not chat history:

- `README.md`: install and usage entrypoint.
- `skills/config/harness-playbook.md`: Harness baseline and backpressure gates.
- `skills/config/*.md`: shared rules and workflow constraints.
- `skills/hooks/setup.sh`: initialization and local bootstrap behavior.
- `.cache/shared/repo-map.md`: generated project map (when repository context is available).

If behavior changes, update the relevant file in the same change set.

## 4. Quality Guardrails

- Prefer deterministic shell scripts over manual instructions.
- Keep install flow idempotent: rerun should not break existing setups.
- Avoid destructive post-install cleanup.
- Favor machine-checkable constraints (hooks/scripts) over prose-only rules.

## 5. Done Criteria

A change is complete only when:

- `sh install.sh` works as the primary installation path.
- The repository remains intact after installation.
- Documentation matches actual script behavior.
