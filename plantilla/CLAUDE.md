# {{PROYECTO}} — CLAUDE.md

<!-- Instalado con el kit MetodoDeTrabajo ({{FECHA}}). Las marcas pendientes las llena la skill
adoptar-metodo a partir del código, y cada una se borra al llenarla. -->

## Arquitectura

<!-- COMPLETAR: stack, procesos que corren, superficies (apps, paneles, sitios), integraciones e
infraestructura de producción, cada uno con su carpeta. Solo lo que no se deduce mirando las
carpetas. -->

**Estado y prioridades:** `ROADMAP.md` es la fuente de verdad: estado por módulo, olas con sus
fichas (`.docs/tareas/`) y la tabla de la deuda.

## Invariante crítica

<!-- COMPLETAR: la propiedad del sistema que nunca se recorta por velocidad, con dónde vive en el
código (por ejemplo: el aislamiento entre clientes de un SaaS). La decide el usuario. La skill
auditoria-seguridad empieza siempre por ella. -->

## Cómo correr el proyecto

<!-- COMPLETAR: versión del runtime (la del CI), cómo levantar cada proceso, datos y usuarios de
prueba, puertos, y qué deja listo el hook de la nube. -->

## Verificación

<!-- COMPLETAR: qué corre el CI, con los comandos exactos por carpeta; dónde viven los tests
(unitarios, integración, e2e); qué no cubre el CI. -->

CI en verde no prueba que el sistema arranque. Cuando un cambio toca el arranque
(<!-- COMPLETAR: módulos que cargan al iniciar, variables de entorno, colas, CORS, migraciones -->),
levantá el sistema y probá el flujo afectado antes de darlo por terminado.

## Forma de trabajo

- **El estado se afirma con evidencia.** Antes de reportar avance o marcar ✅ en `ROADMAP.md` o en
  una PR, contrastá cada afirmación con un resultado de esta sesión (build, test, request contra el
  sistema levantado) y decí explícitamente lo que no verificaste.
- **El pedido define el alcance.** Un bug o una deuda que encuentres fuera de lo pedido va como
  follow-up en el resumen, no al mismo diff. Si el usuario describe un problema o hace una pregunta,
  el entregable es tu diagnóstico: reportá y esperá a que pida el fix.
- **Tests** donde el repo ya los tiene para ese tipo de cambio, uno enfocado por comportamiento
  pedido. Los chequeos descartables van al scratchpad, no al repo.
- **Edits quirúrgicos**: editá la parte que cambia en vez de reescribir el archivo entero.
- **Subagentes** cuando el usuario o la skill invocada los piden (auditorías, pruebas largas); lo
  demás, directo.
- **Resumen final** en español, empezando por el resultado: qué pasó o qué encontraste. Quien lo lee
  no vio la sesión: oraciones completas, sin flechas encadenadas ni abreviaturas inventadas, y cada
  archivo o commit que nombres con su frase de qué es o qué cambió.
- **Al cerrar una tarea**, poné al día lo que cambió: `ROADMAP.md` (con la evidencia) y la memoria del
  proyecto (`estado-actual.md`, y el progreso del goal si hay uno en curso), con fechas absolutas.
  El resumen dice qué memoria se tocó.

## Convenciones

<!-- COMPLETAR: las del código (idioma de identificadores, comentarios y textos de UI; formato;
patrones del dominio que un cambio nuevo tiene que seguir). -->

- **Commits** en Conventional Commits y en español, con el verbo en infinitivo y scope cuando aplica:
  `feat(api): avisar en vivo el estado del envío`. El cuerpo dice por qué. Ramas `feat/…`, `fix/…`,
  `chore/…` y `docs/…` desde `main`.
- **PR** a `main`, mergeada con merge commit, con la plantilla de `.github/pull_request_template.md`:
  "Qué cambia", "Cómo se probó" (cada chequeo con su resultado), "Sin probar" y "Decisiones a revisar".
  <!-- COMPLETAR: a quién se menciona según la carpeta que toca la PR. -->

## Lo que no se toca

Son barandas duras; cada una tiene su camino correcto al lado.

- **`main`**: se llega solo por PR. Ninguna sesión pushea a `main` ni hace force push a ramas ajenas.
  Se mergea cuando el usuario lo autoriza por escrito en la conversación.
- **Secretos y `.env`**: fuera del repo; los ejemplos van en los `.env.example`. Para comprobar un
  `.env` real se imprimen solo los nombres de las variables, nunca sus valores.
- **Archivos de terceros**: las skills fijadas en `skills-lock.json` se actualizan con `npx skills`,
  no a mano.
- **Infra de producción** (<!-- COMPLETAR: archivos de deploy, Dockerfiles, CI -->): solo cuando la
  tarea lo pide, y diciéndolo en la PR.
<!-- COMPLETAR: las barandas propias del proyecto (por ejemplo, migraciones aplicadas inmutables), cada
una con su camino correcto. -->

## Sesiones en la nube

Una sesión en la nube trabaja sin nadie mirando: el entregable es una PR que se revisa sin abrir la
sesión. Cuando te lanzan con una ficha de `.docs/tareas/`, la ficha es el pedido completo.

- Antes de empezar, leé el resumen del hook de arranque. Si dice `FALLÓ`, arreglá el entorno
  (`CLAUDE_CODE_REMOTE=true bash .claude/hooks/cloud-session-start.sh` lo rehace) y contalo en la PR.
  Compará también las versiones instaladas con el lockfile: el hook no siempre detecta dependencias
  viejas.
- Trabajá en la rama que nombra la ficha, desde la base que dice la ficha, con commits chicos, y
  pusheá después de cada uno: si la VM se recicla, lo no pusheado se pierde.
- El primer commit trae la ficha y su archivo de decisiones, encabezado por el modelo que corre la
  sesión y el enlace a ella: `https://claude.ai/code/${CLAUDE_CODE_REMOTE_SESSION_ID/#cse_/session_}`.
  Ese enlace va también en la descripción de la PR.
- Revisá la lista de archivos del diff antes de abrir la PR: tokens, reportes de cobertura y builds
  quedan fuera.
- La PR la revisa y la mergea quien coordina: tu trabajo termina con la PR abierta y el CI en verde.
  Si el CI falla, arreglalo y volvé a pushear.
- `gh pr` y `gh issue` usan GraphQL, que el proxy de GitHub de la nube bloquea. Abrí la PR con la API
  REST: `gh api repos/{{REPO}}/pulls -f title=… -f head=<rama> -f base=<base> -F body=@<archivo>`.
- Cuando no puedas seguir sin una decisión que no sale del código ni de `ROADMAP.md`, elegí la opción
  reversible, anotala en la PR bajo "Decisiones a revisar" y seguí.

## Auditorías

Los informes de `auditoria-seguridad` y `auditoria-codigo` van a `audits/`, que está en `.gitignore`
porque citan vulnerabilidades con rutas concretas. `ROADMAP.md` sí se commitea.
