#!/bin/bash
# Vigia de las sesiones en la nube, para correr dentro de un Monitor: emite una linea por commit
# nuevo en las ramas de las sesiones, por PR abierta o cerrada, y avisa si una rama pasa mucho tiempo
# sin commits. Solo mira commits posteriores a <desde>.
# Correr desde el repo, con gh autenticado.
#
# Uso: vigia.sh <desde-ISO8601> [prefijo-de-rama=claude/] [minutos-quieta=45]
#   vigia.sh 2026-11-10T00:00:00Z
if [ $# -lt 1 ]; then
  sed -n '2,8p' "$0"
  exit 2
fi
DESDE=$1
PREFIJO=${2:-claude/}
QUIETA=$((${3:-45} * 60))
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner) || exit 1

declare -A last_sha last_ts warned
prev_prs=""
while true; do
  now=$(date -u +%s)
  data=$(gh api "repos/$REPO/branches?per_page=100" --paginate \
    --jq ".[] | select(.name|startswith(\"$PREFIJO\")) | \"\(.name) \(.commit.sha)\"" 2>/dev/null) || {
    sleep 60
    continue
  }
  while read -r name sha; do
    [ -z "$name" ] && continue
    if [ "${last_sha[$name]:-}" != "$sha" ]; then
      info=$(gh api "repos/$REPO/commits/$sha" --jq '"\(.commit.committer.date) \(.commit.message|split("\n")[0])"' 2>/dev/null)
      d=${info%% *}
      [[ "$d" > "$DESDE" ]] && echo "COMMIT $name ${sha:0:7} $info"
      last_sha[$name]=$sha
      last_ts[$name]=$(date -u -d "$d" +%s 2>/dev/null || echo "$now")
      warned[$name]=""
    else
      t=${last_ts[$name]:-$now}
      td=$(date -u -d "@$t" +%Y-%m-%dT%H:%M:%SZ)
      if [[ "$td" > "$DESDE" ]] && [ $((now - t)) -gt $QUIETA ] && [ -z "${warned[$name]:-}" ]; then
        echo "QUIETA $name sin commits hace $(((now - t) / 60)) min"
        warned[$name]=1
      fi
    fi
  done <<<"$data"

  # Sin pipefail, el codigo de salida seria el de sort: una consulta fallida se leeria como "ninguna
  # PR abierta" y avisaria cierres falsos. Se consulta primero y se ordena despues.
  if raw=$(gh api "repos/$REPO/pulls?state=open&per_page=100" --paginate --jq '.[] | "#\(.number) \(.head.ref) \(.title)"' 2>/dev/null); then
    prs=$(sort <<<"$raw")
  else
    prs="$prev_prs"
  fi
  comm -13 <(echo "$prev_prs") <(echo "$prs") | grep . | sed 's/^/PR-ABIERTA /'
  comm -23 <(echo "$prev_prs") <(echo "$prs") | grep . | sed 's/^/PR-CERRADA /'
  prev_prs=$prs
  sleep 90
done
