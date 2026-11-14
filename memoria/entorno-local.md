---
name: entorno-local
description: "{{PROYECTO}} — cómo levantar y verificar el sistema en esta máquina Windows, revisar PR sin checkout y las trampas ya pagadas"
metadata:
  type: reference
---

**Levantar el sistema:**
- <Servicios (Docker, bases), procesos, puertos. Los puertos que ocupa otro proyecto o un proceso
  ajeno no se tocan.>
- <Datos y usuarios de prueba.>

**Revisar sin checkout:** la combinación con `main` se arma con
`.claude/skills/compuerta/combinacion.sh` en una carpeta del scratchpad. Las dependencias de esa
carpeta: <npm ci propio, o un junction a las del repo si el lockfile es el mismo>. El `.env` se copia
sin imprimirlo ([[no-imprimir-env]]).

**Tests:** <cómo correr cada tipo, cuánto tardan, cuáles no pueden correr dos a la vez, flakes
conocidos en Windows>.

**Trampas ya pagadas:**
- <Lo que costó caro una vez, con fecha, para no repetirlo.>
