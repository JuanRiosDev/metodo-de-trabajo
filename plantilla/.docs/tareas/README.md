# Fichas de tarea

Una ficha por tarea, autosuficiente: es el pedido completo para una sesión que trabaja sin nadie
mirando. El formato y los nombres están en la skill `escribir-ficha`
(`.claude/skills/escribir-ficha/`).

- `<ID>-<tema>.md`: la ficha de la tarea.
- `<ID>-decisiones.md`: lo que eligió la sesión y por qué, lo verificado y lo que quedó sin probar.
  Las rondas de revisión le suman una sección al final.
- `<ID>.<n>-revision-pr<NN>.md`: la ficha de una ronda de arreglos de la revisión (como mucho dos).

La ficha llega a `main` con el primer commit de la sesión que la ejecuta.
