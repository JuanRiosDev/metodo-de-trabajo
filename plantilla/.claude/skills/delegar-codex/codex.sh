#!/bin/bash
# Llama al runtime del plugin de Codex para Claude Code (openai/codex-plugin-cc) con los argumentos
# que reciba. Es la forma de usar el plugin desde una skill: /codex:review y /codex:adversarial-review
# solo los puede escribir el usuario.
#
# Uso: codex.sh <setup|task|review|adversarial-review|status|result|cancel> [opciones]
#   codex.sh setup
#   codex.sh task --write --cwd <clon> --prompt-file <archivo>
#   codex.sh adversarial-review --wait --cwd <clon> --base origin/main "<foco>"
# El modelo y el esfuerzo salen de ~/.codex/config.toml (model, model_reasoning_effort).
set -euo pipefail
if [ $# -lt 1 ]; then
  sed -n '2,10p' "$0"
  exit 2
fi

PLUGINS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins"
# El instalado (plugins/cache/<marketplace>/codex/<version>), y el mas nuevo si quedaron versiones
# viejas. plugins/marketplaces tiene otra copia, la del repo del plugin, solo como ultimo recurso.
buscar() {
  { find "$1" -type f -name codex-companion.mjs -path '*codex*' -printf '%T@ %p\n' 2>/dev/null || true; } |
    sort -rn | sed -n '1s/^[^ ]* //p'
}
RUNTIME=$(buscar "$PLUGINS/cache")
[ -n "$RUNTIME" ] || RUNTIME=$(buscar "$PLUGINS")
if [ -z "$RUNTIME" ]; then
  echo "No encuentro el plugin de Codex en $PLUGINS. En Claude Code:"
  echo "  /plugin marketplace add openai/codex-plugin-cc"
  echo "  /plugin install codex@openai-codex"
  echo "  /reload-plugins y /codex:setup"
  exit 3
fi
# node en Windows necesita la ruta como C:/...
if command -v cygpath >/dev/null 2>&1; then RUNTIME=$(cygpath -m "$RUNTIME"); fi
exec node "$RUNTIME" "$@"
