#!/bin/bash
# CI doble de una PR: espera la corrida de pull_request sobre la cabeza actual, la relanza una vez y
# espera la segunda. Imprime la conclusion de cada job en cada intento.
# Correr desde el repo, con gh autenticado.
#
# Uso: ci-doble.sh <numero-de-pr>
set -uo pipefail
if [ $# -lt 1 ]; then
  sed -n '2,7p' "$0"
  exit 2
fi
PR=$1
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner) || exit 1
HEAD=$(gh api "repos/$REPO/pulls/$PR" --jq .head.sha) || exit 1
echo "#$PR cabeza ${HEAD:0:7}"

RUN=""
for _ in $(seq 1 60); do
  RUN=$(gh api "repos/$REPO/actions/runs?head_sha=$HEAD&event=pull_request" --jq '.workflow_runs[0].id // empty' 2>/dev/null)
  [ -n "$RUN" ] && break
  sleep 20
done
[ -z "$RUN" ] && { echo "sin corrida de CI para ${HEAD:0:7}"; exit 1; }
echo "corrida $RUN"

RESULTADO=0
for intento in 1 2; do
  while true; do
    st=$(gh api "repos/$REPO/actions/runs/$RUN" --jq '"\(.status) \(.conclusion) \(.run_attempt)"' 2>/dev/null)
    set -- $st
    [ "${1:-}" = completed ] && [ "${3:-}" = "$intento" ] && break
    sleep 45
  done
  echo "intento $intento: $2"
  [ "$2" = success ] || RESULTADO=1
  gh api "repos/$REPO/actions/runs/$RUN/attempts/$intento/jobs" --jq '.jobs[] | "  \(.name): \(.conclusion)"'
  if [ "$intento" = 1 ]; then
    gh api -X POST "repos/$REPO/actions/runs/$RUN/rerun" >/dev/null 2>&1 || { echo "no se pudo relanzar"; exit 1; }
    sleep 30
  fi
done
exit $RESULTADO
