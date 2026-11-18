#!/bin/bash
# Publica una ficha en una rama docs/ficha-... sin checkout ni worktree: no toca el arbol de trabajo
# ni dispara los hooks de git del repo. Correr desde cualquier carpeta dentro del repo.
#
# Uso: ficha-rama.sh <archivo-local> <ruta-en-repo> <rama> "<mensaje>" [base=la rama principal de origin]
#   ficha-rama.sh ./P31-seguridad.md .docs/tareas/P31-seguridad.md docs/ficha-p31 "docs: ficha de P.31"
set -euo pipefail
if [ $# -lt 4 ]; then
  sed -n '2,7p' "$0"
  exit 2
fi
SRC=$1
DEST=$2
RAMA=$3
MSG=$4
BASE=${5:-$(git symbolic-ref -q --short refs/remotes/origin/HEAD || echo origin/main)}

# Solo ramas de fichas: nunca la principal ni la rama de una sesion.
case "$RAMA" in
  docs/ficha-*) ;;
  *) echo "La rama tiene que empezar con docs/ficha- (llego: $RAMA)"; exit 2 ;;
esac

git fetch -q origin
BASE_SHA=$(git rev-parse "$BASE^{commit}")

IDX=$(mktemp -u "${TMPDIR:-/tmp}/ficha-idx-XXXXXX")
# En Git Bash de Windows, GIT_INDEX_FILE tiene que ser una ruta de Windows (C:/...), no /c/...
if command -v cygpath >/dev/null 2>&1; then IDX=$(cygpath -m "$IDX"); fi
trap 'rm -f "$IDX"' EXIT

export GIT_INDEX_FILE="$IDX"
git read-tree "$BASE_SHA"
BLOB=$(git hash-object -w "$SRC")
git update-index --add --cacheinfo 100644,"$BLOB","$DEST"
TREE=$(git write-tree)
unset GIT_INDEX_FILE

COMMIT=$(git commit-tree "$TREE" -p "$BASE_SHA" -m "$MSG")
git push origin "$COMMIT:refs/heads/$RAMA"
echo "rama $RAMA -> $(git rev-parse --short "$COMMIT") (base $(git rev-parse --short "$BASE_SHA"))"
echo "la sesion la trae con: git fetch origin $RAMA && git checkout origin/$RAMA -- $DEST"
