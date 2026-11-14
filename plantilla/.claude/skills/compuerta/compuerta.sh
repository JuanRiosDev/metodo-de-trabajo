#!/bin/bash
# Corre la bateria de la compuerta sobre una carpeta (la combinacion) y deja un log por paso y un
# resumen con el codigo de salida y la duracion de cada uno. No corta en el primer fallo.
#
# Uso: compuerta.sh <carpeta> <carpeta-de-logs> [archivo-de-pasos]
# Pasos: por defecto compuerta.pasos junto a este script; una linea por paso,
#   nombre|subcarpeta|comando
#
# Una sola bateria a la vez. Para cortarla, matar por PID el bash de este script y sus hijos
# (ps -ef | grep compuerta): cortar solo el paso en curso deja seguir al resto.
if [ $# -lt 2 ]; then
  sed -n '2,10p' "$0"
  exit 2
fi
DIR=$1
LOGS=$2
PASOS=${3:-"$(dirname "$0")/compuerta.pasos"}
mkdir -p "$LOGS"
: >"$LOGS/resumen.txt"
echo "pid $$" >>"$LOGS/resumen.txt"

FALLOS=0
while IFS='|' read -r nombre sub cmd; do
  [[ -z "${nombre// /}" || "$nombre" == \#* ]] && continue
  t0=$(date +%s)
  (cd "$DIR/$sub" && bash -c "$cmd") >"$LOGS/$nombre.log" 2>&1 </dev/null
  rc=$?
  [ $rc -ne 0 ] && FALLOS=$((FALLOS + 1))
  echo "$nombre rc=$rc $(($(date +%s) - t0))s" | tee -a "$LOGS/resumen.txt"
done <"$PASOS"
echo "FIN fallos=$FALLOS" | tee -a "$LOGS/resumen.txt"
[ $FALLOS -eq 0 ]
