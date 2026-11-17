---
name: goal-<tema>
description: "<Proyecto> — plan del goal <tema>, propuesto el <AAAA-MM-DD>: olas <N> a <M> más un cierre, alcance, modelos, condición de cierre y el progreso al final"
metadata:
  type: project
---

# Goal: <tema>

Lo pidió <usuario> el <AAAA-MM-DD>: "<sus palabras>". **Estado:** propuesto, sin arrancar. El estado
de partida está en [[estado-actual]]; la forma de trabajo, en las skills del repo `orquestacion`
(sesiones en la nube) y `compuerta` (revisión y merge de cada PR).

## Texto de arranque

Se pega en una sesión nueva abierta desde la carpeta del repo. La autorización de merge tiene que
estar escrita en la conversación: el modo automático no la toma de la memoria.

> Arrancá el goal <tema> de <Proyecto> que está en la memoria `goal-<tema>.md`, desde el estado de
> `estado-actual.md`, con la forma de trabajo de las skills `orquestacion` y `compuerta`. Objetivo: <objetivo en una
> oración>; lo que necesite llaves, cuentas o decisiones mías queda anotado. Te autorizo a lanzar las
> sesiones en la nube de cada ola con sus fichas (como mucho dos a la vez), a delegar en Codex las
> fichas que el plan le asigna, y a mergear a main sin
> pedirme OK cada PR que pase la compuerta: revisión verificada sin bloqueantes, la combinación con la
> integración en verde dos veces, el sistema levantado si toca el arranque y el CI en verde. Siempre
> con merge commit, sin push directo a main, sin force push y sin borrar ramas. <Quién se menciona en
> qué PR.> Actualizá la memoria después de cada paso. Terminás cuando se cumpla la condición de
> cierre del plan, con un resumen de lo que entró y de lo que me queda a mí.

## Alcance

**Entra:**
- <IDs o módulos>

**No entra** (es del usuario o va después):
- <ítem>: <motivo>

**Solo si sobra presupuesto:** <lo cosmético>.

## Olas

Hasta dos sesiones en la nube por ola, más una tarea para Codex, con zonas que no se pisan y una
migración por ola como mucho. Los modelos, según "Modelos" en `CLAUDE.md`.

### Ola <N>

- **<ID>, <tipo>, <Opus|Fable|Codex>:** <qué hace>. Cierra <D-NN…>. Zona: <carpetas>.
- **<ID>, …**

### Cierre

- Las dos auditorías (seguridad y código), cada una en un subagente.
- La prueba punta a punta con un subagente.
- Una PR de docs: `ROADMAP.md` al día.
- El resumen para el usuario.

## Condición de cierre

El goal termina cuando se cumple todo esto:
- <chequeo comprobable>
- el CI de `main` está en verde;
- `ROADMAP.md` y la memoria están al día.

**Estimación:** <N> sesiones más sus rondas; <días> con el límite de uso.

**Why:** <para qué se hace ahora>.

**How to apply:** lo usa la sesión que arranca el goal. Si el código contradice este plan, manda el
código: se corrige el plan y se anota en el progreso.

## Progreso

<!-- Una línea por paso, con fecha absoluta: fichas publicadas (rama y SHA), sesiones lanzadas (modelo,
rama asignada), PR abiertas, lo que bloqueó cada revisión, rondas, compuertas (números) y merges
(SHA de main y árbol). También las correcciones al plan. -->
