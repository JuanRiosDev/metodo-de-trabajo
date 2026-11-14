# Roadmap {{PROYECTO}}

> Actualizado: {{FECHA}} — commit <!-- COMPLETAR: hash corto de main -->
> Lo genera y lo mantiene la skill `organizar-proyecto` a partir del código. Lo que no se pudo
> verificar va en "Sin verificar", nunca como hecho.

## Cómo leer este documento

Estados: ✅ Hecho (implementado, compila y conectado de punta a punta) · 🚧 En progreso (código real
pero incompleto o sin conectar) · ⬜ Pendiente (no existe o es solo un esqueleto). Una pantalla que
lee datos simulados en vez del backend real queda en 🚧 como mucho.

**Cifras de `main`** (del CI del último push, con fecha): <!-- COMPLETAR: tests por tipo y cobertura -->

---

## Estado por módulo

| Módulo | Backend | Frontend | Estado | Notas |
|---|---|---|---|---|
<!-- COMPLETAR: una fila por módulo de dominio, contrastada con el código -->

## Próximos pasos (por dependencias)

Cada tarea tiene una ficha autosuficiente en `.docs/tareas/` (skill `escribir-ficha`). Una ola son
hasta dos sesiones con zonas que no se pisan; la compuerta de cada PR está en la skill `orquestacion`.

| Ola | Tarea | Ficha | Depende de |
|---|---|---|---|

## Deuda técnica

### Tabla de la deuda abierta

Una fila por ítem, con un ID estable `D-NN` que no se reusa: las filas nuevas entran al final, en
orden de ID. Al cerrar un ítem se marca ✅ en la columna Tarea, con la tarea y la PR que lo cerró,
después de comprobarlo en el código de `main` o en el `*-decisiones.md` de la tarea.

- **Severidad:** Crítico, Alto, Medio o Bajo.
- **Tipo:** `seguridad`; `robustez` (un fallo, una carrera, un dato inconsistente o un problema de
  operación); `calidad` (tests, tipos, duplicación); `cosmético` (comentarios, nombres, partir
  archivos).
- **Tarea:** la tarea que lo cierra; para lo que sigue abierto, el dueño (una persona, `Cosmético`, o
  `sin asignar` con una línea de por qué).

**Conteo al {{FECHA}}:** 0 filas.

| ID | Severidad | Tipo | Qué | Origen | Tarea |
|---|---|---|---|---|---|

### Hallazgos

El detalle de cada ítem (de las auditorías de `audits/`, de las revisiones de PR y de las tareas),
con archivo y línea, cuando no entra en la fila.

## Sin verificar / bloqueos externos

Lo que depende de llaves, cuentas o decisiones del usuario, y lo que no se pudo comprobar desde el
repo, con la fecha del último intento.
