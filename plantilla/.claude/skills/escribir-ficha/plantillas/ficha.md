# Tarea <ID> — <tema en una línea>

Tarea de la Ola <N> del goal <nombre del goal>, en una sesión en la nube. <De dónde sale: qué
auditoría, revisión o pedido la origina>. `CLAUDE.md` dice cómo correr el proyecto, las convenciones
y cómo entrega una sesión en la nube. Los IDs `D-…` son los de la tabla de la deuda de `ROADMAP.md`.
<Si toca la invariante crítica: "Es <tema delicado>: no se recorta por velocidad, y no se afloja nada
de lo que cerraron <tareas anteriores>.">

**Cierra:** <D-NN, D-NN y D-NN>.

- **Rama:** la que te asigne la plataforma, desde `origin/main`.
  **Decisiones:** `.docs/tareas/<ID>-decisiones.md`, encabezado con el modelo que corre la sesión y
  el enlace a ella.
- **Esta ficha no está en `main`:** está en la rama `docs/ficha-<id>`. Traela con
  `git fetch origin docs/ficha-<id>` y
  `git checkout origin/docs/ficha-<id> -- .docs/tareas/<ID>-<tema>.md`, y metela en tu primer commit
  junto con el archivo de decisiones.
- **Tu zona:** <carpetas y archivos que toca esta sesión>.
- **La otra sesión de la ola es <ID>** (<tema>): toca <su zona>. No toques esos archivos; si un punto
  tuyo los necesita, anotalo y hacelo en el archivo de al lado.
- <Migraciones: "Sin migraciones" o "Una sola, de <base>">. Un commit por punto, con su test. No toques
  `ROADMAP.md`.

## 1. <Título del punto> (D-NN)

<El problema, con archivo y función. Qué tiene que pasar después. Si se delega una decisión, el
criterio para tomarla y que se anote en las decisiones.> **Test:** <qué demuestra el arreglo>.

## 2. <Título del punto> (D-NN)

…

## Cómo entregar

1. **Verificación:** <comandos exactos, por carpeta>, y <la integración> dos veces, comprobando que
   termina sola.
2. **Contra el sistema levantado:** <qué procesos levantar y qué flujo probar, con la respuesta
   esperada>.
3. **PR contra `main`** por la API REST, como dice `CLAUDE.md`. Título: `<tipo>(<scope>): <qué> (<ID>)`.
   "Cómo se probó" lista cada chequeo con su resultado, "Sin probar" lo que no corriste, y
   "Decisiones a revisar" lo que elegiste sin que lo dijera esta ficha.

La tarea termina con la PR abierta y el CI en verde.
