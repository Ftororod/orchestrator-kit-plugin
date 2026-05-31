# orchestrator-kit-plugin

Marketplace de Claude Code (`ftoro-tools`) que distribuye el plugin
**orchestrator-kit**: instala en cualquier proyecto un sistema de *memoria viva
por archivos* + el *metodo orquestador-ejecutor*, para que el conocimiento del
proyecto viva en archivos versionados y no dependa de la memoria del modelo.

Este repo es **a la vez marketplace y hogar del plugin**: el marketplace
(`.claude-plugin/marketplace.json`) en la raiz apunta al plugin en
`plugins/orchestrator-kit/`.

## Que hace el plugin

Aporta el skill `orchestrator-kit` (invocable como `/orchestrator-kit:orchestrator-kit`
o por activacion automatica). Al correrlo, hace scaffolding en el proyecto actual
de una o ambas capas:

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

## Instalacion (en cualquier maquina, sin copiar archivos)

Una vez este repo este en GitHub (ver "Publicar" abajo), en cualquier proyecto:

```
/plugin marketplace add Ftororod/orchestrator-kit-plugin
/plugin install orchestrator-kit@ftoro-tools
```

Verifica:

```
/plugin list
```

Uso: escribe `/orchestrator-kit` (o frases como "monta la memoria viva del
proyecto" / "modo orquestador") y el skill te guia por el scaffolding.

## Publicar este repo (primera vez)

`gh` no esta disponible en la maquina donde se genero, asi que crea el repo en
GitHub manualmente o con tu CLI y luego:

```bash
cd /home/labvm/orchestrator-kit-plugin
git remote add origin git@github.com:Ftororod/orchestrator-kit-plugin.git
git branch -M main
git push -u origin main
```

El repo en GitHub debe llamarse `orchestrator-kit-plugin` bajo la cuenta `Ftororod`
(crealo vacio, sin README, antes del push). Si usas otra cuenta, ajusta el remote
y los campos `homepage`/`repository` en `plugins/orchestrator-kit/.claude-plugin/plugin.json`.

## Actualizar el plugin

Si cambias el plugin, **sube el campo `version`** en
`plugins/orchestrator-kit/.claude-plugin/plugin.json` (semver). Sin bump de
version, los usuarios no reciben la actualizacion. Luego:

```bash
git commit -am "orchestrator-kit vX.Y.Z: <cambios>"
git push
```

Los usuarios actualizan con `/plugin marketplace update ftoro-tools`.

## Estructura

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
├── README.md
├── LICENSE
└── CHANGELOG.md
```

## Licencia

MIT. Ver `LICENSE`.
