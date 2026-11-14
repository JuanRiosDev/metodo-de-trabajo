---
name: no-imprimir-env
description: "Nunca mostrar el contenido de un .env real (cat, diff, head o grep sin enmascarar): para comprobarlo, solo nombres de variables"
metadata:
  type: feedback
---

El contenido de un `.env` real no se muestra nunca: ni `cat`, ni `diff`, ni `head`, ni un `grep` sin
enmascarar. Para comprobar un cambio, imprimir solo los nombres de las variables y el host
(`new URL(...).hostname`), o contar las líneas que difieren (`diff a b | grep -c '^[<>]'`).

**Why:** lo que se imprime queda en el historial de la sesión. Un `diff` filtrado "solo por las URLs"
puede terminar mostrando el archivo entero, y cada secreto que aparece hay que rotarlo.

**How to apply:** antes de cualquier comando que lea un `.env` o un archivo con credenciales, pensar
qué va a imprimir. Para editarlo, usar un script que no imprima el contenido, conservar los finales de
línea (Python con `newline=''`) y borrar después cualquier copia de respaldo con secretos.
