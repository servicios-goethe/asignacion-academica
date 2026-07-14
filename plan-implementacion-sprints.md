# Plan de implementacion por sprints

## Vision corregida

El sistema administra cada ciclo lectivo desde cero. Para el ciclo 2027 no existe una nomina previa de docentes dentro de la aplicacion: cualquier persona con una cuenta Google Workspace `@goethe.edu.ar` puede autenticarse, identificarse y cargar su disponibilidad para el proximo ciclo.

La carga docente construye la nomina de trabajo del ciclo. Luego el Director analiza las presentaciones, define la estructura academica, realiza las asignaciones y genera la exportacion GPU014 para Untis.

No se migraran disponibilidades ni asignaciones historicas. Los catalogos institucionales que gobiernan el formulario, la estructura y Untis se cargaran como configuracion inicial del ciclo.

## Stack tecnologico

| Capa | Tecnologia |
| --- | --- |
| Backend | .NET 10 LTS, ASP.NET Core Minimal APIs, EF Core |
| Frontend | React, TypeScript, Vite, SPA servida por el backend |
| Base de datos | Azure SQL Database, tier Basic inicial |
| Identidad | Google OAuth, dominio `goethe.edu.ar`, cookie segura |
| Hosting | Azure Container Apps |
| Secretos | Azure Key Vault |
| Archivos | Azure Blob Storage privado, si fueran necesarios |
| Observabilidad | Application Insights y Log Analytics |
| Pruebas | xUnit, pruebas de dominio y servicios con SQLite en memoria |
| CI/CD | GitHub Actions y autenticacion OIDC federada con Azure |
| Region | `brazilsouth` |

Los ambientes quedan aislados en `rg-goethe-asignacion-academica-dev` y `rg-goethe-asignacion-academica-prod`. Ningun recurso de otros proyectos puede modificarse.

## Modelo de acceso

- Visitante externo: no puede ingresar.
- Docente `@goethe.edu.ar`: puede autenticarse sin alta previa, crear su perfil para el ciclo abierto, guardar borrador y enviar su disponibilidad.
- Director: puede consultar todas las presentaciones, observarlas, definir estructura, asignar docentes, cerrar etapas y exportar a Untis.
- Administrador tecnico: administra ciclos, catalogos y usuarios privilegiados.
- Superadministrador: `servicios@goethe.edu.ar`, definido en codigo.

El dominio habilita la entrada docente, pero no otorga roles administrativos. Director y Administrador requieren alta explicita en la tabla `Usuarios` y funcionan respectivamente como referente funcional y tecnico. Sus titulares pueden cambiar por datos; el unico email fijo en codigo es el del Superadministrador.

## Cadencia y gobierno

- Sprint 0: una semana de definicion y preparacion.
- Sprints 1 a 6: dos semanas cada uno.
- Cada entrega se publica primero en `dev` y es validada por Joaquin.
- Produccion se promociona manualmente usando el mismo artefacto probado y un SHA explicito.
- Todo ajuste se registra en `docs/PLAN_MEJORAS_WORKFLOW.md` y `docs/BACKLOG_AJUSTES.md`.
- Cada sprint/hito deja una bitacora tecnica y funcional.

## Sprint 0: Arranque funcional y tecnico

Objetivo: cerrar las decisiones que condicionan el modelo y dejar preparado el repositorio y el despliegue seguro.

Entregables:

- Vision funcional corregida y flujo del ciclo 2027.
- Arquitectura Azure y convenciones del proyecto.
- Matriz inicial de roles y permisos.
- Modelo conceptual y DER inicial.
- Reglas pendientes de disponibilidad, estructura, asignacion y Untis.
- Repositorio GitHub consolidado y documentacion minima.
- Inventario de recursos Azure a crear, con presupuesto y alertas.
- Backlog MVP priorizado y criterios de aceptacion del Sprint 1.

Criterio de cierre: decisiones criticas registradas, acceso GitHub confirmado y autorizacion de Joaquin antes de crear recursos Azure.

## Sprint 1: Fundacion, seguridad y CI/CD

Objetivo: obtener un esqueleto desplegado en `dev` antes de desarrollar funcionalidades de negocio.

Entregables:

- Solucion .NET 10 + React/TypeScript/Vite.
- `/healthz`, manejo global de errores y telemetria.
- Azure SQL con migraciones EF Core.
- Google OAuth restringido a `@goethe.edu.ar`.
- Autoalta docente por ciclo y roles administrativos explicitos.
- Tablas `Usuarios`, `CiclosLectivos` y `Auditoria` append-only.
- Headers de seguridad, antiforgery, rate limiting y cookies seguras.
- GitHub Actions: build y tests; deploy automatico a dev; promocion manual a prod.
- Recursos base dev y prod, Key Vault y OIDC, sin secretos en GitHub.

Criterios de aceptacion:

- Una cuenta `@goethe.edu.ar` sin registro previo puede iniciar sesion y comenzar su perfil docente del ciclo abierto.
- Una cuenta externa queda rechazada.
- El menu y cada endpoint respetan permisos server-side.
- Un commit en `main` despliega automaticamente en dev con tests verdes.

## Sprint 2: Identificacion y disponibilidad docente 2027

Objetivo: habilitar la primera etapa operativa del ciclo.

Entregables:

- Apertura y cierre configurable del periodo de carga.
- Alta del perfil declarado por el docente: identidad Google, nombre, uno o varios departamentos, cargo, horas frente a curso y observaciones.
- Grilla semanal configurable de bloques horarios.
- Guardado automatico/borrador, validacion y envio final.
- Calculo visible de disponibilidad declarada contra horas frente a curso mas 35%; si no alcanza, se muestra una advertencia que no bloquea el envio.
- Estados: Borrador, Enviada, Observada y Aceptada.
- Confirmaciones mediante modales propios y experiencia responsive.
- Auditoria de envios, reaperturas y cambios.

Criterios de aceptacion:

- El docente completa el proceso sin haber sido precargado.
- Solo puede ver y editar su propia presentacion.
- El sistema conserva la identidad Google y los datos declarados para el ciclo 2027.
- El Director puede observar y reabrir una presentacion con trazabilidad.

## Sprint 3: Panel de Direccion y estructura academica

Objetivo: convertir las presentaciones recibidas en insumo de planificacion y construir la oferta anual.

Entregables:

- Tablero de avance, filtros, pendientes, observadas e insuficiencias.
- Configuracion del ciclo con fechas de apertura y cierre de disponibilidad.
- ABM anual de cursos, divisiones, modalidades, materias, grupos y talleres.
- Matriz anual con cantidad semanal de modulos de 45 minutos por materia, curso y division, celdas aplicables/no aplicables y excepciones de carga por division.
- Horas catedra, codigos Untis y reglas de replicacion.
- Estados de estructura: En desarrollo, Finalizada, Aprobada y Reabierta.
- Validaciones de completitud y auditoria transaccional.

Criterios de aceptacion:

- El Director analiza el universo real surgido de las cargas 2027.
- No puede aprobar una estructura incompleta.
- Las materias comunes y de modalidad se aplican solo a las divisiones definidas por el Director.
- Las celdas deshabilitadas no generan espacios curriculares ni admiten asignaciones.
- La aplicacion no distribuye modulos por dia u horario; esa calendarizacion corresponde a Untis.

## Sprint 4: Asignacion docente

Objetivo: realizar la asignacion academica sobre estructura y disponibilidades aprobadas.

Entregables:

- Matriz por nivel, materia, division y grupo.
- Busqueda y filtros de docentes por perfil y disponibilidad.
- Asignacion con interaccion visual y alternativa accesible.
- Calculo de horas asignadas, saldo y regla del 35%.
- Alertas de conflicto horario, sobrecarga, falta de disponibilidad y vacantes.
- Resumen por docente y por division.
- Control de concurrencia, guardado incremental y auditoria.

Criterios de aceptacion:

- Los calculos coinciden con la matriz de casos validada.
- Toda asignacion queda trazada con usuario y fecha UTC.
- No se puede finalizar mientras existan espacios obligatorios sin cubrir.

## Sprint 5: Exportacion Untis y reportes

Objetivo: generar artefactos operativos confiables desde una asignacion aprobada.

Entregables:

- Generador GPU014 versionado y probado.
- Previsualizacion de errores y advertencias.
- Historial inmutable de exportaciones y hash del archivo.
- Reportes de carga, vacantes, conflictos e insuficiencias.
- Importacion real validada en la version de Untis del colegio.

Criterios de aceptacion:

- Untis importa el GPU014 sin errores bloqueantes.
- Los reportes cuadran con los casos controlados por Direccion.
- Regenerar un archivo no elimina la trazabilidad anterior.

## Sprint 6: UAT, endurecimiento y salida productiva

Objetivo: validar el flujo integral y habilitar el uso institucional.

Entregables:

- UAT formal por rol en dev.
- Pruebas de permisos, seguridad, rendimiento y recuperacion.
- Ajustes de UX surgidos de docentes piloto y Direccion.
- Runbook operativo, checklist de corte y prueba de restauracion.
- Alertas, dashboards de observabilidad y presupuesto Azure.
- Promocion manual del artefacto aprobado a produccion.

Criterios de aceptacion:

- Flujo completo validado desde el autoalta docente hasta Untis.
- Joaquin aprueba UAT en dev y autoriza el SHA de produccion.
- Operacion, seguridad y recuperacion quedan documentadas.

## Fuera del MVP

- Sugerencias automaticas de asignacion.
- Integracion directa con RRHH.
- Analitica historica entre ciclos.
- Gestion integral de aulas, salvo que GPU014 la requiera.
- Delegacion avanzada por departamento.
- Aplicacion movil nativa.

## Duracion estimada

El plan base es de 13 semanas: Sprint 0 de una semana y seis sprints de dos semanas. La fecha productiva se confirma al cerrar Sprint 0, una vez definidos el calendario institucional y el alcance exacto de Untis.
