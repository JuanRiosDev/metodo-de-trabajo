# Tarea <ID>.<n> — <lo que bloquea, en una línea>, y lo demás de la revisión de <ID>

Arreglo de la revisión de la PR #<NN> (<ID>), en una sesión en la nube, sobre una rama que todavía no
está en `main`. `CLAUDE.md` dice cómo correr el proyecto, las convenciones y cómo entrega una sesión
en la nube. Leé `.docs/tareas/<ID>-decisiones.md` antes de empezar: no se afloja nada de lo que cerró
<ID>.

- **Base:** la rama de la #<NN>, `<rama>` (`<sha corto>`), no `origin/main`. Creá tu rama desde
  `origin/<rama>`. No pushees a esa rama ni le mergees `main`.
- **Esta ficha no está en `main`:** está en la rama `docs/ficha-<id>-<n>`. Traela con
  `git fetch origin docs/ficha-<id>-<n>` y
  `git checkout origin/docs/ficha-<id>-<n> -- .docs/tareas/<ID>.<n>-revision-pr<NN>.md`, y metela en
  tu primer commit.
- **Decisiones:** una sección nueva al final de `.docs/tareas/<ID>-decisiones.md`, encabezada con el
  modelo que corre la sesión y el enlace a ella.
- Un commit por punto, con su test. No toques `ROADMAP.md`. <Zona de la otra sesión que corre al
  mismo tiempo, si la hay.>

## Bloquean el merge

### 1. <Título>

<Qué está mal, con archivo y línea, y el escenario concreto que rompe.>
**Arreglo:** <el cambio esperado>. **Test:** <qué lo demuestra>.

## Medios de la misma revisión

- **<Título>** (`<archivo>`): <qué está mal y qué se espera>.

## Chicos

- **<Título>** (`<archivo>`): <qué está mal y qué se espera>.

## Cómo entregar

1. **Verificación:** <comandos exactos>, y <la integración> dos veces.
2. **Contra el sistema levantado:** <el flujo que demuestra cada bloqueante cerrado>.
3. **PR con base `<rama>`** (no `main`), por la API REST. Título:
   `fix(<scope>): <qué> (<ID>.<n>)`.
