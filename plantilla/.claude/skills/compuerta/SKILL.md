---
name: compuerta
description: Revisión y compuerta de una PR antes del merge a main, la haya hecho una sesión local, una en la nube o una persona. Usar cuando el usuario diga "pasa la compuerta", "revisa esta PR" o "¿se puede mergear?", y antes de cada merge de una ola.
metadata:
  origin: metodo-de-trabajo
  type: workflow
---

# Compuerta de una PR

Lo que separa una PR de `main`. Los scripts están junto a este archivo (`.claude/skills/compuerta/`) y
se corren con Git Bash desde el repo.

## Autorización

Mergear a `main` pide autorización escrita en la conversación (el modo automático no la toma de la
memoria). El texto de arranque de un goal la puede traer para toda PR que pase la compuerta. Siempre
con merge commit, sin push directo a `main`, sin force push y sin borrar ramas.

## Pasos

1. **Revisión:** `/code-review medium` si la PR es solo de tests o docs; `/code-review high` si toca la
   invariante crítica de `CLAUDE.md`, auth o permisos. Cada hallazgo se verifica leyendo el código
   antes de actuar, y en ejecución si es de comportamiento en ejecución: una sospecha que no se
   reproduce no se arregla. Mirá también `git diff --stat`: tokens, reportes de cobertura y builds
   no van.
2. **Qué bloquea:** un Crítico, un Alto, o un Medio que rompe lo que la PR cierra. El resto va a la
   tabla de deuda de `ROADMAP.md`, con su motivo en el `*-decisiones.md` de la tarea.
3. **Rondas:** el arreglo de lo que bloquea va en una PR apilada (`<ID>.1`) sobre la rama de la PR,
   con su ficha de revisión (skill `escribir-ficha`), con **tope de dos rondas**. Lo que deja la
   segunda lo arregla quien coordina en una `<ID>.3`, o va a la deuda.
4. **Combinación con `main`**, sin checkout ni worktree (los hooks de git del repo pueden correr al
   cambiar de rama, también dentro de un worktree):
   `bash .claude/skills/compuerta/combinacion.sh <rama> <carpeta-en-el-scratchpad>`. Imprime el
   árbol combinado: anotalo. La primera vez, instalá las dependencias en esa carpeta.
5. **Batería** sobre esa carpeta:
   `bash .claude/skills/compuerta/compuerta.sh <carpeta> <carpeta-de-logs>`, con los pasos de
   `compuerta.pasos` (los del CI, con la integración dos veces). Una sola batería a la vez.
6. **El sistema levantado** (como dice `CLAUDE.md`), si la PR toca el arranque o lo que ve el usuario.
7. **CI**, si el repo lo tiene: dos veces en verde con
   `bash .claude/skills/compuerta/ci-doble.sh <pr>`. Si `main` se movió, actualizá la rama de la PR y
   repetí desde el paso 4.
8. **Merge** con `gh pr merge <pr> --merge --match-head-commit <sha probado>`; en una ola, en su orden.
9. **Comprobación:** `git rev-parse origin/main^{tree}` es el árbol que se probó.

El resultado va como comentario de la PR: las rondas que entraron, cada chequeo con sus números, las
variables de entorno nuevas y lo que no se probó.

## Terminada cuando

Cada paso tiene su resultado en el comentario de la PR (o su motivo para no aplicar), y el árbol de
`main` después del merge es el que se probó. Después, `ROADMAP.md` y la memoria se ponen al día.

## Trampas que ya se pagaron

- La primera batería en una carpeta nueva compila sin caché y puede dar un **falso fallo por carga**:
  repetila antes de culpar al código.
- **Dos PR sanas pueden chocar al juntarse** (una firma cambiada, el mismo archivo creado por las
  dos): por eso se prueba la combinación entera. Dos PR que tocan el mismo archivo se juntan aparte,
  mergeando `main` en la rama de una, y se revisan los archivos resueltos.
- **Cortar una batería en segundo plano** con `TaskStop` mata solo el paso en curso y el script sigue:
  buscá el proceso del script y sus hijos (`ps -ef | grep compuerta`) y matalos por PID antes de
  relanzar.
- El `.env` de la carpeta de combinación se copia sin imprimirlo.
