---
name: orquestacion
description: Coordinar olas de sesiones de Claude Code en la nube con fichas: lanzarlas, seguirlas, retomarlas y llevar cada PR a la compuerta. Usar cuando el usuario diga "coordinar olas" o "lanzar sesiones en la nube", y al ejecutar un goal.
metadata:
  origin: metodo-de-trabajo
  type: workflow
---

# Orquestación de olas en la nube

Para la sesión que **coordina**: reparte fichas a sesiones en la nube y lleva cada PR por la skill
`compuerta` hasta `main`, en el orden de la ola. Cómo entrega una sesión en la nube está en
`CLAUDE.md`; las fichas se escriben con `escribir-ficha`. Lanzar sesiones pide autorización escrita en
la conversación (o el texto de arranque de un goal).

Los scripts están junto a este archivo (`.claude/skills/orquestacion/`).

## Sesiones

- El modelo de cada sesión sale de "Modelos" en `CLAUDE.md`. Pasá el ID exacto de la versión más
  nueva, no el alias.
- Como mucho **dos en la nube a la vez**, escalonadas: el límite de uso es uno solo para todas,
  incluida la que coordina, y cuando se llena corta todo a mitad de camino.
- **Codex** suma una tarea más en paralelo, si hay: no gasta ese límite. La ficha que el plan le
  asigna va por la skill `delegar-codex`, con su zona como las demás.
- Los arreglos chicos van **juntos en una sesión**, no una sesión por PR.
- Las sesiones se lanzan a mano con `claude --cloud`; las rutinas programadas no, porque se cortan al
  tope de uso extra sin dejar commits.

**Lanzar (Windows):** `lanzar-nube.ps1` arma el prompt (en ASCII), escribe el lanzador y lo abre en
una ventana propia, porque `claude --cloud` exige una terminal interactiva:

```powershell
powershell -ExecutionPolicy Bypass -File .claude\skills\orquestacion\lanzar-nube.ps1 `
  -Repo (Get-Location) -Id P.28 -Tema "que ningun listado traiga todo" `
  -RamaFicha docs/ficha-p28 -ArchivoFicha .docs/tareas/P28-paginacion.md -Modelo claude-opus-5-5
```

Para una ronda de revisión, sumá `-Base <rama de la PR>`.

**Seguir:** `ListAgents` no muestra las sesiones en la nube; el avance se ve en GitHub. Corré
`bash .claude/skills/orquestacion/vigia.sh <hora-del-lanzamiento-en-UTC>` (por ejemplo
`2026-11-10T14:00:00Z`; las ramas anteriores se ignoran) dentro de un `Monitor`: avisa cada commit de
las ramas `claude/…`, cada PR que se abre o se cierra, y una rama quieta más de 45 minutos. Avisa solo
la cabeza de cada push: antes de concluir que falta un commit, mirá el `git log` de la rama.

**Retomar una sesión cortada:** lanzá otra cuyo prompt diga que haga
`git reset --hard origin/<rama vieja>` en su rama asignada y siga desde ahí. La PR nombra las dos
sesiones. Comprobá que la rama vieja quedó contenida con `git merge-base --is-ancestor`.

## Al cerrar cada paso

Anotá en el progreso del goal (memoria del proyecto) qué se lanzó, con qué modelo, qué PR se abrió,
qué bloqueó y qué se mergeó, con fechas y SHAs. Al cerrar la ola, `organizar-proyecto` pone al día
`ROADMAP.md`.

## Trampas de la nube que ya se pagaron

- El hook de la nube **exporta las variables** del proyecto, y eso esconde fallos del flujo local
  (scripts que dejaron de leer el `.env`): probalos sin ellas.
- El hook puede no avisar de **dependencias viejas**: antes de confiar en un build, la sesión compara
  las versiones instaladas con el lockfile.
- Una sesión puede **commitear archivos que no van** (tokens, cobertura): la compuerta mira el
  `git diff --stat`.
- Los lanzadores `.ps1` para PowerShell 5.1 van en ASCII o con BOM: sin BOM los lee como ANSI y rompe
  los acentos.

## Subagentes

Para auditorías y pruebas largas, con el modelo de "Modelos" en `CLAUDE.md`. Un subagente puede no
tener permiso de escritura: que devuelva el informe en su respuesta y lo guarde quien coordina.
