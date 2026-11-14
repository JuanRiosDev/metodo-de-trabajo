---
name: orquestacion
description: Coordinar olas de sesiones en la nube con fichas, revisar cada PR y pasarla por la compuerta antes del merge. Usar cuando el usuario diga "coordinar olas", "lanzar sesiones en la nube", "pasar la compuerta" o "revisar y mergear las PR de la ola", y al ejecutar un goal.
metadata:
  origin: metodo-de-trabajo
  type: workflow
---

# Orquestación de olas

Para la sesión que **coordina**: reparte fichas a sesiones en la nube, revisa cada PR, la pasa por la
compuerta y las mergea en orden. Cómo entrega una sesión en la nube, qué no se toca y cómo se afirma
el estado están en `CLAUDE.md`. Las fichas se escriben con la skill `escribir-ficha`.

Los scripts están junto a este archivo (`.claude/skills/orquestacion/`) y se corren con Git Bash desde
el repo.

## Autorización

Lanzar sesiones y mergear a `main` piden autorización escrita en la conversación (el modo automático
no la toma de la memoria). El texto de arranque de un goal (skill `planear-goal`) la trae: dentro de
ese texto, una PR que pasa la compuerta se mergea sin pedir OK por cada una. Siempre con merge commit,
sin push directo a `main`, sin force push y sin borrar ramas.

## Modelos

Pasá el ID exacto de la versión más nueva, no el alias.

- **`claude-sonnet-5-5`** para lo mecánico: tests, docs, arreglos chicos, rondas sin riesgo.
- **`claude-opus-5-5`** para lo que toca la invariante crítica, seguridad, auth, concurrencia o una
  migración grande.
- **`claude-fable-5-2`** solo si el usuario lo pide o una tarea delicada falla dos rondas con Opus:
  cuesta el doble y el límite de uso del plan es el cuello de botella.

## Sesiones

- Como mucho **dos en la nube a la vez**, escalonadas: el límite de uso es uno solo para todas,
  incluida la que coordina, y cuando se llena corta todo a mitad de camino.
- Los arreglos chicos van **juntos en una sesión**, no una sesión por PR.
- Las sesiones se lanzan a mano con `claude --cloud`; las rutinas programadas no, porque se cortan al
  tope de uso extra sin dejar commits.

**Lanzar (Windows):** `lanzar-nube.ps1` arma el prompt (en ASCII), escribe el lanzador y lo abre en
una ventana propia, porque `claude --cloud` exige una terminal interactiva:

```powershell
powershell -ExecutionPolicy Bypass -File .claude\skills\orquestacion\lanzar-nube.ps1 `
  -Repo (Get-Location) -Id P.28 -Tema "que ningun listado traiga todo" `
  -RamaFicha docs/ficha-p28 -ArchivoFicha .docs/tareas/P28-paginacion.md -Modelo claude-sonnet-5-5
```

Para una ronda de revisión, sumá `-Base <rama de la PR>`.

**Seguir:** `ListAgents` no muestra las sesiones en la nube; el avance se ve en GitHub. Corré
`bash .claude/skills/orquestacion/vigia.sh <hora-del-lanzamiento-en-UTC>` (por ejemplo
`2026-11-10T14:00:00Z`; las ramas anteriores se ignoran) dentro de un `Monitor`: avisa cada
commit de las ramas `claude/…`, cada PR que se abre o se cierra, y una rama quieta más de 45 minutos.
Avisa solo la cabeza de cada push: antes de concluir que falta un commit, mirá el `git log` de la rama.

**Retomar una sesión cortada:** lanzá otra cuyo prompt diga que haga
`git reset --hard origin/<rama vieja>` en su rama asignada y siga desde ahí. La PR nombra las dos
sesiones. Comprobá que la rama vieja quedó contenida con `git merge-base --is-ancestor`.

## Revisión

- `/code-review medium` en las PR de solo tests o docs; `/code-review high` en las que tocan la
  invariante, auth o visibilidad por rol.
- Cada hallazgo se verifica leyendo el código antes de actuar, y en ejecución si es de comportamiento
  en ejecución: una sospecha que no se reproduce no se arregla.
- Mirá `git diff --stat` de cada PR: una sesión puede commitear tokens, reportes de cobertura o
  builds.
- El resultado de la revisión va como comentario en la PR, mencionando a quien corresponda según
  `CLAUDE.md`.

## Compuerta de una PR

1. La revisión, con cada hallazgo verificado.
2. **Bloquea** un Crítico, un Alto, o un Medio que rompe lo que la PR cierra. El resto va a la tabla
   de deuda de `ROADMAP.md`, con su motivo en el `*-decisiones.md`.
3. El arreglo va en una **PR apilada** (`<ID>.1`) sobre la rama de la PR, con ficha de revisión y
   **tope de dos rondas**. Lo que deja la segunda lo arregla quien coordina en una `<ID>.3`, o va a la
   deuda.
4. La **combinación con `main`**, sin checkout ni worktree (los hooks de git pueden migrar la base
   local al cambiar de rama, también dentro de un worktree):
   `bash .claude/skills/orquestacion/combinacion.sh <rama> <carpeta-en-el-scratchpad>`. Imprime el
   árbol combinado: anotalo.
5. La batería sobre esa carpeta: `bash .claude/skills/orquestacion/compuerta.sh <carpeta> <logs>`, con
   los pasos de `compuerta.pasos` (los del CI, con la integración dos veces). Una sola batería a la
   vez: las de integración comparten la base de prueba.
6. El **sistema levantado** (los procesos de `CLAUDE.md`), si la PR toca el arranque.
7. El CI de la PR dos veces en verde: `bash .claude/skills/orquestacion/ci-doble.sh <pr>` espera la
   corrida, la relanza y espera la segunda. Si `main` se movió, actualizá la rama de la PR y repetí.
8. El merge con `gh pr merge <pr> --merge --match-head-commit <sha probado>`, en el orden de la ola.
9. Al final, comprobá que `git rev-parse origin/main^{tree}` sea el árbol que se probó.

El resultado va como comentario de la PR: las rondas que entraron, cada chequeo con sus números, las
variables de entorno nuevas y lo que no se probó.

## Al cerrar cada paso

Anotá en el progreso del goal (memoria del proyecto) qué se lanzó, con qué modelo, qué PR se abrió,
qué bloqueó y qué se mergeó, con fechas y SHAs. Al cerrar la ola, `organizar-proyecto` pone al día
`ROADMAP.md`.

## Trampas que ya se pagaron

- La primera batería en una carpeta nueva compila sin caché y puede dar un **falso fallo por carga**:
  repetila antes de culpar al código.
- **Dos PR sanas pueden chocar al juntarse** (una firma cambiada, el mismo archivo creado por las dos):
  por eso se prueba la combinación entera, no cada PR sola. Dos PR que tocan el mismo archivo se juntan
  en una sesión aparte que mergea `main` en la rama de una, y la compuerta revisa los archivos
  resueltos.
- El hook de la nube **exporta las variables** del proyecto, y eso esconde fallos del flujo local
  (scripts que dejaron de leer el `.env`): probalos sin ellas.
- El hook de la nube puede no avisar de **dependencias viejas**: antes de confiar en un build, la
  sesión compara las versiones instaladas con el lockfile.
- **Cortar una batería en segundo plano** con `TaskStop` mata solo el paso en curso y el script
  sigue: buscá el proceso del script y sus hijos (`ps -ef | grep compuerta`) y matalos por PID antes de
  relanzar.
- Los lanzadores `.ps1` para PowerShell 5.1 van en ASCII o con BOM: sin BOM los lee como ANSI y rompe
  los acentos.

## Subagentes

Para auditorías y pruebas largas, con el modelo según la regla de arriba. Un subagente puede no tener
permiso de escritura: que devuelva el informe en su respuesta y lo guarde quien coordina.
