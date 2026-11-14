# MetodoDeTrabajo

Una forma de trabajar con Claude Code, empaquetada para usarla en cualquier repo: el `CLAUDE.md` con
sus reglas, el `ROADMAP.md` como fuente de verdad, las fichas de tarea, las olas de sesiones en la
nube con una compuerta antes de cada merge, las auditorías, la memoria del proyecto y los scripts que
lo sostienen.

Salió de un proyecto real llevado a producción y de su goal de deuda técnica. Lo propio de ese
proyecto quedó afuera: en su lugar hay marcas `COMPLETAR` que se llenan con el código de cada repo.

## El método en una página

1. **El estado se afirma con evidencia.** Nada se marca ✅ sin un resultado de la misma sesión
   (build, test, request contra el sistema levantado); lo no verificado se dice.
2. **`ROADMAP.md` es la fuente de verdad**, sacada del código y no de los planes: estado por módulo,
   olas con sus fichas y una tabla única de deuda con IDs estables (`D-NN`).
3. **Una invariante crítica** por proyecto (por ejemplo, el aislamiento entre clientes de un SaaS)
   que nunca se recorta por velocidad y que la auditoría de seguridad revisa primero.
4. **Fichas autosuficientes** en `.docs/tareas/`: el pedido completo para una sesión que trabaja sin
   nadie mirando, con su zona, un commit y un test por punto, y un archivo de decisiones.
5. **Olas** de hasta dos sesiones en la nube, con zonas que no se pisan, el modelo según el riesgo
   (Sonnet lo mecánico, Opus lo delicado) y los arreglos chicos juntos.
6. **Compuerta** antes de cada merge: revisión verificada, rondas apiladas con tope de dos, la
   combinación con `main` probada sin checkout, la integración y el CI dos veces, el sistema levantado
   si toca el arranque, y `main` igual al árbol probado.
7. **Goals** con alcance, olas y una condición de cierre comprobable, arrancados con un texto que trae
   la autorización de merge por escrito.
8. **Memoria al día** al cerrar cada tarea: estado, decisiones de producto, entorno y el progreso del
   goal, con fechas absolutas.

## Instalar en un repo

```powershell
powershell -ExecutionPolicy Bypass -File "<carpeta-del-kit>\instalar.ps1" `
  -Destino "C:\ruta\al\repo" [-Proyecto Nombre] [-SinMemoria] [-Simular]
```

El instalador no pisa nada: si el repo ya tiene `CLAUDE.md` o `ROADMAP.md`, deja la versión del
método al lado (`*.metodo.md`); cualquier otro archivo que ya exista se omite. También agrega
`/audits/` al `.gitignore` y siembra la memoria del proyecto en
`%USERPROFILE%\.claude\projects\<carpeta-del-repo>\memory\`.

Después, abrí Claude Code en el repo y escribí **`/adoptar-metodo`**: lee el código, llena cada
`COMPLETAR`, te pregunta la invariante crítica y las decisiones de negocio, arma el ROADMAP inicial y
deja la compuerta con los comandos del CI.

## Qué trae

```
instalar.ps1                    instalador (PowerShell 5.1)
plantilla/                      lo que se copia al repo
  CLAUDE.md                     forma de trabajo, convenciones, barandas, sesiones en la nube
  ROADMAP.md                    estado por módulo, olas, tabla de deuda, sin verificar
  .github/pull_request_template.md
  .docs/tareas/README.md
  .claude/settings.json         hook de arranque en la nube y permisos de solo lectura
  .claude/hooks/cloud-session-start.sh
  .claude/skills/               las skills del método (abajo)
memoria/                        plantillas de la memoria del proyecto
```

## Las skills y cuándo usarlas

| Skill | Cuándo | Qué deja |
|---|---|---|
| `adoptar-metodo` | Una vez, a mano (`/adoptar-metodo`), después de instalar | `CLAUDE.md`, ROADMAP, compuerta y memoria adaptados al repo |
| `organizar-proyecto` | "organiza el proyecto", "actualiza el roadmap", "dónde vamos" | `ROADMAP.md` al día desde el código |
| `auditoria-seguridad` | "audita seguridad"; en el cierre de un goal | `audits/security-audit-<fecha>.md` |
| `auditoria-codigo` | "audita el código"; en el cierre de un goal | `audits/code-audit-<fecha>.md` |
| `planear-goal` | "mándame el goal para…", "planea las próximas olas" | El plan del goal en la memoria, con el texto de arranque |
| `escribir-ficha` | "escribe la ficha", "prepara la tarea para la nube" | Ficha en `.docs/tareas/` publicada en `docs/ficha-…` |
| `orquestacion` | "coordinar olas", "pasar la compuerta"; al ejecutar un goal | Sesiones lanzadas, PR revisadas, compuertas y merges |

Scripts (Git Bash, desde el repo):

- `escribir-ficha/ficha-rama.sh`: publica una ficha en su rama sin checkout.
- `orquestacion/lanzar-nube.ps1`: arma el lanzador de una sesión en la nube y lo abre en su ventana.
- `orquestacion/vigia.sh`: sigue las ramas y PR de las sesiones desde un `Monitor`.
- `orquestacion/combinacion.sh`: arma la combinación de una PR con `main` en una carpeta, sin checkout.
- `orquestacion/compuerta.sh` + `compuerta.pasos`: la batería sobre la combinación, con un log por paso.
- `orquestacion/ci-doble.sh`: el CI de una PR dos veces.

## Flujos típicos

- **Una tarea suelta en local:** pedila normal; `CLAUDE.md` ya pone las reglas (evidencia, alcance,
  resumen, memoria). Para un cambio grande, `escribir-ficha` primero.
- **Una tarea en la nube:** `escribir-ficha`, después `orquestacion` para lanzarla, revisarla y pasarla
  por la compuerta.
- **Un goal:** `planear-goal` en una sesión; pegás su texto de arranque en una sesión nueva desde el
  repo, y esa sesión coordina con `orquestacion` hasta la condición de cierre.

## Skills de terceros que combinan bien

No vienen en el kit: se instalan por repo con `npx skills` (el CLI que fija versiones en
`skills-lock.json`), según el stack. Fuentes:

| Skill | Fuente (repo · ruta) | Sirve para |
|---|---|---|
| `webapp-testing` | `anthropics/skills` · `skills/webapp-testing` | Probar la app levantada en el navegador con Playwright |
| `use-railway` | `railwayapp/railway-skills` · `plugins/railway/skills/use-railway` | Deploy, logs y variables en Railway |
| `git-workflow-and-versioning` | `addyosmani/agent-skills` · `skills/git-workflow-and-versioning` | Commits atómicos, partir un árbol desordenado |
| `git-workflow` | `affaan-m/ecc` · `skills/git-workflow` | Ramas, Conventional Commits, conflictos |
| `roadmap-update`, `sprint-planning`, `status-report`, `tech-debt` | `anthropics/knowledge-work-plugins` | Priorizar el roadmap, planear la semana, informe de avance, priorizar deuda |

Para un stack TypeScript, ECC (`affaan-m/ecc`) trae agentes (`typescript-reviewer`,
`database-reviewer`, `security-reviewer`, `architect`, `build-error-resolver`, `planner`), reglas y
skills de stack (`database-migrations`, `postgres-patterns`, `docker-patterns`, `deployment-patterns`,
`api-design`, `security-review`, `frontend-patterns`). Son genéricos: si un repo los usa, su
`CLAUDE.md` dice dónde manda sobre ellos (por ejemplo, que `git checkout` para revisar una PR puede
disparar hooks del repo).

## Mantener el kit

Cuando un proyecto paga una trampa nueva o mejora un paso, traelo acá: a la skill que corresponda en
`plantilla/` y, si cambia el método, a "El método en una página". Los repos ya instalados no se
actualizan solos: se copia el archivo cambiado. Ver `CLAUDE.md` de esta carpeta.
