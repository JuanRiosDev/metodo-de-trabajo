# MetodoDeTrabajo — CLAUDE.md

Este repo es el kit, no un proyecto que lo usa. `README.md` dice qué trae y cómo se instala.

- `plantilla/` se copia tal cual a otros repos con `instalar.ps1`. `{{PROYECTO}}`, `{{REPO}}`,
  `{{RUTA}}` y `{{FECHA}}` los reemplaza el instalador; las marcas `COMPLETAR` las llena la skill
  `adoptar-metodo` en cada repo. Todo lo que dependa del stack de un proyecto va como `COMPLETAR`, con
  un ejemplo genérico en un comentario si ayuda. Nada de un proyecto real ni de quien usa el kit
  (nombres, correos, repos, rutas, SHAs, incidentes): este repo es público. Vale también para lo que
  GitHub publica fuera del diff: nombres de rama, mensajes de commit, PR y comentarios. Se escanea
  todo eso antes de cada push; lo aprendido en un proyecto entra como "un proyecto con el kit".
- `memoria/` son plantillas de la memoria de un proyecto (formato de memoria de Claude Code:
  frontmatter con `name`, `description` y `metadata.type`). `MEMORY.md` es el índice: una línea por
  archivo, y el instalador suma solo las de los archivos que crea.
- Los `.ps1` van en ASCII (PowerShell 5.1 lee sin BOM como ANSI). Los `.sh` van con finales LF.
- Las skills siguen la skill `writing-for-agents`: descripciones cortas con sus disparadores, pasos
  con un "Terminado cuando" comprobable, cada regla en un solo lugar (`CLAUDE.md` de la plantilla para
  lo que vale siempre, la skill para lo que vale en su flujo).
- **Probar un cambio:** instalar en un repo de prueba en el scratchpad, con `-RaizMemoria` apuntando
  ahí también, dos veces (la segunda no tiene que crear ni duplicar nada), y una vez sobre un repo con
  `CLAUDE.md` propio. Los scripts de `compuerta/` y `escribir-ficha/` se prueban contra un remoto
  bare local.
- Al cambiar el método, actualizá "El método en una página" del `README.md`.
