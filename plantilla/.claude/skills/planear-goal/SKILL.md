---
name: planear-goal
description: Plan de un goal (varias olas de sesiones en la nube hasta una condición de cierre comprobable), guardado en la memoria del proyecto con el texto de arranque que trae la autorización de merge. Usar cuando el usuario diga "mándame el goal", "arma el goal para…" o "planea las próximas olas".
metadata:
  origin: metodo-de-trabajo
  type: planning
---

# Planear un goal

Un goal es un objetivo grande (llevar a producción, cerrar la deuda) que se ejecuta en olas, cada una
con hasta dos sesiones en la nube, hasta que se cumple una **condición de cierre** que se puede
comprobar. Esta skill lo planea y lo deja escrito; no lo arranca. Lo ejecuta una sesión nueva con la
skills `orquestacion` y `compuerta`, a partir del texto de arranque que el usuario pega.

## Pasos

1. **Partí del estado real:** `ROADMAP.md` (tabla de deuda, próximos pasos), la memoria
   `estado-actual.md`, `git fetch --prune`, `gh pr list` y las ramas abiertas de otras personas. Si
   el roadmap está viejo, corré antes `organizar-proyecto`.
2. **Alcance**, en tres listas:
   - **Entra:** lo que el goal cierra, citando los IDs `D-NN` o los módulos.
   - **No entra:** lo que depende del usuario (llaves, cuentas, pagos, decisiones de producto) y lo
     que se deja para después, cada cosa con su motivo.
   - **Solo si sobra presupuesto:** lo cosmético.
3. **Olas:** hasta dos sesiones en la nube por ola, más una tarea para Codex si hay, con zonas que no
   se pisan y una migración por ola como mucho. Cada tarea con su ID, quién la ejecuta y con qué
   modelo ("Modelos" en `CLAUDE.md`), los IDs que cierra y de qué depende.
   Agrupá los arreglos chicos en la sesión cuya zona ya los toca. Si otra persona tiene ramas abiertas
   en una zona, la ola que la toca empieza después de hablarlo con el usuario.
4. **Cierre:** las auditorías otra vez (`auditoria-seguridad` y `auditoria-codigo`, cada una en un
   subagente con el modelo de "Modelos"), una prueba punta a punta de los flujos principales contra el
   sistema levantado, una PR de docs con `ROADMAP.md` al día y el resumen para el usuario.
5. **Condición de cierre**, como lista de chequeos que se comprueban (por ejemplo: sin Altos ni
   Medios abiertos que no dependan del usuario; auditorías sin Críticos ni Altos; la prueba punta a
   punta pasa; el CI de `main` en verde; `ROADMAP.md` y la memoria al día).
6. **Estimación:** cuántas sesiones más sus rondas, y cuántos días con el límite de uso.
7. **Texto de arranque**, con la autorización que necesita el goal (plantilla en
   `plantilla-goal.md`, junto a este archivo).
8. **Guardá el plan** en la memoria del proyecto como `goal-<tema>.md` con
   `plantilla-goal.md`, y sumá su línea en `MEMORY.md`.

## Terminado cuando

Cada ítem de "Entra" tiene una tarea en una ola, cada ítem de "No entra" tiene su motivo, la
condición de cierre es una lista de chequeos comprobables, y el usuario tiene el texto de arranque
para pegar en una sesión nueva abierta desde el repo.

Si al ejecutar el goal el código contradice el plan, manda el código: se corrige el plan, se anota en
su progreso y se sigue.
