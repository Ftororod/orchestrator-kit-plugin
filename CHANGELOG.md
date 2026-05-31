# Changelog

Formato basado en Keep a Changelog. El plugin sigue semver.

## [1.0.0] - 2026-05-31

### Added
- Plugin `orchestrator-kit` con el skill homonimo.
- Capa de memoria viva por archivos: `.claude/memory/` + `MEMORY.md` + `MEMORY-SYSTEM.md`.
- Scaffolding del metodo orquestador-ejecutor: `CLAUDE.md` con rituales, 8 categorias
  de anotacion, `napkin.md`, `orchestrator/state/` (6 archivos),
  `handoff-archive/`, `prompts/{active,completed,_templates}`, `inbox/`, `listeners/`.
- Marketplace `ftoro-tools` que distribuye el plugin desde este mismo repo.
- Resolucion del directorio `template/` via `CLAUDE_PLUGIN_ROOT` para instalaciones de plugin.
