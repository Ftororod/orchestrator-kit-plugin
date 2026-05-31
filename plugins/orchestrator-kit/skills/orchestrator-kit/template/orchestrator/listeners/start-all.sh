#!/usr/bin/env bash
# Despacho automatico de prompts — plantilla generica.
# Personaliza CODES con tus ejecutores. Requiere inotify-tools (Linux).
#
# Por cada code: vigila prompts/active/<code>/ y al crearse un .md ejecuta el
# CLI del ejecutor en su repo, dejando la salida en inbox/<code>/.
#
# Idempotencia: cada prompt despachado deja un marcador .<base>.dispatched junto
# a la respuesta en inbox/. Al reiniciar el listener NO se re-ejecutan prompts ya
# despachados (evita ejecuciones duplicadas y gasto repetido de tokens). Para
# re-despachar un prompt a proposito, borra su marcador o muevelo a completed/.

set -euo pipefail

ORCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG_DIR="${HOME}/.cache/orchestrator-listeners"
mkdir -p "${LOG_DIR}"

# Formato: "<code>:<ruta-del-repo-ejecutor>"
CODES=(
  "code-1:/path/al/repo/del/ejecutor-1"
  # "code-2:/path/al/repo/del/ejecutor-2"
)

dispatch_one() {
  local code="$1" repo="$2" prompt_file="$3"
  local base inbox resp marker
  base="$(basename "${prompt_file}" .md)"
  inbox="${ORCH_ROOT}/orchestrator/inbox/${code}"
  resp="${inbox}/${base}_response.md"
  marker="${inbox}/.${base}.dispatched"
  mkdir -p "${inbox}"
  # Saltar si ya fue despachado (idempotencia entre reinicios del listener):
  if [ -e "${marker}" ]; then
    echo "$(date -Iseconds) Saltado (ya despachado): ${prompt_file}" >>"${LOG_DIR}/listener-${code}.log"
    return 0
  fi
  : >"${marker}"
  echo "$(date -Iseconds) Prompt detectado: ${prompt_file}" >>"${LOG_DIR}/listener-${code}.log"
  echo "$(date -Iseconds) Ejecutando claude -p en ${repo}" >>"${LOG_DIR}/listener-${code}.log"
  # Prompt via stdin (evita topar con ARG_MAX en prompts grandes).
  # Ajusta el comando del CLI a tu herramienta si no es claude:
  if ! ( cd "${repo}" && claude -p < "${prompt_file}" >"${resp}" 2>>"${LOG_DIR}/listener-${code}.log" ); then
    echo "$(date -Iseconds) ERROR ejecutando ${prompt_file}" >>"${LOG_DIR}/listener-${code}.log"
    # Fallo: quitar el marcador para permitir reintento en el proximo evento.
    rm -f "${marker}"
  fi
}

watch_code() {
  local code="$1" repo="$2"
  local active="${ORCH_ROOT}/orchestrator/prompts/active/${code}"
  mkdir -p "${active}"
  # Re-evaluar prompts presentes al arrancar (los ya despachados se saltan via marcador):
  for f in "${active}"/*.md; do
    [ -e "${f}" ] || continue
    dispatch_one "${code}" "${repo}" "${f}"
  done
  # Vigilar nuevos:
  inotifywait -m -e create -e moved_to --format '%w%f' "${active}" | while read -r f; do
    case "${f}" in *.md) dispatch_one "${code}" "${repo}" "${f}" ;; esac
  done
}

for entry in "${CODES[@]}"; do
  code="${entry%%:*}"; repo="${entry#*:}"
  watch_code "${code}" "${repo}" &
  echo "Listener arrancado para ${code} (${repo})"
done

wait
