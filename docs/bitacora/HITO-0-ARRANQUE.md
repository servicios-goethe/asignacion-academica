# Bitacora Hito 0 - Arranque

Fecha de inicio: 2026-07-14  
Estado: En curso

## Realizado

- Analisis del RFP original.
- Identificacion del error conceptual sobre la precarga docente.
- Definicion del autoalta por dominio para el ciclo 2027.
- Sustitucion del stack Next.js/Supabase por el stack Azure institucional.
- Preparacion de documentacion minima, plan por sprints, DER y backlog.
- Verificacion de acceso administrativo al repositorio GitHub.
- Autorizacion del owner para crear exclusivamente los resource groups dev y prod en `brazilsouth`.
- Creacion satisfactoria de `rg-goethe-asignacion-academica-dev` y `rg-goethe-asignacion-academica-prod` en la suscripcion `Treffpunkt Goethe`.
- Verificacion posterior: ambos resource groups se encuentran vacios y con estado `Succeeded`.
- Inicio de relevamiento de presupuestos Azure existentes para definir alertas 50/80/100% en dev y prod.
- Creacion de presupuestos mensuales de USD 50 en dev y prod, con alertas 50/80/100% a `servicios@goethe.edu.ar` y vigencia hasta el 2028-06-30.
- Definicion de referentes mediante perfiles: Director para validacion funcional, Admin para validacion tecnica y `servicios@goethe.edu.ar` como unico Superadmin fijo.
- Confirmacion de varios departamentos por docente y advertencia no bloqueante cuando la disponibilidad no alcanza el minimo del 35% adicional.
- Confirmacion de estructura anual configurable por el Director: fechas, cursos, modalidades, materias, horas de 45 minutos, divisiones y matriz de aplicabilidad/asignacion.
- Confirmacion de `Horas 45'` como cantidad semanal de modulos por materia, curso y division; la distribucion diaria queda en Untis.
- Confirmacion de Google SSO como fuente ineditable de email, nombre y apellido; un cargo por docente y horas frente a curso en modulos semanales de 45 minutos.
- Incorporacion al repositorio de las capturas del formulario 2026 como evidencia funcional.
- Confirmacion de interfaz completa bilingue espanol/aleman con selector y preferencia persistida por usuario.
- Confirmacion de bloques 2027 segun las opciones seleccionables del Forms actual: diez bloques lunes/martes/jueves/viernes y seis los miercoles, sin agregar un septimo bloque.
- Actualizacion de la metodologia Azure a version 2.0: consulta obligatoria de dimensionamiento, comparacion de arquitecturas, puerta de aprobacion G1 y medicion de costo/rendimiento a 7/30 dias.
- Reescritura de `SEGURIDAD_ISO27001.md` para separar requisitos del SGSI (clausulas 4 a 10), controles del Anexo A y responsabilidades tecnicas e institucionales.
- Preparacion de `DIMENSIONAMIENTO_Y_COSTOS.md` como propuesta G1: alternativa administrada de bajo costo, supuestos de carga, presupuesto, objetivos p95, RTO/RPO, umbrales y medicion posterior.

## Incidencias y aprendizaje

| Problema | Causa | Resolucion |
| --- | --- | --- |
| El RFP suponia una nomina docente previa | Se interpreto el proceso actual como fuente maestra | El perfil docente nace de la autenticacion y declaracion anual |
| El stack propuesto no seguia el estandar institucional | El RFP proponia Vercel y Supabase | Se adopto .NET 10, React, Azure SQL y Container Apps |
| Azure CLI rechazo el presupuesto por version de interfaz | El comando preview no envio el objeto `filter` requerido en alcance RG | Se utilizo la API estable `2023-11-01` y se versiono el cuerpo en `infra/budget-config.json` |
| El stack institucional fijaba algunos SKU antes de conocer la carga | La metodologia usaba una arquitectura de referencia como decision universal | Se separaron estandares de aplicacion y seguridad de la seleccion de servicios, que ahora exige dimensionamiento y comparacion de costos vigentes |
| La documentacion ISO 27001 mencionaba solo el Anexo A | Se habia registrado un recorte tecnico orientado a controles de aplicacion | Se incorporaron gobierno del SGSI, gestion de riesgos, responsabilidades, evidencia y limites de la declaracion de alineacion |
| No existia un dimensionamiento formal antes de Sprint 1 | El uso esperado era bajo pero no estaba cuantificado | Se documento una propuesta con margen de carga y aprobacion G1 pendiente antes de crear servicios Azure |

## Pendiente

- Validar reglas funcionales abiertas.
- Obtener acceso y autorizacion para la suscripcion Azure.
- Crear infraestructura y esqueleto en Sprint 1.
