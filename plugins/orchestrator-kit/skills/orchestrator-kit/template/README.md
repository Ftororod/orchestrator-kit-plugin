# Orchestrator template

Plantilla generica para correr un proyecto con el metodo orquestador-ejecutor y
memoria viva por archivos. El conocimiento del proyecto vive en archivos
versionados que el modelo lee al arrancar y mantiene al cerrar, no en la memoria
del modelo.

## Que incluye

- `CLAUDE.md` — instrucciones del rol orquestador: rituales de arranque/cierre, memoria viva, 8 categorias de anotacion, flujo orquestador-ejecutor, formato de emision de prompts.
- `MEMORY-SYSTEM.md` — explicacion completa del subsistema de memoria por archivos (el "por que" y el "como").
- `.claude/memory/` — memoria viva: un hecho por archivo + `MEMORY.md` como indice.
- `.claude/napkin.md` — runbook curado de lecciones tecnicas recurrentes.
- `orchestrator/state/` — los 6 archivos de estado persistente (decisiones, pendientes, fricciones, tracking, validaciones, descartado).
- `orchestrator/handoff-archive/` — ideas no priorizadas.
- `orchestrator/prompts/` — prompts en vuelo (`active/`), completados (`completed/`) y plantillas (`_templates/`).
- `orchestrator/inbox/` — respuestas de los ejecutores.
- `orchestrator/listeners/` — patron opcional de despacho automatico de prompts.

## Bootstrap en un proyecto nuevo

1. Copia esta carpeta a la raiz de tu proyecto (o usala como repo del orquestador).
2. Abre `CLAUDE.md` y reemplaza todos los placeholders `<...>`: nombre del proyecto, nombre del PO, lista de Codes activos, reglas de idioma.
3. Edita la cabecera de cada archivo en `orchestrator/state/` con el contexto de tu proyecto (o dejalos como estan; tienen estructura vacia lista para poblar).
4. Decide donde vive la memoria (repo-committed en `.claude/memory/` es el default; ver `MEMORY-SYSTEM.md` seccion 2).
5. Personaliza `orchestrator/prompts/_templates/executor-rules.md` con las reglas que quieras inyectar a tus ejecutores.
6. Commit inicial. Desde aqui todo viaja con el repo.
7. Primera sesion: el orquestador lee `MEMORY.md` (vacio), `napkin.md` y `current-state.md`, y empieza a poblarlos con el uso.

## Filosofia en una linea

No dependas de que el modelo recuerde. Escribe los hechos en archivos, haz que
el modelo los lea al arrancar y los mantenga al cerrar.
