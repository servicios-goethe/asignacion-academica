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

## Incidencias y aprendizaje

| Problema | Causa | Resolucion |
| --- | --- | --- |
| El RFP suponia una nomina docente previa | Se interpreto el proceso actual como fuente maestra | El perfil docente nace de la autenticacion y declaracion anual |
| El stack propuesto no seguia el estandar institucional | El RFP proponia Vercel y Supabase | Se adopto .NET 10, React, Azure SQL y Container Apps |

## Pendiente

- Validar reglas funcionales abiertas.
- Obtener acceso y autorizacion para la suscripcion Azure.
- Crear infraestructura y esqueleto en Sprint 1.
