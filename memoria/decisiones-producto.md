---
name: decisiones-producto
description: "{{PROYECTO}} — decisiones de producto y de negocio del usuario que no se vuelven a preguntar, y las que esperan su respuesta"
metadata:
  type: project
---

Tomadas por el usuario (con fecha y dónde quedó escrito). No volver a preguntar:

- **Producto:** <qué entra en la v1 y qué va a la v2>.
- **Infraestructura:** <hosting, dominio, servicios externos>.
- **Arquitectura:** <lo descartado a propósito, por ejemplo microservicios>.
- **La invariante crítica** (`CLAUDE.md`) no se recorta nunca por velocidad.

**Pendientes del usuario:** no están descartadas, esperan su decisión o sus llaves.
- <ítem>

**Why:** son decisiones de negocio, no se deducen del código.

**How to apply:** si una tarea roza alguno de estos puntos, seguir la decisión sin preguntar. Si el
código o `ROADMAP.md` la contradicen, preguntar antes de cambiar el rumbo.
