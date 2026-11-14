---
name: auditoria-seguridad
description: Auditoría de seguridad del repo completo que empieza por la invariante crítica de CLAUDE.md y deja un informe en audits/. Usar cuando el usuario diga "audita seguridad", "haz un security audit" o "revisa la invariante", y en el cierre de un goal.
metadata:
  origin: metodo-de-trabajo
  type: audit
---

# Auditoría de seguridad

Solo lectura: esta skill no modifica código, propone los arreglos en el informe. Para un cambio
puntual alcanza `/code-review`; esto es el repo entero.

## Orden (la prioridad no se altera)

### 1. La invariante crítica

Leé "Invariante crítica" en `CLAUDE.md` y seguí cada camino que la sostiene, de la entrada del
request hasta la base de datos. Buscá el camino donde se rompe: un dato del request usado sin validar
para elegir de quién son los datos, estado compartido entre requests concurrentes (singletons,
variables de módulo, cachés sin la clave correcta), un token de un contexto aceptado en otro. Si
`CLAUDE.md` no la define todavía, decilo en el informe y auditá la propiedad de los datos por usuario
(IDOR).

### 2. Autenticación y autorización

- Tokens con expiración, secreto desde el entorno (sin default en el código), rotación y revocación.
- Cada endpoint protegido tiene su guard; buscá los que no. Un recurso ajeno o de otro rol responde
  404, no 403 (un 403 confirma que existe).
- Links mágicos, OTP y reseteos: expiración, un solo uso, entropía, y un tope de pedidos por
  destinatario y por IP.

### 3. Integraciones externas

- Webhooks: la firma se valida antes de procesar; idempotencia por ID de evento; los montos se
  contrastan con el registro local.
- Credenciales de terceros solo en el backend: buscá tokens o claves en el código del frontend y en
  las variables públicas del bundler.

### 4. Secretos y configuración

- Credenciales en el código y `.env` reales en git (`git ls-files | grep -i env`).
- CORS restringido a los orígenes conocidos, headers de seguridad, validación de entrada con lista
  blanca, rate limiting global.
- Puertos de bases y colas sin exponer; credenciales de desarrollo distintas de las de producción.

### 5. Superficie pública (sin login)

- Respuestas que revelan qué existe (404 contra 403 contra 500, listados sin filtro).
- IDs de la URL o del query buscados dentro del alcance correcto.
- Formularios: validación, anti-spam, HTML sin sanitizar, mass assignment.

Un área que todavía no existe en el código se dice así en el informe, en vez de auditar lo que no hay.

## Formato del informe

Guardalo en `audits/security-audit-<YYYY-MM-DD>.md` (creá `audits/` si falta; sigue en
`.gitignore`). Si corrés como subagente sin permiso de escritura, devolvé el informe entero en tu
respuesta y quien coordina lo guarda.

Encabezado: fecha, commit auditado (`git rev-parse --short HEAD`), alcance y una tabla-resumen por
severidad. Un bloque por hallazgo:

```markdown
## [SEVERIDAD] Título corto del hallazgo

- **Severidad**: Crítico | Alto | Medio | Bajo
- **Archivo**: ruta/al/archivo.ext:línea
- **Descripción**: qué está mal y qué escenario concreto de ataque o fuga habilita.
- **Recomendación**: el cambio concreto (con snippet si aplica).
```

Cierre: la sección "Sin verificar", con lo que no se pudo comprobar.

## Terminado cuando

Las cinco áreas están recorridas en orden, cada hallazgo cita un archivo y una línea que abriste, y
cada severidad se sostiene con su escenario. Entonces, en el chat: los Críticos y Altos, y la
sugerencia de pasarlos a la tabla de deuda con `organizar-proyecto`.
