---
name: orchestrator-kit
description: Scaffold a living-memory + orchestrator system into the current project. Use when the user wants persistent file-based project memory (memory/ + MEMORY.md), or the full orchestrator-executor method (state files for decisions/pendings/pain-points/tracking, start/close session rituals in CLAUDE.md, napkin, prompts/inbox dispatch flow) so the project's knowledge lives in versioned files instead of the model's memory. Triggers include "memoria viva", "memoria persistente del proyecto", "modo orquestador", "replicar el sistema de memoria", "living memory", "orchestrator method", "set up project memory".
---

# Orchestrator Kit — living memory + orchestrator scaffolding

Bundles a battle-tested system so any project keeps its knowledge in versioned
files that the model reads on start and maintains on close, instead of relying on
the model's memory. The full template ships inside this skill at `template/`.

## What this skill installs

Two layers, install one or both:

1. Living memory (file-based) — `.claude/memory/` with one fact per file
   (frontmatter: `name`, `description`, `metadata.type` = user|feedback|project|reference)
   plus `MEMORY.md` as the index the model reads at startup. Full rationale in
   `template/MEMORY-SYSTEM.md`.
2. Orchestrator scaffolding — `CLAUDE.md` with start/close rituals + the 8
   annotation categories + orchestrator-executor flow; `.claude/napkin.md`
   runbook; `orchestrator/state/` (decision-log, current-state, pain-points,
   comparativo-tracking, visual-validations, discarded); `orchestrator/handoff-archive/`;
   `orchestrator/prompts/{active,completed,_templates}`; `orchestrator/inbox/`;
   optional `orchestrator/listeners/` auto-dispatch.

## How to run this skill

Do NOT ask the user to paste any files. Everything needed is in this skill's
`template/` directory. Follow these steps.

### Step 1 — find the skill's template directory

The template lives next to this SKILL.md, at `<this-skill-dir>/template/`. Locate
it robustly (the home path varies per machine) by searching under the Claude
config dirs for a SKILL.md whose path contains `orchestrator-kit`, then take its
directory and append `/template`. If nothing is found, search the whole
filesystem for a directory path ending in `orchestrator-kit/template`.

### Step 2 — choose scope and gather inputs

Use AskUserQuestion to ask:
- Scope: full kit (memory + orchestrator) | only living memory | only orchestrator scaffolding.
- Target: confirm the install directory (default: current repo root).

Then collect the placeholder values to substitute (ask in one batched message,
skip any the user does not have yet — they can fill later):
- `<PROYECTO>` — project name.
- `<NOMBRE_PO>` — product owner / decision-maker name.
- Codes activos — list of executor agents: name + repo path + one-line description.
- Idioma/forma — prose language and any tone/dialect rules.

### Step 3 — copy the chosen files into the target

- Full kit: copy the whole `template/` tree into the target root.
- Only living memory: copy `template/.claude/memory/` and `template/MEMORY-SYSTEM.md`,
  and append the "Memoria viva del proyecto" section from `template/CLAUDE.md` to
  the target's existing `CLAUDE.md` (create it if absent).
- Only orchestrator scaffolding: copy everything EXCEPT `.claude/memory/` and
  `MEMORY-SYSTEM.md`.

Never overwrite an existing `CLAUDE.md`, `MEMORY.md`, napkin, or populated state
file without showing the user the conflict first. If the target already has these,
merge by appending the missing sections rather than clobbering.

### Step 4 — substitute placeholders

Replace every `<...>` placeholder in the copied files with the values gathered in
step 2. At minimum: `<PROYECTO>`, `<NOMBRE_PO>`, the "Codes activos" block, the
idioma/forma block, and `<YYYY-MM-DD>` headers (use today's date). Leave example
blocks (HTML comments) as guidance or strip them per the user's preference. Tell
the user which placeholders you could not fill so they finish them.

### Step 5 — confirm and optionally commit

Show the tree you created. If the target is a git repo and the user wants it,
stage and commit the scaffolding. From here the system travels with the repo.

## Key rules to convey to the user (so the system actually works)

- The rituals in `CLAUDE.md` are what make the model USE the files. Without the
  start-of-session read and end-of-session write, the files exist but go stale.
- One fact per memory file. Update existing files, do not duplicate. Delete false
  memories. Do not store what the repo already records. Absolute dates only.
- Executors do NOT reliably inherit the orchestrator's CLAUDE.md — inject the
  executor rules inline in every prompt (see `template/orchestrator/prompts/_templates/`).

## Self-contained fallback

If `template/` cannot be located, you can still scaffold from scratch: the full
content and rationale for every file is documented in `template/MEMORY-SYSTEM.md`
(memory layer) and `template/CLAUDE.md` (orchestrator layer). Recreate the
structure described in "What this skill installs" using those as the spec.
