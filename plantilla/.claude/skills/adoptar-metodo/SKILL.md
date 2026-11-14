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
   manda.
5. **Invariante crítica:** proponé una o dos a partir del dominio (aislamiento entre clientes, datos de
   menores, plata, la propiedad de los datos por usuario) y que el usuario elija. Es su decisión.
6. **Compuerta:** reemplazá el ejemplo de `.claude/skills/orquestacion/compuerta.pasos` por los
   comandos del CI, en su orden, con la prueba de integración dos veces.
7. **Hook de la nube:** adaptá `.claude/hooks/cloud-session-start.sh` (dependencias, servicios,
   variables, migraciones, datos de prueba). Si el usuario no va a usar sesiones en la nube, borrá el
   hook, su entrada en `.claude/settings.json` y la sección "Sesiones en la nube" de `CLAUDE.md`.
8. **ROADMAP inicial:** corré la skill `organizar-proyecto`. Sin informes en `audits/`, la tabla de
   deuda queda vacía y el resumen propone correr las dos auditorías.
9. **Memoria del proyecto:** completá `estado-actual.md`, `entorno-local.md` y
   `decisiones-producto.md` (el instalador las sembró). Las decisiones de negocio que no salen del
   código se le preguntan al usuario, juntas, en una sola pregunta.
10. **Verificá:** corré una vez cada comando de "Verificación" y anotá el resultado; lo que no se pueda
    correr acá queda como "sin probar" en el resumen.

## Terminado cuando

El `grep` del paso 1 no devuelve nada, no queda ningún `*.metodo.md`,
y cada comando de "Verificación" de `CLAUDE.md` tiene su resultado de esta sesión (o su motivo para no
correrlo).

El resumen dice qué se llenó, qué decidió el usuario y qué quedó sin probar, y propone commitear todo
en una rama `chore/metodo-de-trabajo` con su PR: se commitea y se abre la PR solo si el usuario lo
pide. Esta skill se puede borrar del repo después.
