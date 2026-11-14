---
name: organizar-proyecto
description: Estado real del proyecto en ROADMAP.md, sacado del código y no de los planes. Usar cuando el usuario diga "organiza el proyecto", "actualiza el roadmap" o "dónde vamos", y al cerrar una ola o un goal.
metadata:
  origin: metodo-de-trabajo
  type: planning
---

# Organizar el proyecto

Genera o actualiza `ROADMAP.md` en la raíz a partir del **estado real del código**. Los planes de
`.docs/` y la memoria dicen qué se planeó; el estado sale solo de lo que existe y corre. Las
definiciones de ✅/🚧/⬜, de severidad y de tipo están en "Cómo leer este documento" del propio
`ROADMAP.md`.

## 1. Escanear

Cada afirmación del roadmap se apoya en un archivo que abriste en esta sesión:

- **Módulos del backend:** para cada uno, si tiene lógica real (rutas, servicios, validación) o es un
  esqueleto. Una carpeta con placeholders cuenta como ⬜.
- **Datos:** schemas y migraciones que existen de verdad, y si hay desfase entre los dos.
- **Frontend:** rutas y pantallas que montan componentes reales; si leen la API o datos simulados
  (mocks, `localStorage`).
- **CI y despliegue:** workflows, Dockerfiles, configuración del hosting.
- **Integraciones:** código real que llama al servicio externo. Que aparezca en un doc o en
  `.env.example` no alcanza.
- **Trabajo en curso:** `git fetch --prune`, `gh pr list` y las ramas abiertas de otras personas o
  sesiones.
- **Deuda:** los informes de `audits/`, los `*-decisiones.md` de `.docs/tareas/` y los comentarios
  de revisión de las PR mergeadas desde la última actualización.

## 2. Actualizar ROADMAP.md

- Encabezado con la fecha y el commit de `main` (`git rev-parse --short origin/main`), y las cifras
  del último CI de `main` (tests por tipo, cobertura).
- **Estado por módulo**, una fila por módulo de dominio.
- **Próximos pasos**, ordenados por dependencias (reglas abajo).
- **Tabla de la deuda abierta:** cada hallazgo nuevo entra al final con el siguiente `D-NN`; un ítem
  cerrado se marca ✅ con la tarea y la PR, solo después de comprobarlo en `main`. Al final, el conteo
  por severidad, tipo y dueño.
- **Sin verificar:** todo lo que no pudiste comprobar, con la fecha.
- Las secciones que escribió una persona y que esta skill no genera se conservan tal cual.

## Reglas de priorización

1. La **invariante crítica** de `CLAUDE.md` primero: si no está sólida, es el bloqueador número uno.
2. Hallazgos Críticos y Altos de seguridad antes que funcionalidad nueva.
3. Después, la cadena de dependencias del negocio: un módulo aguas abajo no es prioritario mientras
   su dependencia aguas arriba esté ⬜.

## Terminado cuando

Cada fila de "Estado por módulo" cita lo que la sostiene, todo lo no comprobable está en "Sin
verificar", y el conteo de la deuda coincide con las filas de la tabla. Entonces, en el chat: qué
cambió de estado desde la versión anterior y cuál es el siguiente paso recomendado.

`ROADMAP.md` se commitea; los informes de `audits/` quedan fuera de git.
