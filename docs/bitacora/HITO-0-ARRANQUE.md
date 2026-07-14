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
- Elaboracion de propuesta de bloques 2027; queda pendiente confirmar el sexto y septimo bloque de los miercoles por inconsistencia en el formulario actual.

## Incidencias y aprendizaje

| Problema | Causa | Resolucion |
| --- | --- | --- |
| El RFP suponia una nomina docente previa | Se interpreto el proceso actual como fuente maestra | El perfil docente nace de la autenticacion y declaracion anual |
| El stack propuesto no seguia el estandar institucional | El RFP proponia Vercel y Supabase | Se adopto .NET 10, React, Azure SQL y Container Apps |
| Azure CLI rechazo el presupuesto por version de interfaz | El comando preview no envio el objeto `filter` requerido en alcance RG | Se utilizo la API estable `2023-11-01` y se versiono el cuerpo en `infra/budget-config.json` |

## Pendiente

- Validar reglas funcionales abiertas.
- Obtener acceso y autorizacion para la suscripcion Azure.
- Crear infraestructura y esqueleto en Sprint 1.
