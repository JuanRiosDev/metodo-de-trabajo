---
name: escribir-ficha
description: Ficha de tarea en .docs/tareas/ para una sesión que trabaja sin nadie mirando (en la nube, local o Codex), y la ficha de una ronda de revisión de su PR. Usar cuando el usuario diga "escribe la ficha" o "prepara la tarea para la nube", al armar una ola, y al mandar a arreglar lo que bloqueó una PR.
metadata:
  origin: metodo-de-trabajo
  type: workflow
---

# Escribir una ficha

La ficha es el pedido completo: quien la ejecuta no vio la conversación, no puede preguntar y no
conoce las otras sesiones. Lo que no está en la ficha no existe para esa sesión.

## Nombres

- **ID** con una letra por área y un número correlativo (por ejemplo `P` backend, `F` frontend, `D`
  docs): `P.31`. Las rondas de revisión suman un punto: `P.31.1`, `P.31.2`.
- Archivos en `.docs/tareas/`: `P31-<tema>.md` (la tarea), `P31-decisiones.md` (lo escribe la
  sesión) y `P31.1-revision-pr<NN>.md` (cada ronda).

## Pasos

1. **Contrastá cada afirmación con el código** de la base (`origin/main`, o la rama de la PR en una
   revisión): cada archivo, función y comportamiento que nombres existe y es como decís. Un bug se
   reproduce o se lee en el código, no se toma de un informe viejo.
2. **Escribí con la plantilla** que corresponde: `plantillas/ficha.md` o `plantillas/revision.md`
   (junto a este archivo). La sesión arma su `*-decisiones.md` con `plantillas/decisiones.md`.
3. **Zonas:** las carpetas o archivos de esta sesión, y los de las otras sesiones de la ola con lo
   que no se toca. Si dos fichas necesitan el mismo archivo, repartí quién toca qué parte, o ponelas
   en olas distintas.
4. **Cada punto:** el problema con su archivo, el arreglo esperado (o la decisión que se le delega,
   con el criterio para tomarla), el ID de la deuda que cierra y su test. Un commit por punto.
5. **Cómo entregar:** los comandos exactos de verificación (la integración dos veces), los chequeos
   contra el sistema levantado si la tarea toca el arranque, y el título de la PR.
6. **Publicá la ficha** en una rama `docs/ficha-<id>` sin checkout ni worktree, para no disparar los
   hooks de git del repo:
   `bash .claude/skills/escribir-ficha/ficha-rama.sh <archivo> .docs/tareas/<nombre> docs/ficha-<id> "docs: ficha de <ID>" [base]`.
   La sesión la trae con `git checkout origin/docs/ficha-<id> -- <ruta>` y la mete en su primer commit.
   Una ficha para Codex no se publica: la commitea `delegar-codex` en su clon, y su prompt reemplaza
   lo de la rama y la PR (en la ficha, "Cómo entregar" termina en la verificación).

## La ficha de revisión

- **Base:** la rama de la PR revisada, no `main`. La sesión no pushea a esa rama ni le mergea `main`.
- **Secciones:** "Bloquean el merge" (Crítico, Alto, o un Medio que rompe lo que la PR cierra),
  "Medios de la misma revisión" y "Chicos". Cada hallazgo, verificado leyendo el código antes de
  escribirlo; si es de comportamiento en ejecución, probado en ejecución.
- **Decisiones:** una sección nueva al final del `*-decisiones.md` de la tarea.
- Tope de **dos rondas** (`.1` y `.2`). Lo que deja la segunda lo arregla quien coordina en una `.3`,
  o va a la deuda.

## Terminada cuando

Una sesión sin la conversación puede ejecutarla de punta a punta: cada archivo citado existe en la
base, cada punto tiene su test y su ID, las zonas no se pisan con otra ficha de la ola, y "Cómo
entregar" dice qué correr y qué cuenta como terminado.
