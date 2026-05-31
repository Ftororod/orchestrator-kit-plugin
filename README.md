# orchestrator-kit-plugin

Plugin de Claude Code que instala en cualquier proyecto un sistema de **memoria
viva por archivos** + el **metodo orquestador-ejecutor**, para que el
conocimiento del proyecto viva en archivos versionados y no dependa de la
memoria del modelo.

Este repo es a la vez **marketplace** (`ftoro-tools`) y **hogar del plugin**
(`orchestrator-kit`): el `marketplace.json` en la raiz apunta al plugin en
`plugins/orchestrator-kit/`.

## Instalacion

En cualquier maquina o proyecto, dentro de Claude Code:

```
/plugin marketplace add Ftororod/orchestrator-kit-plugin
/plugin install orchestrator-kit@ftoro-tools
```

Verifica con `/plugin list` (debe aparecer `orchestrator-kit@ftoro-tools`,
estado `enabled`).

## Uso

Invoca el skill (queda namespaced bajo el plugin):

```
/orchestrator-kit:orchestrator-kit
```

Tambien se activa automaticamente con frases como "monta la memoria viva del
proyecto" o "modo orquestador". El skill te pregunta el alcance y hace el
scaffolding en el proyecto actual.

## Que instala el skill

Una o ambas capas, segun elijas:

1. **Memoria viva (por archivos)** — `.claude/memory/` con un hecho por archivo
   (frontmatter `name` / `description` / `metadata.type` = user|feedback|project|reference)
   y `MEMORY.md` como indice que el modelo lee al arrancar. Racional completo en
   el `MEMORY-SYSTEM.md` que instala.
2. **Scaffolding del orquestador** — `CLAUDE.md` con rituales de arranque/cierre,
   las 8 categorias de anotacion y el flujo orquestador-ejecutor; `.claude/napkin.md`;
   `orchestrator/state/` (decision-log, current-state, pain-points,
   comparativo-tracking, visual-validations, discarded); `orchestrator/handoff-archive/`;
   `orchestrator/prompts/{active,completed,_templates}`; `orchestrator/inbox/`;
   y `orchestrator/listeners/` (despacho automatico opcional).

## Estructura del repo

```
orchestrator-kit-plugin/
├── .claude-plugin/
│   └── marketplace.json              # catalogo (marketplace "ftoro-tools")
├── plugins/
│   └── orchestrator-kit/
│       ├── .claude-plugin/
│       │   └── plugin.json           # manifest del plugin
│       └── skills/
│           └── orchestrator-kit/
│               ├── SKILL.md          # instrucciones del skill
│               └── template/         # archivos que el skill copia al proyecto
├── README.md  ·  CHANGELOG.md  ·  LICENSE
```

## Publicar actualizaciones

Al cambiar el plugin, **sube el campo `version`** en
`plugins/orchestrator-kit/.claude-plugin/plugin.json` (semver). Sin bump de
version los usuarios no reciben la actualizacion. Luego:

```bash
git commit -am "orchestrator-kit vX.Y.Z: <cambios>"
git push
```

Los usuarios actualizan con `/plugin marketplace update ftoro-tools`.

## Licencia

MIT. Ver `LICENSE`.
