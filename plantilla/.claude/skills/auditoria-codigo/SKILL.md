---
name: auditoria-codigo
description: Auditoría de calidad del código (consistencia de datos, duplicación, tests, manejo de errores, convenciones), distinta de la de seguridad, con informe en audits/. Usar cuando el usuario diga "audita el código" o "revisa la calidad del proyecto", y en el cierre de un goal.
metadata:
  origin: metodo-de-trabajo
  type: audit
---

# Auditoría de código

Solo lectura: propone los arreglos en el informe. Algo que huela a vulnerabilidad se anota como
referencia cruzada y se recomienda `auditoria-seguridad`, sin profundizar acá.

## Áreas

### 1. Datos

- Schemas contra migraciones: cada cambio de schema con su migración, sin desfase.
- Enums y campos que un lado asume y el otro no tiene; nombres inconsistentes entre modelos.
- Cada parte del código usa el cliente o la conexión que le corresponde.

### 2. Duplicación real

Componentes, clientes HTTP, tipos o reglas de negocio repetidos entre superficies o módulos, de unas
15 líneas o más, o con lógica de negocio: lo que debería vivir en un lugar compartido. Las
coincidencias triviales quedan fuera.

### 3. Tests y errores

- Inventario de tests por módulo; los módulos con cero tests.
- Errores de la base o de terceros que llegan crudos al cliente; endpoints sin manejo de error.
- Pantallas que llaman a la API sin estado de carga o de error.

### 4. Convenciones

- Rutas del backend contra las funciones del cliente del frontend; forma de las respuestas y de los
  errores, igual en todas las superficies.
- Las convenciones de `CLAUDE.md`: desviaciones sistemáticas, no casos aislados.

## Informe

En `audits/code-audit-<YYYY-MM-DD>.md`, con el mismo formato que `auditoria-seguridad`
(`.claude/skills/auditoria-seguridad/SKILL.md`, sección "Formato del informe"): encabezado con fecha,
commit y alcance, tabla por severidad, un bloque por hallazgo y "Sin verificar" al final. Se
priorizan los hallazgos que causan bugs sobre los de estilo.

## Terminado cuando

Las cuatro áreas están recorridas y cada hallazgo cita archivos y líneas reales. Entonces, en el
chat: lo más importante y la sugerencia de pasarlo a la tabla de deuda con `organizar-proyecto`.
