# Seguridad de la informacion e ISO/IEC 27001

Version 2.0 - 2026-07-22

## 1. Proposito y alcance

Este documento registra el enfoque de seguridad, los riesgos, los controles y
la evidencia del sistema **Planificacion y Asignacion Docente**. Comprende su
codigo, datos, identidades, integraciones, infraestructura Azure, despliegues y
operacion dentro de:

- `rg-goethe-asignacion-academica-dev`;
- `rg-goethe-asignacion-academica-prod`;
- repositorio `servicios-goethe/asignacion-academica`;
- proyecto OAuth y APIs de Google asociados exclusivamente al sistema.

La referencia es **ISO/IEC 27001:2022**, incluida su Enmienda 1:2024. ISO/IEC
27002:2022 se utiliza como guia para implementar controles e ISO/IEC 27005:2022
como apoyo para gestionar riesgos.

Fuentes oficiales:

- [ISO/IEC 27001:2022](https://www.iso.org/standard/27001)
- [ISO/IEC 27001:2022/Amd 1:2024](https://www.iso.org/standard/88435.html)
- [ISO/IEC 27002:2022](https://www.iso.org/standard/75652.html)
- [ISO/IEC 27005:2022](https://www.iso.org/standard/80585.html)

## 2. Declaracion de alcance y limites

Este documento **no certifica al sistema ni a la organizacion** y no sustituye
un Sistema de Gestion de Seguridad de la Informacion (SGSI). Una certificacion
ISO/IEC 27001 se otorga sobre el alcance definido de un SGSI organizacional,
no sobre una aplicacion aislada sin sus procesos de gobierno.

El proyecto:

- aplica gestion de riesgos de seguridad desde el diseno;
- implementa y prueba controles tecnicos y operativos aplicables;
- conserva evidencia auditable para el SGSI institucional;
- registra brechas, responsables, tratamientos y riesgo residual;
- aporta informacion para una futura Declaracion de Aplicabilidad (SoA).

Este documento **no es la SoA institucional**. La seleccion definitiva de
controles, las exclusiones y la aceptacion del riesgo residual corresponden al
responsable del SGSI y a Direccion dentro del alcance organizacional aprobado.

## 3. Modelo de alineacion

ISO/IEC 27001 no se reduce al Anexo A. La alineacion se trabaja en dos niveles:

1. **Clausulas 4 a 10**: requisitos obligatorios para gobernar, operar, evaluar
   y mejorar el SGSI. El proyecto produce evidencia, pero varios requisitos
   requieren decisiones y procesos institucionales.
2. **Anexo A**: controles de referencia que se consideran durante el
   tratamiento de riesgos. Se aplican cuando son necesarios; una exclusion
   debe justificarse y ningun control reemplaza el proceso de gestion.

### 3.1 Clausulas 4 a 10 y evidencia del proyecto

| Clausula | Aplicacion al proyecto | Evidencia o accion | Responsabilidad principal |
| --- | --- | --- | --- |
| 4. Contexto | Identificar alcance, partes interesadas, obligaciones y dependencias | Este documento, RFP, arquitectura, inventario y requisitos legales | Direccion / responsable SGSI |
| 5. Liderazgo | Definir ownership, politica y responsabilidades | `ROLES_Y_PERMISOS.md`, owner, referentes y aprobaciones | Direccion |
| 6. Planificacion | Evaluar y tratar riesgos; fijar objetivos medibles | Registro de riesgos, plan de tratamiento y criterios de aceptacion | Responsable SGSI + owners de riesgo |
| 7. Apoyo | Asegurar competencias, comunicacion y control documental | Runbooks, capacitacion, repositorio, revisiones y bitacora | Admin tecnico / RR. HH. / SGSI |
| 8. Operacion | Ejecutar controles y cambios conforme al tratamiento | CI/CD, UAT, backups, monitoreo, accesos y gestion de incidentes | Equipo tecnico y dueños del proceso |
| 9. Evaluacion | Medir eficacia, revisar y auditar | Metricas, alertas, pruebas, revisiones de acceso y auditoria interna | SGSI / auditoria / Direccion |
| 10. Mejora | Corregir no conformidades y prevenir recurrencias | Backlog, bitacora, post-incidentes y acciones correctivas | Owner de cada accion |

La organizacion debe confirmar el alcance del SGSI dentro del cual se incorpora
el sistema. Hasta entonces, la evidencia del proyecto se considera preparatoria
y no una declaracion de conformidad con las clausulas 4 a 10.

### 3.2 Mapeo preliminar al Anexo A

El mapeo siguiente agrupa controles relevantes, sin declarar aplicabilidad
definitiva ni reproducir el contenido de la norma.

| Grupo | Aplicacion prevista | Evidencia esperada | Estado |
| --- | --- | --- | --- |
| Organizacionales | Politicas, roles, inventario, clasificacion, acceso, nube, incidentes, continuidad, cumplimiento y procedimientos | Documentacion aprobada, matriz de permisos, contratos, runbooks, revisiones y tickets | En curso |
| Personas | Terminos de uso, concientizacion, trabajo remoto y reporte de eventos | Politicas institucionales, capacitacion y canal de incidentes | Requiere integracion institucional |
| Fisicos | Proteccion de instalaciones y equipos desde los que se administra el servicio | Controles del colegio y responsabilidades heredadas del proveedor cloud | Fuera del codigo; validar con SGSI |
| Tecnologicos | Identidad, privilegios, codigo, autenticacion, configuracion, vulnerabilidades, backups, logging, redes, cifrado, desarrollo y pruebas seguras | Codigo, tests, pipelines, configuracion Azure, logs, reportes y pruebas de restore | En curso |

Controles de otros marcos, obligaciones legales o medidas adicionales pueden
ser necesarios aunque no figuren en el Anexo A. La evaluacion se basa en el
riesgo y no en completar una lista de verificacion.

## 4. Responsabilidades

| Rol | Responsabilidad de seguridad |
| --- | --- |
| Direccion / sponsor | Aprobar prioridades, recursos, alcance y riesgos que excedan la autoridad operativa |
| Responsable del SGSI | Mantener metodologia de riesgos, SoA institucional, auditorias y mejora del SGSI |
| Director funcional | Validar proceso, acceso funcional, integridad de asignaciones y necesidades de disponibilidad |
| Admin tecnico | Operar configuracion, monitoreo, incidentes, backups y evidencia dentro de su alcance |
| Superadmin `servicios@goethe.edu.ar` | Administrar accesos privilegiados y coordinar decisiones tecnicas y de riesgo |
| Equipo de desarrollo | Aplicar desarrollo seguro, tests, correcciones y trazabilidad de cambios |
| Usuarios | Proteger su cuenta, respetar el uso autorizado y reportar incidentes |
| Microsoft y Google | Cumplir los controles del proveedor segun contratos y modelo de responsabilidad compartida |

Ningun desarrollador puede aceptar unilateralmente un riesgo institucional.
Cada riesgo debe tener un owner con autoridad suficiente y fecha de revision.

## 5. Metodologia de riesgos

### 5.1 Proceso

1. Identificar activo, proceso, datos y responsable.
2. Identificar amenaza, vulnerabilidad, escenario e impacto posible.
3. Valorar probabilidad e impacto de 1 a 5 antes de controles.
4. Determinar el nivel inherente: `Probabilidad x Impacto`.
5. Elegir tratamiento: mitigar, evitar, transferir o aceptar.
6. Definir controles, owner, fecha objetivo y evidencia verificable.
7. Estimar riesgo residual y obtener aceptacion cuando corresponda.
8. Revisar despues de cambios relevantes, incidentes o en la cadencia acordada.

### 5.2 Criterio inicial

| Puntaje | Nivel | Tratamiento |
| ---: | --- | --- |
| 1-4 | Bajo | Gestion operativa y seguimiento |
| 5-9 | Medio | Tratamiento planificado y owner asignado |
| 10-16 | Alto | Mitigacion antes de produccion o aceptacion formal de Direccion |
| 17-25 | Critico | No desplegar ni continuar la operacion sin reducir o aceptar formalmente el riesgo |

Los valores son una base para el proyecto. El SGSI institucional puede
reemplazarlos por su metodologia corporativa.

## 6. Linea base de seguridad del sistema

### 6.1 Identidad y acceso

- Google SSO restringido a cuentas `@goethe.edu.ar` y MFA institucional.
- Email, nombre y apellido provienen de Google y no son editables localmente.
- Autorizacion server-side en cada endpoint; la UI no constituye un control.
- Minimo privilegio, segregacion de funciones y revision periodica de roles.
- `servicios@goethe.edu.ar` es el unico Superadmin fijo.
- Accesos privilegiados, cambios de rol y lecturas sensibles quedan auditados.

### 6.2 Aplicacion y desarrollo

- Validacion allowlist, limites de tamano y constraints de dominio en la base.
- Dependencias, imagenes y vulnerabilidades se revisan en CI/CD.
- Secretos exclusivamente en Key Vault; nunca en codigo, chat o artifacts.
- Build y tests antes de dev; UAT en dev; prod manual con SHA aprobado.
- Dev y prod separados. Produccion usa la misma imagen validada en dev.
- Cambios de esquema mediante migraciones versionadas y revisadas.

### 6.3 Datos, privacidad y trazabilidad

- Clasificar datos y definir minima recopilacion, finalidad y retencion.
- Cifrado en transito y en reposo mediante capacidades administradas.
- Archivos en Blob privado; acceso breve y auditado mediante identidad
  administrada o mecanismo equivalente aprobado.
- Auditoria append-only en la misma transaccion que la accion de negocio.
- Logs sin secretos ni datos personales innecesarios.
- Eliminacion, exportacion y retencion sujetas a obligaciones institucionales y
  legales documentadas.

### 6.4 Infraestructura y operacion

- Operar solo dentro de los RG exclusivos del proyecto.
- Identidades administradas y RBAC de minimo privilegio para servicios Azure.
- Configuracion segura, parches administrados y exposicion de red justificada.
- Presupuestos y alertas no reemplazan alertas de disponibilidad o seguridad.
- Backups con retencion definida y pruebas periodicas de restauracion.
- Metricas, logs y alertas con retencion y responsables establecidos.
- Runbooks de incidente, continuidad, escalado, rollback y recuperacion.

### 6.5 Responsabilidad compartida

El uso de Azure o Google no transfiere toda la seguridad al proveedor. Antes de
produccion se documenta por servicio quien responde por identidad, datos,
configuracion, red, cifrado, backups, logs, vulnerabilidades, disponibilidad y
eliminacion. Las certificaciones del proveedor son evidencia de sus controles,
no certifican automaticamente la configuracion ni el proceso Goethe.

## 7. Evidencia minima

| Evidencia | Ubicacion | Frecuencia |
| --- | --- | --- |
| Riesgos, tratamientos y brechas | Este documento y backlog | En cada cambio relevante y trimestral |
| Roles y permisos | `docs/ROLES_Y_PERMISOS.md` + tests | Antes de prod y trimestral |
| Arquitectura y datos | `docs/DER.md` y plan Azure | En cada cambio de arquitectura/esquema |
| Cambios y aprobaciones | GitHub, Actions y bitacora | Por despliegue |
| Eventos de negocio | Tabla `Auditoria` | Continuo |
| Logs y alertas tecnicas | Application Insights / Log Analytics | Continuo; revision operativa definida |
| Backup y restore | Azure + acta de prueba | Antes de prod y luego segun RPO/RTO |
| UAT y seguridad | `docs/UAT_CHECKLIST.md` | Por release mayor |
| Incidentes y acciones correctivas | Registro institucional + backlog | Por incidente |
| Costos y capacidad | `DIMENSIONAMIENTO_Y_COSTOS.md` | 7/30 dias, despues de picos y trimestral |

La evidencia debe indicar fecha, ambiente, responsable, resultado y referencia
al artifact o ticket. No se almacenan secretos dentro de la evidencia.

## 8. Registro de riesgos, brechas y decisiones

Estados permitidos: `Pendiente`, `En tratamiento`, `Mitigado`, `Aceptado` o
`Transferido`. Solo el owner autorizado puede marcar un riesgo como aceptado.

| Id | Brecha o riesgo | Nivel preliminar | Tratamiento previsto | Owner | Evidencia de cierre | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| SEC-001 | Proyecto OAuth Google aun no creado | Alto | Crear proyecto exclusivo, restringir dominio y registrar redirects dev/prod | Admin tecnico | Configuracion revisada + login probado | Pendiente |
| SEC-002 | Dev desplegado; prod y controles productivos aun pendientes | Medio | Mantener ingress interno, validar dev y promover solo despues de SSO/UAT | Admin tecnico | IaC/configuracion + smoke test + UAT | En tratamiento |
| SEC-003 | Matriz de permisos definida pero no implementada ni probada | Alto | Autorizacion backend y tests positivos/negativos por rol | Equipo de desarrollo | Suite de autorizacion verde | Pendiente |
| SEC-004 | Especificacion GPU014 pendiente de validacion | Medio | Validar exportacion en Untis con archivo controlado sin datos sensibles | Director funcional | Acta de prueba y fixture aprobado | Pendiente |
| SEC-005 | Alcance del SGSI y SoA institucional no vinculados al proyecto | Medio | Confirmar alcance, owner de riesgos y controles heredados | Direccion / SGSI | Acta o referencia institucional | Pendiente |
| SEC-006 | Clasificacion, base legal y retencion de datos no formalizadas | Alto | Inventariar datos y aprobar finalidad, acceso, retencion y eliminacion | Direccion / SGSI | Matriz de datos aprobada | Pendiente |
| SEC-007 | RTO, RPO y estrategia de continuidad sin aprobar | Alto | Definir objetivos, backups, redundancia y runbook segun impacto | Direccion + Admin tecnico | Objetivos aprobados + prueba de restore | Pendiente |
| SEC-008 | Gestion de incidentes y canales de escalamiento no documentados | Alto | Integrar el sistema al proceso institucional y ejecutar ejercicio | SGSI + Admin tecnico | Runbook y simulacro registrado | Pendiente |
| SEC-009 | Revision de proveedores y responsabilidades compartidas pendiente | Medio | Documentar servicios Azure/Google, contratos, dependencias y owners | Admin tecnico / SGSI | Matriz de responsabilidad aprobada | Pendiente |
| SEC-010 | Pruebas de seguridad y vulnerabilidades aun no ejecutadas | Alto | SAST, dependencias, imagen, DAST y correccion antes de prod | Equipo de desarrollo | Reportes sin hallazgos altos/criticos abiertos | Pendiente |

## 9. Condiciones de seguridad para produccion

No se habilita produccion hasta verificar como minimo:

- [ ] Riesgos altos y criticos mitigados o aceptados formalmente.
- [ ] OAuth, dominio, MFA, sesiones y cierre de sesion probados.
- [ ] Matriz de autorizacion cubierta por tests server-side.
- [ ] Secretos en Key Vault y permisos revisados.
- [ ] Datos clasificados, retencion y acceso aprobados.
- [ ] Auditoria, logging, monitoreo y alertas verificados.
- [ ] Dependencias, codigo e imagen sin hallazgos altos/criticos abiertos.
- [ ] Backup y restauracion probados contra RPO/RTO acordados.
- [ ] Runbooks de incidente, rollback y continuidad disponibles.
- [ ] UAT por rol y aprobacion de Direccion registradas.
- [ ] Responsabilidad compartida de Azure/Google documentada.
- [ ] Evidencia conservada sin credenciales ni datos sensibles innecesarios.

## 10. Revision y mejora

Este documento se revisa:

- antes del primer despliegue productivo;
- ante cambios de arquitectura, identidad, datos o proveedores;
- despues de un incidente o prueba de recuperacion fallida;
- cuando cambien obligaciones legales o el alcance del SGSI;
- como minimo trimestralmente durante operacion activa.

Cada revision debe actualizar riesgos, estado de controles, evidencia, owner y
fecha objetivo. Las lecciones se registran en la bitacora y las acciones en
`BACKLOG_AJUSTES.md`; cerrar una tarea tecnica no implica aceptar
automaticamente su riesgo residual.
