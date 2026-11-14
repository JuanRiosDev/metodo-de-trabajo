---
name: estado-actual
description: "{{PROYECTO}} al {{FECHA}} — dónde está main, qué PR y ramas hay abiertas, qué es del usuario y cómo está la máquina local"
metadata:
  type: project
---

**Repo:** `{{REPO}}`, en `{{RUTA}}`. Instalado con el kit MetodoDeTrabajo el {{FECHA}}; la skill
`adoptar-metodo` completa esta memoria.

## Dónde está

- **`main` = `<sha>`**, con <N> PR abiertas. `ROADMAP.md` es la fuente de verdad del estado y de la
  deuda.
- <El goal en curso, si hay, con su memoria: [[goal-<tema>]].>

## Quién es quién

- <Persona: qué carpetas son suyas, con qué usuario de GitHub commitea, a quién se menciona en qué PR.>

## Lo que es del usuario (ninguna sesión lo hace)

- <Llaves, cuentas, despliegues, DNS, secretos, decisiones pendientes.>

## La máquina local

- <Rama en la que está el repo, cambios sin commitear que no se tocan, servicios arriba, datos de
  prueba que quedaron.>

**Why:** que una sesión nueva sepa dónde está el proyecto sin reconstruirlo.

**How to apply:** antes de actuar, `git fetch --prune` y `gh pr list`, porque otra persona o una
sesión en la nube pueden haber movido algo. El entorno está en [[entorno-local]].
