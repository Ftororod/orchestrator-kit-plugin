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

## Privacidad: repo publico vs privado

La memoria y los state files contienen decisiones, fricciones y notas internas
del proyecto. El ritual de cierre termina en `commit + push`, asi que **en un
repo publico eso se publicaria**. Por eso, al instalar, el skill pregunta el
**modo de persistencia de memoria**:

- **Local-only (gitignored)** — default recomendado. La memoria vive solo en tu
  maquina, excluida de git via `.gitignore` (el skill lo genera automaticamente).
  Seguro en cualquier repo, incluido publico. Sobrevive entre sesiones pero no
  viaja entre maquinas por git.
- **Versioned (committed)** — la memoria viaja con el repo y sincroniza entre
  maquinas. Solo para repos **privados**. Nunca para publicos.

En modo Local-only el `commit + push` del cierre simplemente salta los archivos
ignorados, sin error: se versiona el metodo (`CLAUDE.md`, `MEMORY-SYSTEM.md`,
plantillas), no los datos. Nunca escribas secretos reales en memoria.

## El problema que resuelve

Claude no recuerda nada entre sesiones: su unica memoria es el contexto de la
conversacion actual, que se pierde al cerrar. Cada sesion nueva arranca a ciegas
y se gastan tokens reconstruyendo donde quedo el proyecto, que se decidio y por
que. Este kit mueve ese conocimiento a **archivos versionados** que el modelo
LEE al arrancar y ESCRIBE al cerrar. El estado del proyecto vive en el repo, no
en el modelo. Cualquier sesion, en cualquier maquina, arranca con el mismo
estado.

## Que instala el skill

Una o ambas capas, segun elijas:

### 1. Memoria viva (por archivos)

`.claude/memory/` con **un hecho por archivo** (markdown + frontmatter), mas
`MEMORY.md` como indice que el modelo carga al arrancar. Cada archivo:

```markdown
---
name: <slug-kebab-case>
description: <resumen de una linea — sirve para decidir relevancia al recordar>
metadata:
  type: user | feedback | project | reference
---

<el hecho>
```

Los 4 tipos:

- `user` — quien es el PO/usuario: rol, expertise, preferencias de trabajo.
- `feedback` — guia sobre como trabajar (correcciones, enfoques confirmados); incluye el **porque**.
- `project` — trabajo en curso, metas, restricciones no derivables del codigo/git; fechas absolutas.
- `reference` — punteros a recursos externos (URLs, dashboards, tickets).

Disciplina: un hecho por archivo; actualizar en vez de duplicar; borrar memorias
falsas; no guardar lo que el repo ya registra; fechas absolutas. Racional
completo en el `MEMORY-SYSTEM.md` que instala.

### 2. Scaffolding del orquestador

El metodo orquestador-ejecutor: una instancia "orquestadora" mantiene el estado
y reparte trabajo a instancias "ejecutoras". Instala:

- `CLAUDE.md` — define el rol orquestador con los **rituales de arranque y cierre**
  (ver abajo), las **8 categorias de anotacion** y el flujo orquestador-ejecutor.
- `.claude/napkin.md` — runbook curado de lecciones tecnicas recurrentes.
- `orchestrator/state/` — los 6 archivos de estado persistente:
  `decision-log.md`, `current-state.md`, `pain-points.md`,
  `comparativo-tracking.md`, `visual-validations.md`, `discarded.md`.
- `orchestrator/handoff-archive/ideas-huerfanas.md` — ideas no priorizadas.
- `orchestrator/prompts/{active,completed,_templates}/` — prompts en vuelo, archivados y plantillas.
- `orchestrator/inbox/` — respuestas de los ejecutores.
- `orchestrator/listeners/` — despacho automatico de prompts (opcional).

## El ciclo de una sesion: arranque y cierre

El valor del kit esta en los dos rituales que instala en `CLAUDE.md`. Son lo que
obliga al modelo a usar los archivos; sin ellos, los archivos existen pero se
quedan obsoletos.

### Al arrancar (obligatorio, en orden)

1. Leer `.claude/memory/MEMORY.md` y abrir las memorias relevantes a la tarea.
2. Leer `.claude/napkin.md` y reportar contenido al PO.
3. Leer `orchestrator/state/current-state.md` y reportar resumen al PO.
4. Listar `orchestrator/inbox/*/` por respuestas nuevas sin procesar.
5. Listar `orchestrator/prompts/active/*/` por prompts en vuelo.
6. Reportar: "Estado actual: X frentes abiertos, Y respuestas en inbox, Z
   decisiones pendientes. Por donde?"

### Al cerrar (obligatorio, en orden) — aqui se anota todo

Este es el cierre donde el modelo vuelca TODO lo que paso en la sesion a sus
archivos, para que la proxima arranque sin perdida:

1. Volcar pendientes a `orchestrator/state/current-state.md`.
2. Registrar decisiones nuevas del PO en `orchestrator/state/decision-log.md`, con fecha.
3. Registrar fricciones nuevas en `orchestrator/state/pain-points.md`, si hubo.
4. Memoria viva: guardar hechos nuevos (user/feedback/project/reference) y
   actualizar `.claude/memory/MEMORY.md`.
5. Actualizar `.claude/napkin.md` si surgio guidance recurrente nuevo.
6. Commit + push del branch.
7. Reportar el cierre:
   ```
   ESTADO_GUARDADO: <archivos modificados>
   PROXIMO_PASO: <que viene>
   OPEN: <pendientes reales para la proxima sesion>
   ```

### Las 8 categorias de anotacion

La regla de oro del cierre: **cualquier dato que paso por la sesion debe terminar
en uno de estos archivos**. Antes de cerrar, el modelo verifica que cada dato
relevante este en su lugar.

| # | Categoria | Archivo destino |
|---|---|---|
| 1 | Decisiones del PO | `orchestrator/state/decision-log.md` |
| 2 | Pendientes operativos | `orchestrator/state/current-state.md` |
| 3 | Quejas / fricciones | `orchestrator/state/pain-points.md` |
| 4 | Ideas no priorizadas | `orchestrator/handoff-archive/ideas-huerfanas.md` |
| 5 | Lecciones tecnicas recurrentes | `.claude/napkin.md` |
| 6 | Tracking comparativo (antes/despues, sistema viejo vs nuevo) | `orchestrator/state/comparativo-tracking.md` |
| 7 | Validaciones manuales/visuales hechas | `orchestrator/state/visual-validations.md` |
| 8 | Descartado y por que | `orchestrator/state/discarded.md` |

## Flujo orquestador-ejecutor (capa 2)

Cuando usas la capa de orquestador, el ciclo de trabajo es:

1. El orquestador escribe un prompt autosuficiente en
   `orchestrator/prompts/active/<code>/<fecha>_<slug>.md` (inyecta inline las
   reglas del ejecutor, no asume contexto previo).
2. Comitea y despacha (manual, o via los listeners opcionales).
3. El ejecutor corre y deja su respuesta en
   `orchestrator/inbox/<code>/<mismo-archivo>_response.md`.
4. El orquestador lee la respuesta, actualiza el state y archiva el par
   (prompt + respuesta) en `orchestrator/prompts/completed/<code>/`.

Las dos capas son independientes: puedes instalar solo la memoria viva si no
necesitas el esquema multi-instancia.

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
