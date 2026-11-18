#!/bin/bash
# SessionStart de las sesiones de Claude Code en la nube (claude.ai/code).
#
# Deja la VM lista para verificar cambios: dependencias instaladas, servicios corriendo, la base
# migrada y sembrada, y las variables del proyecto exportadas a cada comando de la sesión (vía
# CLAUDE_ENV_FILE). Es idempotente: en una sesión reanudada solo rehace lo que falta.
#
# En local no hace nada: sale enseguida si CLAUDE_CODE_REMOTE no es "true".
# Para rehacerlo a mano dentro de la nube:
#   CLAUDE_CODE_REMOTE=true bash .claude/hooks/cloud-session-start.sh
#
# COMPLETAR: adaptar las secciones marcadas al stack del proyecto (skill adoptar-metodo). Si el
# proyecto no usa sesiones en la nube, borrar este archivo y el hook de .claude/settings.json.

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
LOG=/tmp/session-start.log
: >"$LOG"
FAILED=()

# step <nombre> <comando...>: corre el comando con la salida al log y anota la falla sin cortar
# los pasos siguientes.
step() {
  local name="$1"
  shift
  echo "== $name" >>"$LOG"
  if ! "$@" >>"$LOG" 2>&1; then
    FAILED+=("$name")
    return 1
  fi
}

# --- Variables de entorno de esta VM ------------------------------------------------------------
# COMPLETAR: generar el .env de desarrollo si no existe (secretos aleatorios, URLs a localhost).
# Un secreto que cifra datos sembrados tiene que sobrevivir entre sesiones: se genera una vez.
# Todo lo de este .env se exporta a cada comando de la sesión: un NODE_ENV=development exportado hace
# que un build de producción (`vite build`, por ejemplo) salga en modo desarrollo. Si la app ya asume
# development cuando falta, no lo pongas.
ENV_FILE="$ROOT/.env"
# if [ ! -f "$ENV_FILE" ]; then
#   rand() { node -e "process.stdout.write(require('crypto').randomBytes($1).toString('$2'))"; }
#   cat >"$ENV_FILE" <<EOF
# DATABASE_URL=postgresql://dev:dev@localhost:5432/dev
# JWT_SECRET=$(rand 48 base64url)
# EOF
# fi

# Exporta cada variable del .env que el entorno de la nube no defina ya: lo que se cargue en el
# entorno gana sobre el archivo.
if [ -f "$ENV_FILE" ]; then
  EXPORTS=/tmp/session-env.sh
  : >"$EXPORTS"
  while IFS= read -r line; do
    key="${line%%=*}"
    [[ "$line" == *=* && "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
    value="${line#*=}"
    value="${value#\"}"
    value="${value%\"}"
    if [ -z "${!key+x}" ]; then
      printf "export %s='%s'\n" "$key" "$value" >>"$EXPORTS"
    fi
  done <"$ENV_FILE"
  # shellcheck disable=SC1090
  . "$EXPORTS"
  if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    cat "$EXPORTS" >>"$CLAUDE_ENV_FILE"
  fi
fi

# --- Servicios ----------------------------------------------------------------------------------
# COMPLETAR: arrancar lo que el proyecto necesita (vienen instalados en la imagen, apagados).
# El hook puede no correr como root: `service` va con `sudo -n` (sin pedir contraseña).
as_root() {
  if [ "$(id -u)" = 0 ]; then "$@"; else sudo -n "$@"; fi
}
# if ! pg_isready -h localhost -q 2>/dev/null; then
#   step "Postgres: arrancar" as_root service postgresql start
#   for _ in $(seq 1 30); do pg_isready -h localhost -q && break; sleep 1; done
# fi
# if ! redis-cli ping >/dev/null 2>&1; then
#   step "Redis: arrancar" as_root service redis-server start
# fi

# --- Dependencias: se instalan solo cuando cambia el lockfile -----------------------------------
# COMPLETAR: las carpetas con package-lock.json (o el gestor del proyecto).
DEP_DIRS=(".")
install_deps() {
  local dir="$ROOT/$1"
  local stamp="node_modules/.cloud-install.sha256"
  cd "$dir" || return 1
  [ -f package-lock.json ] || return 0
  sha256sum --check --status "$stamp" 2>/dev/null && return 0
  rm -f "$stamp"
  npm ci --no-audit --no-fund && sha256sum package.json package-lock.json >"$stamp"
}
PIDS=()
for d in "${DEP_DIRS[@]}"; do
  install_deps "$d" >"/tmp/npm-$(echo "$d" | tr '/.' '__').log" 2>&1 &
  PIDS+=("$!:$d")
done
for p in "${PIDS[@]}"; do
  wait "${p%%:*}" || FAILED+=("dependencias de ${p#*:} (ver /tmp/npm-*.log)")
done

# Los hooks de git del proyecto (si los hay) pueden asumir Docker o la máquina local; en la nube
# se desactivan y lo que hacen se corre a mano.
git -C "$ROOT" config --unset core.hooksPath 2>/dev/null

# --- Base de datos: migraciones y datos de prueba -----------------------------------------------
# COMPLETAR: migrar y sembrar, con un chequeo para no resembrar en una sesión reanudada.
# Una herramienta del proyecto se llama con `npx --no-install`: si `npm ci` falló, npx bajaría la
# versión más nueva en vez de la del lockfile.
# cd "$ROOT" && step "Migraciones" npx --no-install prisma migrate deploy
# step "Seed" npm run db:seed

# --- Resumen: Claude Code lo recibe como contexto al arrancar -----------------------------------
echo "Entorno de la nube (log: $LOG):"
# COMPLETAR: una línea por cosa que quedó lista (servicios, DB, usuario de prueba, cómo correr).
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "- FALLÓ: ${FAILED[*]}. Revisar el log antes de confiar en tests o en el sistema."
fi
exit 0
