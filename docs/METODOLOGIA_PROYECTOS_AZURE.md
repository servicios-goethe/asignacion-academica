# Metodologia Goethe: desarrollo y migracion de sistemas a Azure

Documento PORTABLE: se entrega tal cual a cualquier conversacion/equipo que
desarrolle un sistema nuevo o migre una solucion GAS a Azure (ej: Mapas de
Aprendizaje). Nacio del proyecto Onboarding/ATS (repo
`servicios-goethe/goethe-ats`), que es la implementacion de referencia de todo
lo que sigue. Responsable: Joaquin Salas (servicios@goethe.edu.ar), director
de INFRA de Goethe-Schule Buenos Aires.

## 0. Reglas innegociables (leer primero)

1. **PROHIBIDO tocar recursos Azure ajenos al proyecto.** La suscripcion
   comparte produccion con otros sistemas (ej: treffpunkt). Cada proyecto opera
   UNICAMENTE dentro de sus resource groups `rg-goethe-<proyecto>-dev|prod`.
2. **Secretos jamas en chat, repo ni archivos commiteados.** Solo Key Vault;
   los carga Joaquin por el portal. `.env` es local y esta en `.gitignore`.
   Si un secreto se expone (aunque sea en repo privado): se rota, no se discute.
3. **Registro unico de pedidos**: todo pedido de Joaquin se anota DE INMEDIATO
   en `docs/PLAN_MEJORAS_WORKFLOW.md` (lotes) + `docs/BACKLOG_AJUSTES.md`
   (items AJ-0NN con estado), aunque quede pendiente. Nada vive solo en la
   conversacion.
4. **Nunca se prueba primero en produccion.** Todo cambio: build + tests ->
   deploy automatico a dev -> prueba de Joaquin -> promocion manual a prod.
5. **UI**: nunca `confirm()`/`alert()` nativos; siempre modales propios
   (componente ConfirmModal). Todo responsive (patron `tabla-cards` en mobile).
6. **Todo auditable**: acciones de negocio en tabla `Auditoria` append-only,
   escrita en la misma transaccion que la mutacion.

## 1. Stack estandar

| Capa | Tecnologia |
| --- | --- |
| Backend | .NET LTS (hoy 10), minimal APIs, EF Core |
| Base | Azure SQL Database (Basic al inicio; subir tier segun uso) |
| Frontend | React + TypeScript + Vite; SPA servida por el backend; i18n ES/DE si aplica (react-i18next) |
| Archivos | Azure Blob Storage privado (contenedores por uso + `dataprotection` para claves de sesion) |
| Secretos | Azure Key Vault (prod con purge protection) |
| Hosting | Azure Container Apps: dev min-replicas 0 (ahorro), prod min-replicas 1 + publish ReadyToRun (sin cold start) |
| Observabilidad | Log Analytics + Application Insights por ambiente |
| Tests | xUnit; logica de dominio con matriz de casos; servicios contra SQLite en memoria |
| CI/CD | GitHub Actions con OIDC federado (cero secretos de Azure en GitHub) |
| Identidad | Google OAuth (dominio goethe.edu.ar) + tabla Usuarios propia |
| Email | Gmail API, service account con delegacion scope UNICO `gmail.send`, impersona una casilla real (ej rrhh@); credencial en KV |
| Region | brazilsouth |

Naming: `rg-goethe-<p>-dev|prod`, `app-goethe-<p>-*`, `sql-goethe-<p>-*` /
base `sqldb-goethe-<p>`, `kv-goethe-<p>-*`, `stgoethe<p><env>`,
`cae-goethe-<p>-*`, `appi-goethe-<p>-*`, ACR `acrgoethe<p>dev` (compartido
dev/prod: prod consume la imagen ya construida y probada, nunca rebuildea).

## 2. Politicas de seguridad (se implementan SIEMPRE, desde el hito 1)

1. **Autenticacion**: cookie auth; Google OAuth solo en /auth/login; dominio
   permitido + usuario ACTIVO en tabla Usuarios (si no: 401/403 JSON para la
   SPA, nunca redirect en llamadas API). MFA exigido en cuentas Google.
2. **Autorizacion server-side en cada endpoint** (rol y alcance por datos, ej
   directores solo su nivel). El menu del frontend es cosmetico. La matriz de
   permisos vive en codigo con tests, NO es editable por pantalla.
3. **Superadmin hardcodeado**: servicios@goethe.edu.ar; solo el administra los
   catalogos que gobiernan el acceso; solo se modifica a si mismo.
4. **Validacion allowlist en todo input** (campos, opciones, tamanos); CHECK
   constraints en SQL para dominios cerrados: un valor invalido no entra ni
   por bug de aplicacion.
5. **Endpoints publicos** (sin login): superficie minima, rate limiting por
   IP, DisableAntiforgery explicito y validacion estricta de archivos (tipo,
   tamano, extension).
6. **Archivos**: Blob privado; acceso solo via SAS de 10 minutos generada por
   managed identity; cada lectura auditada; metadatos + hash SHA-256 en tabla.
7. **Anti-clickjacking**: `frame-ancestors 'none'` + X-Frame-Options DENY en
   toda la app; excepciones explicitas por ruta si algo se embebe (solo desde
   goethe.edu.ar).
8. **Data Protection keys persistidas en Blob** (si no, cada deploy/scale-to-0
   invalida las sesiones). Mensaje "sesion expirada" amable en el frontend.
9. **SQL firewall**: administracion solo desde las IPs fijas del colegio
   (181.30.18.114-118, regla `AdminColegio`); desde otro lado, portal o regla
   temporal que se borra al terminar.
10. **Email en modo prueba durante UAT**: `Email__RedirectAllTo` redirige TODO
    a servicios@ con prefijo [PRUEBA] y banner; se vacia recien en el corte.
11. **Deploy prod con gate**: workflow manual con SHA explicito + campo de
    confirmacion "DESPLEGAR" (Required reviewers de GitHub exige plan pago en
    repos privados; al sumar equipo, GitHub Pro + reviewers).
12. **Brechas con registro**: lo no resuelto se anota en
    `docs/SEGURIDAD_ISO27001.md` (tabla de brechas con riesgo y resolucion
    prevista), nunca se tapa. ISO 27001 certifica organizaciones; el sistema
    se construye "alineado al Anexo A con evidencia auditable".

## 3. Metodologia de trabajo (sprints/hitos)

1. **Plan por hitos** antes de empezar (`docs/PLAN_MIGRACION_AZURE.md` como
   modelo): infraestructura -> esqueleto+CI/CD+login -> modelo de datos ->
   backend seguro -> frontend pantalla por pantalla -> produccion+UAT -> corte.
2. **Joaquin prueba cada entrega en dev** antes de seguir; el frontend se
   entrega PANTALLA POR PANTALLA. Sus ajustes entran como AJ-0NN y se agrupan
   en lotes chicos ("vamos probando para no hacer todo junto").
3. **Bitacora por hito** (`docs/bitacora/HITO-N-*.md`): que se hizo, y tabla
   problema/causa/solucion de cada tropiezo (el conocimiento operativo queda
   escrito, no en la memoria de nadie).
4. **Ciclo de cambio**: codigo + tests verdes local -> commit descriptivo ->
   push a main -> deploy automatico a dev -> smoke test -> prueba de Joaquin
   -> `deploy-prod.yml` con SHA + DESPLEGAR -> verificacion en prod (healthz,
   imagen corriendo, cache-bust del bundle si hace falta).
5. **Documentos minimos del repo** (mismos nombres en todos los proyectos):
   README (stack + orden de lectura), PLAN_MIGRACION_AZURE, bitacora/, DER,
   ROLES_Y_PERMISOS, OPERACION_AZURE (runbook + checklist de corte),
   SEGURIDAD_ISO27001, UAT_CHECKLIST (por rol), PLAN_MEJORAS_WORKFLOW,
   BACKLOG_AJUSTES, y COBERTURA_VS_CHECKLIST_GAS si es migracion.
6. **UAT formal** con checklist por rol y modo prueba de emails; **corte
   final** con checklist propio (apagar modo prueba, dominio, redireccion del
   sistema viejo, prueba de restore, entrega de accesos).
7. **Datos**: si los datos del sistema viejo son de prueba, corte con carga
   inicial limpia y ABMs para que Joaquin cargue todo (confirmarlo siempre).

## 4. Convenciones de modelo de datos (mantener la MISMA logica en todos los DER)

1. **Una base por sistema** (aislamiento); integraciones entre satelites via
   exports/Data Lake, nunca joins entre bases.
2. Tablas y columnas en **espanol, PascalCase, plural** (Usuarios, Niveles,
   Postulaciones). PK `Id` int identity (bigint en tablas append-only de alto
   volumen). Sin prefijos tecnicos.
3. **Toda string con MaxLength**; fechas en **UTC** (`datetime2`), el frontend
   convierte a hora local (helper `fechas.ts`).
4. **CHECK constraints para todo dominio cerrado** (roles, estados, tipos),
   generados desde los catalogos del codigo (Domain) para que codigo y base
   nunca diverjan.
5. **`LegacyId` nullable UNIQUE** en entidades migradas desde GAS/Firestore
   (idempotencia del ETL).
6. **Append-only**: `Auditoria` (Accion, Entidad, EntidadId, Usuario, Fecha,
   DetalleJson) y tablas de eventos/historial. Nunca UPDATE/DELETE sobre ellas.
7. **Maestras** con `Activo` (soft-delete; nunca DELETE fisico de datos de
   negocio), `ModificadoPor`, `FechaModificacion`. Catalogos simples en
   `OpcionesMaestras` (Tipo + Valor, UK compuesta); textos configurables en
   `Parametros` (clave/valor con allowlist de claves en codigo).
8. **Archivos**: tabla `Archivos` (Contenedor, BlobPath UK, NombreOriginal,
   ContentType, TamanoBytes, HashSha256, SubidoPor, FechaSubida); las
   entidades referencian por FK. El binario SIEMPRE en Blob, jamas en SQL.
9. **Workflows**: catalogo de estados y transiciones EN CODIGO con tests
   (garantia anti-salteo); lo configurable por pantalla es acotado (activacion
   de etapas opcionales, nombres de campos) y los valores capturados van al
   historial (DetalleJson), no a columnas nuevas por campo.
10. **Identidad en la traza por email** (string), sin FK a Usuarios: la traza
    sobrevive a bajas/cambios de usuario.
11. `docs/DER.md` en mermaid, actualizado en el MISMO commit que cada
    migracion de esquema. Migraciones EF con nombres descriptivos y
    `MigrateOnStartup=true`.

## 5. Checklist de arranque de un proyecto nuevo (hito 0/1)

- [ ] Repo GitHub privado en `servicios-goethe/goethe-<proyecto>`.
- [ ] Resource groups dev y prod + presupuesto con alertas 50/80/100% en ambos.
- [ ] Proyecto GCP PROPIO para el cliente OAuth (no reusar el de otro sistema;
      leccion aprendida) con las redirect URIs `<url>/signin-google`.
- [ ] Key Vaults (prod con purge protection) y secretos cargados por portal.
- [ ] Esqueleto .NET+React con /healthz, login Google, tabla Usuarios +
      superadmin, Auditoria, y CI/CD OIDC funcionando (deploy-dev automatico,
      deploy-prod manual con confirmacion) ANTES de la primera feature.
- [ ] Docs minimos creados desde el dia 1 (seccion 3.5).
- [ ] Si migra de GAS: congelar el codigo GAS con un tag, documentar cobertura
      funcional vs checklist, definir si los datos viejos migran o no.

## 6. Prompt de arranque para una nueva conversacion

Pegar esto (ajustando el nombre) al iniciar el proyecto en otra conversacion:

> Vamos a desarrollar/migrar **<NOMBRE>** (hoy en GAS) a Azure. Segui al pie
> de la letra `docs/METODOLOGIA_PROYECTOS_AZURE.md` del repo
> `servicios-goethe/goethe-ats` (stack, seguridad, metodologia por hitos con
> mi prueba en dev y promocion manual a prod, convenciones de DER y docs
> minimos). Reglas criticas: nada fuera de los resource groups del proyecto
> (PROHIBIDO tocar treffpunkt u otros), secretos solo por Key Vault cargados
> por mi, todo pedido mio se registra al instante en PLAN_MEJORAS_WORKFLOW.md
> + BACKLOG_AJUSTES.md, modales propios (nunca popups nativos), y todo
> documentado para un futuro equipo de mantenimiento. Arranca armando el plan
> de hitos y el checklist de arranque, y espera mi OK antes de crear recursos.
