# Metodologia Goethe: desarrollo y migracion de sistemas a Azure

Version 2.0 - 2026-07-22

Documento PORTABLE para cualquier equipo que desarrolle un sistema nuevo o
migre una solucion existente a Azure. Define seguridad, metodologia, stack
institucional y, antes de desplegar, un proceso obligatorio de dimensionamiento
que permita elegir la arquitectura de menor costo que cumpla los objetivos de
rendimiento, disponibilidad y operacion.

Responsable: Joaquin Salas (`servicios@goethe.edu.ar`), director de INFRA de
Goethe-Schule Buenos Aires.

## 0. Reglas innegociables (leer primero)

1. **PROHIBIDO tocar recursos Azure ajenos al proyecto.** La suscripcion
   comparte produccion con otros sistemas. Cada proyecto opera UNICAMENTE
   dentro de sus resource groups `rg-goethe-<proyecto>-dev|prod`.
2. **Secretos jamas en chat, repo ni archivos commiteados.** Solo Key Vault;
   los carga Joaquin por el portal. `.env` es local y esta en `.gitignore`.
   Si un secreto se expone, se rota.
3. **Registro unico de pedidos**: todo pedido de Joaquin se anota DE INMEDIATO
   en `docs/PLAN_MEJORAS_WORKFLOW.md` y `docs/BACKLOG_AJUSTES.md`, aunque quede
   pendiente. Nada vive solo en la conversacion.
4. **Nunca se prueba primero en produccion.** Todo cambio: build + tests ->
   deploy automatico a dev -> prueba de Joaquin -> promocion manual a prod.
5. **UI**: nunca `confirm()`/`alert()` nativos; siempre modales propios. Todo
   responsive, accesible y apto para el flujo real de trabajo.
6. **Todo auditable**: acciones de negocio en tabla `Auditoria` append-only,
   escrita en la misma transaccion que la mutacion.
7. **No se crean servicios Azure antes de aprobar el dimensionamiento.** Se
   debe relevar uso, crecimiento, estacionalidad, latencia y continuidad;
   comparar alternativas con precios vigentes de la region y documentar la
   decision en `docs/DIMENSIONAMIENTO_Y_COSTOS.md`.
8. **Reducir costo no significa degradar requisitos.** Seguridad, aislamiento,
   recuperacion y rendimiento acordado son restricciones. Entre las opciones
   que las cumplen se elige la de menor costo total de operacion.
9. **Ningun SKU es eterno.** Se mide el uso real y se ajusta capacidad despues
   de 7 y 30 dias, luego de cada periodo pico y como minimo trimestralmente.

## 1. Hito 0: consulta obligatoria de dimensionamiento

Antes de recomendar un plan o crear infraestructura, el equipo debe consultar
al owner y registrar las respuestas. No se puede asumir que un sistema nuevo
necesita el mismo plan que otro proyecto.

### 1.1 Cuestionario minimo

1. **Usuarios**: registrados iniciales y a 12/24 meses; usuarios activos por
   dia y por mes; concurrencia normal y maxima esperada.
2. **Patron de uso**: continuo, de oficina, intermitente o estacional; dias y
   franjas de uso; duracion y frecuencia de las campanas o picos.
3. **Carga**: solicitudes o transacciones normales y pico; proporcion de
   lectura/escritura; procesos mas pesados; tareas programadas e integraciones.
4. **Datos**: volumen inicial, crecimiento mensual/anual, cantidad y tamano de
   archivos, retencion, historico y requisitos de backup.
5. **Rendimiento**: objetivo de latencia p95 para operaciones interactivas;
   tiempo aceptable de inicio en frio; duracion maxima de reportes y procesos.
6. **Continuidad**: horario de servicio, SLA necesario, RTO y RPO; impacto de
   una interrupcion; necesidad de alta disponibilidad o redundancia regional.
7. **Seguridad y red**: sensibilidad de los datos, exposicion publica,
   integraciones, restricciones de IP, endpoints privados y cumplimiento.
8. **Observabilidad**: volumen estimado de logs, trazas y metricas; retencion;
   eventos que nunca pueden muestrearse, como seguridad y auditoria.
9. **Ambientes**: dev, test, UAT y prod; cuales pueden apagarse o escalar a cero
   y cuales requieren respuesta inmediata.
10. **Presupuesto**: limite mensual y anual, moneda, margen admitido y costo de
    una degradacion; beneficios o franquicias disponibles en la suscripcion.
11. **Crecimiento y operacion**: horizonte de crecimiento, capacidad del equipo
    para operar servicios y momento en que se revisara la arquitectura.

Si todavia no existen mediciones, se documentan supuestos conservadores,
fuente de cada supuesto, riesgo, margen de capacidad y plan para reemplazarlos
por metricas reales. Nunca se oculta una estimacion como si fuera un dato.

### 1.2 Entregable obligatorio

Crear `docs/DIMENSIONAMIENTO_Y_COSTOS.md` antes de infraestructura, con:

- resumen de respuestas y supuestos;
- objetivos medibles de latencia, disponibilidad, RTO y RPO;
- al menos dos arquitecturas candidatas, incluida una opcion de bajo costo;
- estimacion mensual normal, mensual pico y anual por ambiente y servicio;
- region, SKU, unidades, horas activas, almacenamiento, backups, egreso de red
  y observabilidad incluidos en el calculo;
- beneficios gratuitos o descuentos identificados por separado, con sus
  limites y fecha de verificacion;
- comparacion de rendimiento, cold start, SLA, seguridad, escalabilidad,
  mantenimiento y costo total;
- arquitectura elegida, alternativas descartadas y justificacion;
- umbrales y calendario de escalado, reduccion o apagado;
- presupuesto, alertas, responsables y plan de medicion posterior.

Los precios y la disponibilidad de SKU cambian. Deben verificarse el mismo dia
de la decision en fuentes oficiales, para la region y moneda de la suscripcion.
No se reutilizan cifras historicas ni se presume que una tecnologia es mas
barata por su nombre.

### 1.3 Puertas de decision

1. **G0 - Alcance entendido**: flujo, datos, usuarios y restricciones.
2. **G1 - Dimensionamiento aprobado**: alternativas, rendimiento y costos
   aceptados por el owner. Recien entonces se crean recursos.
3. **G2 - Infraestructura validada**: seguridad, presupuestos, alertas y
   despliegue dev operativos.
4. **G3 - Rendimiento validado**: prueba de carga con concurrencia pico mas
   margen y objetivos p95 cumplidos antes de produccion.
5. **G4 - Ajuste con uso real**: costos y metricas revisados a 7/30 dias y al
   finalizar el primer pico de uso.

## 2. Stack institucional y estrategia de seleccion

El stack de aplicacion se mantiene consistente. Los servicios administrados y
sus SKU se eligen por dimensionamiento; los ejemplos son puntos de partida, no
decisiones automaticas.

| Capa | Estandar / criterio de seleccion |
| --- | --- |
| Backend | .NET LTS, minimal APIs y EF Core |
| Frontend | React + TypeScript + Vite; SPA servida por backend; i18n ES/DE si aplica |
| Base de datos | Comparar Azure SQL, PostgreSQL y MySQL administrados segun carga, costo regional, SLA y requisitos funcionales. Azure SQL es la referencia institucional, no un SKU obligatorio |
| Archivos | Azure Blob Storage privado; tier y ciclo de vida segun frecuencia y retencion |
| Secretos | Azure Key Vault; prod con purge protection |
| Hosting | Azure Container Apps Consumption como referencia; min/max replicas segun cold start, concurrencia y estacionalidad |
| Registro | Un ACR Basic por proyecto compartido entre ambientes, salvo requisito documentado; prod consume la imagen probada en dev |
| Observabilidad | Application Insights + Log Analytics con muestreo, topes y retencion definidos; errores, seguridad y auditoria no se descartan |
| Tests | xUnit; dominio con matriz de casos; integracion con motor representativo |
| CI/CD | GitHub Actions con OIDC federado, sin secretos Azure en GitHub |
| Identidad | Proveedor institucional, normalmente Google OAuth `goethe.edu.ar`, mas tabla Usuarios propia |
| Email | Gmail API con service account y delegacion de alcance minimo; credencial en Key Vault |
| Region | `brazilsouth` por defecto; otra region requiere comparar latencia, residencia, disponibilidad y precio |

Naming: `rg-goethe-<p>-dev|prod`, `app-goethe-<p>-*`, `sql-goethe-<p>-*`,
`sqldb-goethe-<p>`, `kv-goethe-<p>-*`, `stgoethe<p><env>`,
`cae-goethe-<p>-*`, `appi-goethe-<p>-*`, ACR `acrgoethe<p>`.

### 2.1 Guia de decision por servicio

**Base de datos**

- Evaluar ofertas gratuitas para dev/POC solo si sus limites, ausencia de SLA
  y politica de pausa son aceptables. Nunca basar produccion critica en una
  franquicia no garantizada.
- Para produccion pequena con respuesta predecible, comparar un tier
  provisionado basico con opciones serverless. Medir consultas e indices.
- Serverless resulta conveniente cuando la inactividad compensa el costo de
  computo y el cold start es aceptable. Si no puede pausarse por latencia, se
  calcula su costo con la capacidad minima activa.
- PostgreSQL o MySQL se eligen por compatibilidad, portabilidad, extensiones o
  costo total comprobado. No se presume que son mas baratos: se comparan
  compute, almacenamiento, backups, alta disponibilidad y operacion.
- No alojar una base autogestionada dentro del contenedor de la aplicacion sin
  una excepcion aprobada que cubra backups, restore, parches y disponibilidad.

**Compute y hosting**

- Dev/test pueden usar `min-replicas=0` si el inicio en frio es aceptable.
- Prod puede escalar a cero en sistemas intermitentes solo cuando el objetivo
  de latencia lo permita. Para una UX inmediata se mantiene al menos una
  replica durante la ventana activa.
- En aplicaciones estacionales se admite elevar capacidad durante la campana
  y reducirla al terminar, de manera automatizada o mediante runbook.
- Definir concurrencia por replica, CPU/memoria, minimo, maximo y reglas de
  escalado a partir de una prueba; no copiar parametros de otro sistema.
- App Service dedicado, Functions Premium, Kubernetes o maquinas virtuales
  requieren una necesidad documentada que Container Apps no pueda cubrir.

**Storage, registro y red**

- Usar Blob Standard LRS como punto de partida cuando cumpla durabilidad y
  residencia; aplicar lifecycle a tiers cool/archive segun acceso y retencion.
- Compartir ACR entre dev/prod del mismo proyecto y limpiar imagenes antiguas;
  no compartir datos, Key Vault ni base productiva para ahorrar costo.
- CDN, Front Door, Application Gateway, NAT Gateway, Redis, API Management,
  endpoints privados u otros servicios fijos se agregan solo por un requisito
  medido de seguridad, red, latencia o escala.
- La omision de un servicio de red debe pasar por analisis de riesgo. El ahorro
  no habilita exposicion indebida ni controles de acceso mas debiles.

**Observabilidad**

- Configurar muestreo adaptativo para telemetria de alto volumen, limites
  diarios y retencion acorde con operacion y cumplimiento.
- Preservar sin muestreo errores relevantes, autenticacion, eventos de
  seguridad y la auditoria de negocio.
- Las franquicias suelen ser compartidas o limitadas: verificarlas en la
  suscripcion y no tratarlas como costo cero permanente.
- Crear alertas utiles; evitar logs verbosos permanentes y duplicacion de la
  misma telemetria en varios destinos.

### 2.2 Presupuesto de rendimiento

Cada proyecto define objetivos concretos, por ejemplo latencia p95, tiempo de
inicio, concurrencia pico y duracion de reportes. Antes de prod se ejecuta una
prueba con carga pico mas margen y datos de volumen representativo. Se revisan
CPU, memoria, replicas, conexiones, DTU/vCore o equivalente, bloqueos, tiempos
de consulta, errores y throttling.

Optimizar primero aplicacion y consultas: paginacion, indices, pooling,
compresion, cache HTTP y `ReadyToRun` cuando aporte. Aumentar SKU despues de
identificar el cuello de botella, salvo que exista un riesgo operativo urgente.

## 3. Politicas de seguridad (desde el hito 1)

1. **Autenticacion**: cookie auth; OAuth solo en `/auth/login`; dominio
   permitido + usuario ACTIVO segun la regla funcional del sistema. API
   devuelve 401/403 JSON, no redirects. MFA exigido en cuentas institucionales.
2. **Autorizacion server-side en cada endpoint** por rol y alcance de datos.
   El menu del frontend es cosmetico. Matriz de permisos en codigo con tests.
3. **Superadmin hardcodeado**: `servicios@goethe.edu.ar`; administra catalogos
   de acceso y solo se modifica a si mismo, salvo decision expresa del proyecto.
4. **Validacion allowlist** en inputs y CHECK constraints en SQL para dominios
   cerrados; un valor invalido no entra ni por un bug de aplicacion.
5. **Endpoints publicos**: superficie minima, rate limiting, antiforgery
   resuelto explicitamente y validacion estricta de archivos.
6. **Archivos**: Blob privado; acceso mediante SAS breve generada por managed
   identity; lecturas auditadas; metadatos y hash SHA-256 en tabla.
7. **Anti-clickjacking**: `frame-ancestors 'none'` y `X-Frame-Options: DENY`;
   excepciones explicitas y acotadas por ruta.
8. **Data Protection keys persistidas** en Blob para sobrevivir despliegues y
   escalado a cero. El frontend informa una sesion expirada de forma clara.
9. **Acceso a datos**: minimo privilegio y red restringida segun el analisis de
   riesgo. Reglas temporales se eliminan al terminar.
10. **Email en UAT**: `Email__RedirectAllTo` redirige a servicios@ con prefijo
    `[PRUEBA]`; se desactiva recien en el corte aprobado.
11. **Deploy prod con gate**: workflow manual con SHA explicito y confirmacion
    `DESPLEGAR`; reviewers obligatorios cuando el plan GitHub lo permita.
12. **Brechas registradas** en `docs/SEGURIDAD_ISO27001.md`, con riesgo,
    responsable y resolucion. El sistema se construye alineado al Anexo A con
    evidencia auditable.

## 4. Metodologia de trabajo (sprints/hitos)

1. **Descubrimiento y dimensionamiento antes de infraestructura**: completar
   Hito 0, aprobar `DIMENSIONAMIENTO_Y_COSTOS` y recien despues crear servicios.
2. **Plan por hitos**: dimensionamiento -> infraestructura -> esqueleto,
   CI/CD y login -> modelo de datos -> backend -> frontend por pantalla ->
   rendimiento/UAT -> produccion y corte.
3. **Joaquin prueba cada entrega en dev**; ajustes como AJ-0NN agrupados en
   lotes pequenos para no acumular cambios sin validar.
4. **Bitacora por hito** (`docs/bitacora/HITO-N-*.md`): que se hizo y tabla
   problema/causa/solucion de cada tropiezo.
5. **Ciclo de cambio**: codigo + tests -> commit descriptivo -> push -> deploy
   a dev -> smoke test -> prueba de Joaquin -> prod manual con SHA -> health
   check, verificacion de imagen y metricas.
6. **Documentos minimos**: README, PLAN_MIGRACION_AZURE,
   DIMENSIONAMIENTO_Y_COSTOS, bitacora/, DER, ROLES_Y_PERMISOS,
   OPERACION_AZURE, SEGURIDAD_ISO27001, UAT_CHECKLIST,
   PLAN_MEJORAS_WORKFLOW, BACKLOG_AJUSTES y, si migra,
   COBERTURA_VS_CHECKLIST_GAS.
7. **UAT formal** por rol y corte final con checklist: modo email, dominio,
   sistema anterior, restore, accesos, rendimiento y alertas.
8. **Datos**: confirmar siempre si se migran. Si son de prueba, iniciar limpio
   y proveer ABMs para la carga inicial.

## 5. Convenciones de modelo de datos

1. **Una base por sistema**; integraciones via APIs o exports, nunca joins
   entre bases de sistemas distintos.
2. Tablas y columnas en **espanol, PascalCase, plural**. PK `Id` int identity;
   bigint en tablas append-only de alto volumen. Sin prefijos tecnicos.
3. **Toda string con MaxLength**; fechas en UTC; frontend convierte a local.
4. **CHECK constraints** para dominios cerrados, generados desde catalogos de
   codigo para evitar divergencias.
5. `LegacyId` nullable UNIQUE en entidades migradas para ETL idempotente.
6. `Auditoria` y tablas de eventos son append-only, sin UPDATE/DELETE.
7. Maestras con `Activo`, `ModificadoPor` y `FechaModificacion`; soft-delete
   para datos de negocio.
8. Binarios siempre en Blob. Tabla `Archivos` con path unico, nombre,
   content-type, tamano, hash, usuario y fecha.
9. Estados y transiciones en codigo con tests; configuracion visual acotada y
   valores capturados preservados en historial.
10. Identidad de traza por email sin FK a Usuarios para sobrevivir a bajas.
11. `docs/DER.md` se actualiza en el mismo commit que cada migracion EF.

## 6. Medicion, costos y ajuste continuo

1. Etiquetar todos los recursos como minimo con `Project`, `Environment`,
   `Owner`, `CostCenter` y `ManagedBy`.
2. Crear presupuestos y alertas antes de servicios pagos. Referencia inicial:
   50%, 80% y 100%, ajustada al presupuesto aprobado.
3. Separar costo estimado, costo facturado y costo evitado por franquicias.
4. Revisar Azure Cost Management y metricas a 7 y 30 dias, al cierre de la
   primera campana y trimestralmente.
5. Comparar uso real contra supuestos: usuarios, concurrencia, CPU/memoria,
   consultas, almacenamiento, logs, egreso, latencia p95 y errores.
6. Aplicar rightsizing con evidencia: bajar o apagar capacidad ociosa, elevar
   antes de picos previstos y retirar recursos sin uso mediante cambio
   controlado. Toda modificacion queda en bitacora.
7. Alertar anomalias y proyectar el costo a fin de mes; no esperar a alcanzar
   el 100% para investigar.
8. Mantener un runbook de escalado estacional y reversa. El cambio debe poder
   ejecutarse sin recompilar la aplicacion.

## 7. Checklist de arranque de un proyecto nuevo

- [ ] Alcance, usuarios y proceso principal entendidos.
- [ ] Cuestionario de dimensionamiento respondido o supuestos documentados.
- [ ] Objetivos p95, cold start, SLA, RTO y RPO acordados.
- [ ] Precios y SKU verificados para region y suscripcion en la fecha actual.
- [ ] Al menos dos arquitecturas comparadas con costo normal, pico y anual.
- [ ] `docs/DIMENSIONAMIENTO_Y_COSTOS.md` aprobado por el owner (G1).
- [ ] Repo GitHub privado en `servicios-goethe/<proyecto>`.
- [ ] Resource groups dev/prod, tags, presupuesto y alertas 50/80/100%.
- [ ] Proyecto GCP propio para OAuth; no reutilizar clientes de otro sistema.
- [ ] Key Vaults y secretos cargados por portal; purge protection en prod.
- [ ] Esqueleto .NET+React con `/healthz`, identidad, Usuarios, superadmin,
      Auditoria y CI/CD OIDC antes de la primera feature.
- [ ] Prueba de carga definida para concurrencia pico mas margen.
- [ ] Docs minimos creados desde el dia 1.
- [ ] Si migra: congelar sistema anterior, documentar cobertura y decidir datos.
- [ ] Revisiones de costo/rendimiento a 7/30 dias agendadas.

## 8. Prompt de arranque para una nueva conversacion

> Vamos a desarrollar/migrar **<NOMBRE>** a Azure. Segui
> `docs/METODOLOGIA_PROYECTOS_AZURE.md`. Antes de recomendar SKU o crear
> recursos, haceme el cuestionario obligatorio de dimensionamiento: usuarios y
> concurrencia, patron y estacionalidad, transacciones, datos y crecimiento,
> archivos, latencia p95 y cold start, SLA/RTO/RPO, seguridad/red,
> observabilidad, ambientes, presupuesto y horizonte de crecimiento. Si no
> conozco una cifra, registra un supuesto y su plan de validacion. Verifica
> precios y beneficios vigentes para la region y suscripcion, compara al menos
> dos arquitecturas y prepara `docs/DIMENSIONAMIENTO_Y_COSTOS.md` con costo
> normal, pico y anual. Prioriza el menor costo total que cumpla seguridad y
> rendimiento. Espera mi aprobacion del G1 antes de crear recursos. Reglas
> criticas: nada fuera de los resource groups del proyecto, secretos solo en
> Key Vault, todo pedido se registra en PLAN_MEJORAS_WORKFLOW y
> BACKLOG_AJUSTES, dev antes de prod y toda decision queda documentada.
