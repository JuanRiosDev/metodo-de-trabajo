#!/bin/bash
# Prepara un clon del repo para que Codex ejecute una ficha sin tocar el arbol de trabajo del repo ni
# disparar sus hooks: clona origin, crea la rama codex/<id> desde la base, commitea la ficha, copia
# los .env del repo sin imprimirlos y escribe el prompt de Codex en <carpeta>/.git/codex-prompt.md.
# Correr desde cualquier carpeta dentro del repo.
#
# Uso: preparar-clon.sh <ID> <ficha> <carpeta> [base=la rama principal de origin]
#   preparar-clon.sh P.31 ./P31-seguridad.md "$SCRATCH/codex-p31"
# Para una ronda de revision, la base es la rama de la PR revisada.
set -euo pipefail
if [ $# -lt 3 ]; then
  sed -n '2,9p' "$0"
  exit 2
fi
ID=$1
FICHA=$2
DIR=$3
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
BASE=${4:-$(principal)}
BASE=${BASE#origin/}

if [ ! -f "$FICHA" ]; then
  echo "No existe la ficha $FICHA"
  exit 1
fi
# mkdir sin -p falla si la carpeta ya existe: es la forma atomica de tomarla. Solo despues se arma el
# trap, asi nunca borra una carpeta de otra corrida.
mkdir -p "$(dirname "$DIR")"
if ! mkdir "$DIR" 2>/dev/null; then
  echo "Ya existe $DIR: si es la misma tarea, segui en ese clon; si no, elegi otra carpeta."
  exit 1
fi
# Si algo falla de aca en adelante, se borra la carpeta: un clon a medias (sin rama, ficha ni prompt)
# no sirve, y al relanzar el chequeo de arriba lo tomaria por uno valido.
trap 'rm -rf -- "$DIR"' EXIT

RAIZ=$(git rev-parse --show-toplevel)
URL=$(git remote get-url origin)
RAMA="codex/$(printf '%s' "$ID" | tr 'A-Z.' 'a-z-' | tr -cd 'a-z0-9-')"
NOMBRE=$(basename "$FICHA")

# Un clon nuevo no tiene los hooks del repo instalados: el checkout y el commit no los disparan.
git clone -q --no-checkout "$URL" "$DIR"
git -C "$DIR" checkout -q -b "$RAMA" "origin/$BASE"
mkdir -p "$DIR/.docs/tareas"
cp "$FICHA" "$DIR/.docs/tareas/$NOMBRE"
git -C "$DIR" add ".docs/tareas/$NOMBRE"
# Si la base ya trae la ficha igual (una ficha mergeada, o la de una ronda), no hay nada que commitear.
FICHA_ESTADO="ya estaba en la base"
if ! git -C "$DIR" diff --cached --quiet; then
  git -C "$DIR" commit -q -m "docs: ficha de $ID"
  FICHA_ESTADO="commiteada"
fi

# Los .env que git ignora en el repo, a la misma ruta del clon. Solo se nombran.
(cd "$RAIZ" && git ls-files --others --ignored --exclude-standard --directory -z) |
  while IFS= read -r -d '' f; do
    case "$f" in
      .env | */.env | .env.local | */.env.local)
        mkdir -p "$DIR/$(dirname "$f")"
        cp "$RAIZ/$f" "$DIR/$f"
        echo "copiado $f"
        ;;
    esac
  done

cat >"$DIR/.git/codex-prompt.md" <<EOF
Ejecutá la tarea $ID. La ficha \`.docs/tareas/$NOMBRE\` es el pedido completo y ya está commiteada
en tu rama, \`$RAMA\`, que sale de \`origin/$BASE\`. Antes, leé \`CLAUDE.md\`: cómo correr el
proyecto, la verificación, las convenciones y lo que no se toca valen para vos.

- Trabajá en esta rama y en la zona de la ficha. Un commit por punto, con su test, con el formato de
  commits de \`CLAUDE.md\`. Si el sandbox no te deja commitear, dejá los cambios sin commitear y decí
  en tu respuesta qué archivos van en cada punto.
- Anotá lo que elegiste en el archivo de decisiones que nombra la ficha, con la plantilla
  \`.claude/skills/escribir-ficha/plantillas/decisiones.md\`, encabezado con "Codex", tu modelo y tu
  esfuerzo de razonamiento.
- Lo que la ficha diga de una sesión en la nube, de traer la ficha de otra rama o de abrir la PR no es
  para vos: quien revisa tu trabajo pushea y abre la PR. Vos dejás todo en esta rama, sin push, y sin
  tocar \`ROADMAP.md\`.
- Terminás con la verificación de "Cómo entregar" corrida. Tu respuesta final lista cada chequeo con
  su resultado, lo que no pudiste probar y por qué, y las decisiones que tomaste sin que lo dijera la
  ficha.
EOF

trap - EXIT
MOSTRAR=$DIR
if command -v cygpath >/dev/null 2>&1; then MOSTRAR=$(cygpath -m "$DIR"); fi
echo "clon en $MOSTRAR, rama $RAMA desde origin/$BASE ($(git -C "$DIR" rev-parse --short "origin/$BASE")), ficha $FICHA_ESTADO"
echo "prompt: $MOSTRAR/.git/codex-prompt.md"
echo "siguiente: instalar las dependencias en el clon y lanzar"
echo "  bash .claude/skills/delegar-codex/codex.sh task --write --cwd \"$MOSTRAR\" --prompt-file \"$MOSTRAR/.git/codex-prompt.md\""
