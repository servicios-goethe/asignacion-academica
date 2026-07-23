# Plan de mejoras y workflow

## Lote 001 - Replanteo inicial

Fecha: 2026-07-14  
Estado: En curso; AJ-006 y AJ-007 completados

Incluye:

- AJ-001: adopcion del stack Azure institucional.
- AJ-002: inicio limpio del ciclo 2027.
- AJ-003: autoalta docente por dominio Google Workspace.
- AJ-004: consolidacion del repositorio GitHub.
- AJ-005: preparacion del despliegue Azure.
- AJ-006: creacion autorizada de los resource groups exclusivos del proyecto.
- AJ-007: presupuestos y alertas de consumo para ambos ambientes.
- AJ-008: referentes funcional y tecnico resueltos por perfiles; solo el Superadmin queda fijo por email.
- AJ-009: relacion de varios departamentos por docente y regla del 35% no bloqueante.
- AJ-010: estructura anual configurable por el Director mediante una matriz equivalente a la planilla actual.
- AJ-011: limite funcional confirmado entre carga semanal del sistema y calendarizacion en Untis.
- AJ-012: contrato del formulario docente basado en Google SSO y referencia visual del formulario actual.
- AJ-013: interfaz completa bilingue ES/DE con seleccion por usuario.
- AJ-014: bloques horarios 2027 confirmados segun las opciones seleccionables del Forms actual.
- AJ-015: metodologia Azure revisada para consultar dimensionamiento, comparar alternativas y aprobar costo/rendimiento antes de desplegar infraestructura.
- AJ-016: documento de seguridad ampliado para integrar gobierno del SGSI, Anexo A, gestion de riesgos, evidencia y condiciones de salida a produccion.
- AJ-017: dimensionamiento G1 aprobado por el owner: 80 docentes, 40 simultaneos como estres extremo, pico de cuatro semanas, objetivos p95, RTO/RPO, presupuesto y baseline Azure.
- AJ-018: Sprint 1 iniciado con esqueleto .NET/React, endpoints base, pantalla bilingue, configuracion local y CI de build/test.
- AJ-018: baseline Azure dev desplegado con SQL, Key Vault, Storage, ACR, observabilidad y Container App interna saludable; prod permanece bloqueado hasta SSO.
- AJ-019: Google OAuth propio pendiente; la CLI GCP no esta instalada en el entorno actual.
- AJ-020: ingress interno mantenido como medida preventiva mientras se configura Google SSO.
- AJ-021: proteccion de aplicacion requerida antes de habilitar acceso externo: autenticacion, dominio, rate limiting, limites de request, logging y replicas acotadas.
- AJ-022: contencion automatica de costos pendiente: budget de USD 100, Action Group, escala a cero, bloqueo de ingress y recuperacion manual.
- AJ-023: alertas de anomalias de costo y politicas preventivas pendientes para evitar exposiciones publicas o SKUs no aprobados.

## Lote 002 - Seguridad y contencion de costos

Objetivo: reducir la superficie de ataque y limitar el impacto economico de una exposicion o abuso antes de publicar la aplicacion.

Orden de implementacion:

1. Completar Google SSO y cargar los secretos reales en Key Vault sin versionarlos ni compartirlos por chat.
2. Mantener `externalIngress=false` hasta validar autenticacion, autorizacion por perfil y pruebas de acceso no autorizado.
3. Implementar rate limiting, limites de payload, logs de seguridad y maximo de replicas controlado.
4. Configurar alertas de presupuesto y anomalias; luego agregar Action Group con automatizacion de emergencia.
5. Probar el bloqueo en dev y documentar la recuperacion manual antes de considerar prod.

La contencion automatica reduce el consumo de computo y acceso, pero no garantiza una factura maxima: SQL, almacenamiento, ACR, Key Vault, observabilidad y otros cargos pueden continuar. Azure evalua presupuestos con demora, por lo que el budget es una barrera de emergencia y no un limite financiero absoluto.

Criterio de cierre: documentacion publicada en GitHub, arquitectura aprobada y prerrequisitos de Sprint 1 identificados. La creacion de recursos Azure requiere autorizacion expresa.
