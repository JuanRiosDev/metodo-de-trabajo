#!/bin/bash
# Arma la combinacion de una rama con la base (el arbol que quedaria en main despues del merge) sin
# checkout ni worktree, y deja una carpeta igual a ese arbol. Conserva lo instalado o generado
# (dependencias, builds, cobertura, .env) para que la siguiente corrida aproveche la cache.
# Correr desde cualquier carpeta dentro del repo.
#
# Uso: combinacion.sh <rama-o-sha> <carpeta> [base=la rama principal de origin]
#   combinacion.sh origin/claude/p31-seguridad-abc123 "$SCRATCH/combo"
#
# La primera vez la carpeta no tiene dependencias: instalalas ahi (npm ci, etc.) o enlaza las del
# repo (junction en Windows) si el lockfile es el mismo. El .env se copia sin imprimirlo.
set -euo pipefail
if [ $# -lt 2 ]; then
  sed -n '2,12p' "$0"
  exit 2
fi
REF=$1
DIR=$2
# Rama principal: la que origin dice hoy (sigue un renombre o un clon sin origin/HEAD), si no la
# que quedo registrada, y si no main.
principal() {
  local r
  git remote set-head origin -a >/dev/null 2>&1 || true
  if r=$(git symbolic-ref -q --short refs/remotes/origin/HEAD) && git rev-parse -q --verify "$r^{commit}" >/dev/null; then
    echo "$r"
  else
    echo origin/main
  fi
}
BASE=${3:-$(principal)}

# Carpetas y archivos que la sincronizacion no toca.
PRUNE=(node_modules dist build coverage .venv venv __pycache__ .next .turbo generated)
KEEP_FILES='(^|/)\.env(\.local)?$|^\.combinacion$'

git fetch -q origin
HEAD_SHA=$(git rev-parse "$REF^{commit}")
BASE_SHA=$(git rev-parse "$BASE^{commit}")

if ! OUT=$(git merge-tree --write-tree "$BASE_SHA" "$HEAD_SHA"); then
  echo "La rama choca con $BASE: hay que juntarlas en una sesion aparte."
  echo "$OUT"
  exit 1
fi
TREE=$(echo "$OUT" | head -1)
COMBO=$(git commit-tree "$TREE" -p "$BASE_SHA" -p "$HEAD_SHA" -m "combinacion de $REF con $BASE")

mkdir -p "$DIR"
WANT=$(mktemp)
HAVE=$(mktemp)
trap 'rm -f "$WANT" "$HAVE"' EXIT
git -c core.quotepath=off ls-tree -r --name-only "$COMBO" | sort >"$WANT"

prune_expr=()
for p in "${PRUNE[@]}"; do prune_expr+=(-name "$p" -o); done
unset 'prune_expr[${#prune_expr[@]}-1]'
(cd "$DIR" && find . \( "${prune_expr[@]}" \) -prune -o -type f -print |
  sed 's|^\./||' | grep -Ev "$KEEP_FILES" | sort) >"$HAVE" || true

SOBRAN=$(comm -13 "$WANT" "$HAVE" | wc -l)
comm -13 "$WANT" "$HAVE" | while IFS= read -r f; do rm -f -- "$DIR/$f"; done
git archive "$COMBO" | tar -x -C "$DIR"

printf 'rama %s\nbase %s\ncombinacion %s\narbol %s\n' "$HEAD_SHA" "$BASE_SHA" "$COMBO" "$TREE" >"$DIR/.combinacion"
echo "combinacion $(git rev-parse --short "$COMBO") en $DIR ($SOBRAN archivos viejos borrados)"
echo "rama ${HEAD_SHA:0:7} + base ${BASE_SHA:0:7} -> arbol $TREE"
echo "despues del merge: git rev-parse $BASE^{tree} tiene que dar $TREE"
