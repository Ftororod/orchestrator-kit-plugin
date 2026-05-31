# Changelog

Formato basado en Keep a Changelog. El plugin sigue semver.

## [1.2.1] - 2026-05-31

### Fixed
- Limpieza de ocurrencias residuales de "sprint" -> "frente" en `CLAUDE.md`,
  README de prompts y `ideas-huerfanas.md` (completa la unificacion de v1.2.0).

## [1.2.0] - 2026-05-31

### Added
- **Hook SessionStart** (`hooks/hooks.json` + `hooks/session-start.sh`): inyecta
  `MEMORY.md`, `napkin.md`, `current-state.md` y un listado de inbox/prompts en
  vuelo al contexto al arrancar la sesion. Convierte el ritual de arranque de
  "instruccion que el modelo puede olvidar" a enforcement real. No-op silencioso
  en proyectos sin el kit; siempre sale 0.

### Changed
- `listeners/start-all.sh`: idempotencia entre reinicios via marcador
  `.<base>.dispatched` (no re-ejecuta prompts ya despachados); prompt al CLI por
  stdin en vez de argumento (evita ARG_MAX en prompts grandes); el marcador se
  borra si la ejecucion falla para permitir reintento.
- Terminologia unificada a "frente" (antes mezclaba "sprint"/"frente") en
  `CLAUDE.md`, `current-state.md` y plantillas de prompt.

## [1.1.0] - 2026-05-31

### Added
- Paso de **modo de persistencia de memoria** en el skill: pregunta Local-only
  (gitignored, default recomendado, seguro en repos publicos) vs Versioned
  (solo repos privados).
- Generacion automatica de `.gitignore` con las exclusiones de memoria/state
  cuando se elige Local-only; detecta y des-trackea archivos ya staged/committed.
- Aviso explicito si el repo es publico y la memoria ya fue pusheada (historia expuesta).
- Nota de privacidad en el `template/CLAUDE.md` para que el orquestador instalado
  entienda su propio modo de memoria.

### Changed
- Step 6 (commit) verifica que no haya memoria staged en Local-only y prohibe
  mezclar el commit del scaffolding con cambios pre-existentes del working tree.

## [1.0.0] - 2026-05-31

### Added
- Plugin `orchestrator-kit` con el skill homonimo.
- Capa de memoria viva por archivos: `.claude/memory/` + `MEMORY.md` + `MEMORY-SYSTEM.md`.
- Scaffolding del metodo orquestador-ejecutor: `CLAUDE.md` con rituales, 8 categorias
  de anotacion, `napkin.md`, `orchestrator/state/` (6 archivos),
  `handoff-archive/`, `prompts/{active,completed,_templates}`, `inbox/`, `listeners/`.
- Marketplace `ftoro-tools` que distribuye el plugin desde este mismo repo.
- Resolucion del directorio `template/` via `CLAUDE_PLUGIN_ROOT` para instalaciones de plugin.
