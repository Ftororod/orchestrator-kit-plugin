---
name: orchestrator-kit
description: Scaffold a living-memory + orchestrator system into the current project. Use when the user wants persistent file-based project memory (memory/ + MEMORY.md), or the full orchestrator-executor method (state files for decisions/pendings/pain-points/tracking, start/close session rituals in CLAUDE.md, napkin, prompts/inbox dispatch flow) so the project's knowledge lives in versioned files instead of the model's memory. Triggers include "memoria viva", "memoria persistente del proyecto", "modo orquestador", "replicar el sistema de memoria", "living memory", "orchestrator method", "set up project memory".
---

# Orchestrator Kit — living memory + orchestrator scaffolding

Bundles a battle-tested system so any project keeps its knowledge in versioned
files that the model reads on start and maintains on close, instead of relying on
the model's memory. The full template ships inside this skill at `template/`.

## Enforcement (automatic, plugin-level)

The plugin ships a **SessionStart hook** (`hooks/session-start.sh`) that runs on
every session and injects `MEMORY.md`, `napkin.md`, `current-state.md` and an
inbox/active-prompts listing into the model's context. It makes the startup
read reliable instead of dependent on the model remembering. It no-ops silently
in projects where the kit was never scaffolded. You do NOT install or configure
this — it is active whenever the plugin is enabled. The startup ritual in
`CLAUDE.md` still applies (open relevant detail memories, report to the PO).

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

The template lives next to this SKILL.md, at `<this-skill-dir>/template/`. Resolve
it in this order (the path differs between a personal skill and a plugin install):

1. If the env var `CLAUDE_PLUGIN_ROOT` is set (this skill is running as part of an
   installed plugin), the template is at
   `$CLAUDE_PLUGIN_ROOT/skills/orchestrator-kit/template`.
2. Otherwise search under the Claude config dirs (`$HOME/.claude`,
   `$HOME/.config/claude`) for a SKILL.md whose path contains `orchestrator-kit`,
   take its directory and append `/template`.
3. Last resort, search the filesystem for a directory path ending in
   `orchestrator-kit/template`.

Verify the resolved directory exists and contains `CLAUDE.md` and `MEMORY-SYSTEM.md`
before using it.

### Step 2 — choose scope, memory mode, and gather inputs

First, detect the git context to inform the recommendation: run `git -C <target>
remote -v`. If there is a remote, note its host/URL. You generally cannot tell
public vs private reliably without an API call, so ASK rather than assume.

Use AskUserQuestion to ask:
- Scope: full kit (memory + orchestrator) | only living memory | only orchestrator scaffolding.
- Target: confirm the install directory (default: current repo root).
- **Memory persistence mode** (this is critical — the memory files contain
  project decisions, pain-points, and notes that often must NOT be public):
  - `Local-only (gitignored)` — RECOMMENDED DEFAULT. Memory and state files stay
    on this machine and are excluded from git. Safe for ANY repo, including
    public ones. Memory survives across sessions but does not travel between
    machines via git.
  - `Versioned (committed)` — Memory travels with the repo and syncs across
    machines. Choose this ONLY for PRIVATE repos. NEVER for public repos.

  If the detected remote looks public (e.g. a github.com URL on a repo the user
  describes as open source) or the user is unsure, default to `Local-only` and
  say why.

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

### Step 5 — configure .gitignore (based on memory mode)

This step prevents accidentally publishing project memory. Do it BEFORE any commit.

If the user chose **Local-only (gitignored)** in Step 2, append the following
block to the target's `.gitignore` (create the file if it does not exist; do not
duplicate the block if it is already present). These paths are project DATA that
should stay local; everything else (the method: `CLAUDE.md`, `MEMORY-SYSTEM.md`,
`orchestrator/prompts/_templates/`, README placeholders) stays versionable.

```
# orchestrator-kit: memoria viva y estado del orquestador (local, no versionado)
.claude/memory/
.claude/napkin.md
orchestrator/state/
orchestrator/inbox/
orchestrator/handoff-archive/
orchestrator/prompts/active/
orchestrator/prompts/completed/
```

Then check whether any of these paths were ALREADY staged or committed (a prior
run, or the user staged them). Run `git -C <target> ls-files` filtered to those
paths. If any are tracked, untrack them without deleting the working copy:

```
git -C <target> rm -r --cached .claude/memory .claude/napkin.md orchestrator/state orchestrator/inbox orchestrator/handoff-archive orchestrator/prompts/active orchestrator/prompts/completed
```

(Only run it for the paths that actually exist/are tracked, to avoid errors.)

If the repo is public AND those paths were already PUSHED in a prior commit,
warn the user explicitly: the data is already in the remote history; `.gitignore`
will not remove it retroactively. They must scrub history or treat it as exposed.

If the user chose **Versioned (committed)**, skip this step but reconfirm once
that the repo is private before proceeding to commit.

### Step 6 — confirm and optionally commit

Show the tree you created and the memory mode chosen. If the target is a git repo
and the user wants it, stage and commit the scaffolding.

- In **Local-only** mode, the commit will include the method files and the
  `.gitignore` you wrote, but NOT the memory/state data (git skips ignored paths).
  Verify with `git -C <target> status` that no `.claude/memory/` or
  `orchestrator/state/` files appear staged before committing.
- In **Versioned** mode (private repo only), the commit includes everything.

Never bundle the scaffolding commit with unrelated pre-existing changes in the
working tree — commit the kit in isolation and leave the user's other work alone.

## Key rules to convey to the user (so the system actually works)

- NEVER let project memory/state reach a public repo. The end-of-session ritual
  in `CLAUDE.md` ends in `commit + push`; in a public repo that publishes
  decisions, pain-points and notes. Default to Local-only mode (Step 2/5) unless
  the user confirms a private repo. Never write real secrets into memory either.
- The SessionStart hook injects state at startup, but the rituals in `CLAUDE.md`
  are what make the model USE and MAINTAIN the files. Without the end-of-session
  write-back, the injected state goes stale.
- One fact per memory file. Update existing files, do not duplicate. Delete false
  memories. Do not store what the repo already records. Absolute dates only.
- Executors do NOT reliably inherit the orchestrator's CLAUDE.md — inject the
  executor rules inline in every prompt (see `template/orchestrator/prompts/_templates/`).

## Self-contained fallback

If `template/` cannot be located, you can still scaffold from scratch: the full
content and rationale for every file is documented in `template/MEMORY-SYSTEM.md`
(memory layer) and `template/CLAUDE.md` (orchestrator layer). Recreate the
structure described in "What this skill installs" using those as the spec.
