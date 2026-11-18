---
name: adoptar-metodo
description: Adapta el kit MetodoDeTrabajo recién instalado a este repo, llenando las marcas COMPLETAR desde el código. Se corre una vez, a mano.
disable-model-invocation: true
metadata:
  origin: metodo-de-trabajo
  type: setup
---

# Adoptar el método en este repo

`instalar.ps1` copió los archivos del método con marcas `COMPLETAR` donde hace falta saber del
proyecto. Esta skill las llena a partir del código y de lo que el usuario decide.

## Pasos

1. **Inventario:**
   `grep -rn --exclude-dir=adoptar-metodo "COMPLETAR" CLAUDE.md ROADMAP.md *.metodo.md .claude .github`
   (los `*.metodo.md` existen solo si el repo ya tenía esos archivos). Esa lista es el trabajo.
2. **Si el repo ya tenía `CLAUDE.md` o `ROADMAP.md`**, el instalador dejó la versión del método al lado
   (`*.metodo.md`). Fusioná: lo del repo se conserva, las secciones del método que faltan se suman, y
   donde chocan se pregunta al usuario. Después borrá el `*.metodo.md`.
3. **Leé el proyecto:** manifiestos y sus scripts (`package.json`, `pyproject.toml`, …), los workflows
   de CI, Dockerfiles y compose, README, la estructura de carpetas y `git log --oneline -30` (idioma y
   formato real de los commits).
4. **Llená `CLAUDE.md`:** Arquitectura, Cómo correr, Verificación (los comandos exactos del CI),
   Convenciones y "Lo que no se toca". Solo lo que no se deduce mirando las carpetas. Si las
   convenciones reales del repo (commits, ramas, merges) difieren de las del método, preguntá cuál
   manda. Los docs del método dicen `main`: si la rama principal es otra
   (`git symbolic-ref --short refs/remotes/origin/HEAD`), reemplazala en `CLAUDE.md`,
   `.docs/tareas/README.md` y las skills con sus plantillas (`grep -rnw main`). Los scripts la toman
   solos de origin.
5. **Invariante crítica:** proponé una o dos a partir del dominio (aislamiento entre clientes, datos de
   menores, plata, la propiedad de los datos por usuario) y que el usuario elija. Es su decisión.
6. **Compuerta:** reemplazá el ejemplo de `.claude/skills/compuerta/compuerta.pasos` por los
   comandos del CI (o, sin CI, los chequeos que `CLAUDE.md` pide antes de entregar), en su orden, con
   la prueba de integración dos veces. Corré la batería una vez sobre una combinación de `main`
   consigo misma para comprobar los pasos. Si hay CI, mirá dos trampas y proponé el arreglo (el CI es
   infra: lo aprueba el usuario):
   - en los push a la rama principal, el grupo de `concurrency` tiene que ser el commit
     (`github.sha`), no la rama: con un grupo por rama, GitHub cancela las corridas pendientes de
     varios merges seguidos;
   - un paso que no hace fallar la corrida (`continue-on-error`, como un audit que todavía no
     bloquea) tiene que decir en el resumen del job cuando no corrió: un resumen vacío se lee como
     "sin hallazgos".
7. **Nube:** preguntá si el proyecto va a usar sesiones en la nube. Si sí, adaptá
   `.claude/hooks/cloud-session-start.sh` (dependencias, servicios, variables, migraciones, datos de
   prueba). Si no, borrá el hook, su entrada en `.claude/settings.json`, la sección "Sesiones en la
   nube" de `CLAUDE.md` y las skills `orquestacion` y `planear-goal`.
8. **Modelos:** preguntá el plan de Claude (Pro, Max, …) y si tiene Fable (su fila en `/model`), y
   llená la línea "Plan" de "Modelos" en `CLAUDE.md`. Para Codex, corré
   `bash .claude/skills/delegar-codex/codex.sh setup`. Si está listo, comprobá que
   `~/.codex/config.toml` tenga `model_reasoning_effort = "high"` y en `model` el modelo de Codex que
   el usuario elija como el más capaz; si falta, proponé la línea. Si el usuario no usa Codex, borrá
   la skill `delegar-codex` y la línea de Codex de "Modelos".
9. **ROADMAP inicial:** corré la skill `organizar-proyecto`. Sin informes en `audits/`, la tabla de
   deuda queda vacía y el resumen propone correr las dos auditorías.
10. **Memoria del proyecto:** la carpeta de memoria de esta sesión es la que dice tu system prompt, y
    según cómo se abra Claude Code puede no ser la que sembró el instalador
    (`%USERPROFILE%\.claude\projects\<ruta-del-repo-con-guiones>\memory\`). Una sola memoria por
    proyecto: si el proyecto ya tiene memoria en la carpeta de la sesión, completá esa y borrá la
    sembrada; si no, llevá la sembrada a la carpeta de la sesión. Después completá `estado-actual.md`,
    `entorno-local.md` y `decisiones-producto.md` sin repetir lo que ya dicen los docs del repo. Las
    decisiones de negocio que no salen del código se le preguntan al usuario, juntas, en una sola
    pregunta.
11. **Verificá:** corré una vez cada comando de "Verificación" y anotá el resultado; lo que no se pueda
    correr acá queda como "sin probar" en el resumen.

## Terminado cuando

El `grep` del paso 1 no devuelve nada, no queda ningún `*.metodo.md`,
y cada comando de "Verificación" de `CLAUDE.md` tiene su resultado de esta sesión (o su motivo para no
correrlo).

El resumen dice qué se llenó, qué decidió el usuario y qué quedó sin probar, y propone commitear todo
en una rama `chore/metodo-de-trabajo` con su PR: se commitea y se abre la PR solo si el usuario lo
pide. Esta skill se puede borrar del repo después.
