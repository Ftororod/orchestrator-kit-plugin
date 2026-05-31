#!/usr/bin/env bash
# orchestrator-kit — hook SessionStart.
#
# Inyecta la memoria viva del proyecto al contexto al arrancar la sesion, para
# que el ritual de arranque del CLAUDE.md sea FIABLE y no dependa de que el
# modelo recuerde leer los archivos (la pieza critica del metodo, ver
# MEMORY-SYSTEM.md). Su STDOUT se agrega al contexto del modelo en SessionStart.
#
# Se ejecuta en TODO proyecto donde el plugin este habilitado, pero hace no-op
# silencioso si el kit no esta montado (los archivos no existen). Siempre sale 0.

set -u
proj="${CLAUDE_PROJECT_DIR:-$PWD}"

files=(
  "$proj/.claude/memory/MEMORY.md"
  "$proj/.claude/napkin.md"
  "$proj/orchestrator/state/current-state.md"
)

# Si ningun archivo del kit existe, este proyecto no lo usa: salir sin emitir nada.
any=0
for f in "${files[@]}"; do
  [ -f "$f" ] && any=1
done
[ "$any" -eq 0 ] && exit 0

echo "=== orchestrator-kit: memoria viva del proyecto (inyectada al arrancar) ==="
echo "Estos son los archivos de estado persistente. Sigue el ritual de arranque"
echo "del CLAUDE.md: abre las memorias del indice relevantes a la tarea, revisa"
echo "inbox y prompts en vuelo, y reporta el estado al PO antes de continuar."
echo

for f in "${files[@]}"; do
  if [ -f "$f" ]; then
    echo "----- ${f#"$proj"/} -----"
    cat "$f"
    echo
  fi
done

# Capa orquestador (si existe): respuestas en inbox y prompts en vuelo.
if [ -d "$proj/orchestrator/inbox" ]; then
  resp="$(find "$proj/orchestrator/inbox" -name '*_response.md' 2>/dev/null)"
  [ -n "$resp" ] && { echo "----- respuestas en inbox -----"; echo "$resp"; echo; }
fi
if [ -d "$proj/orchestrator/prompts/active" ]; then
  act="$(find "$proj/orchestrator/prompts/active" -name '*.md' 2>/dev/null)"
  [ -n "$act" ] && { echo "----- prompts en vuelo -----"; echo "$act"; echo; }
fi

exit 0
