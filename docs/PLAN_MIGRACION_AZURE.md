# Plan de construccion y despliegue Azure

Aunque el sistema es nuevo y no una migracion, este documento conserva el nombre estandar de la metodologia Goethe.

## Hito 0 - Definicion

Estado: En curso; dimensionamiento G1 documentado y pendiente de aprobacion del owner.

- Corregir la vision funcional del ciclo 2027.
- Definir roles, reglas academicas y contrato GPU014.
- Preparar repositorio, backlog, DER y documentacion minima.
- Confirmar suscripcion, tenant, presupuesto y nombres de recursos.
- Esperar autorizacion antes de crear recursos Azure.
- Resource groups dev y prod creados en `brazilsouth` el 2026-07-14; ambos quedaron vacios y listos para el Hito 1.
- Presupuestos mensuales de USD 50 por ambiente creados hasta el 2028-06-30, con alertas 50/80/100% a `servicios@goethe.edu.ar`.
- `docs/DIMENSIONAMIENTO_Y_COSTOS.md` preparado con supuestos de uso, alternativas, costos orientativos, objetivos de rendimiento y umbrales de escalado.

## Hito 1 - Infraestructura y esqueleto

Inicio condicionado a la aprobacion G1 y a la verificacion final de precios y
SKU en la suscripcion. El primer bloque de trabajo puede ser local y no genera
consumo Azure.

- Crear exclusivamente `rg-goethe-asignacion-academica-dev` y `rg-goethe-asignacion-academica-prod` en `brazilsouth`.
- Configurar presupuestos y alertas 50/80/100%.
- Crear solamente los servicios seleccionados en `DIMENSIONAMIENTO_Y_COSTOS.md`: SQL, Key Vault, Storage, Log Analytics, Application Insights, Container Apps Environment y Container App, con SKU y replicas aprobados.
- Configurar identidad administrada y OIDC de GitHub Actions.
- Crear solucion .NET 10 + React/Vite, `/healthz`, tests y despliegue dev.
- Crear proyecto OAuth de Google propio y configurar redirect URIs.

## Hito 2 - Identidad y modelo base

- Google OAuth para cualquier cuenta `@goethe.edu.ar`.
- Autoalta de participante docente en el ciclo abierto.
- Roles administrativos asignados explicitamente.
- Ciclos lectivos, perfiles, presentaciones y auditoria.

## Hito 3 - Disponibilidad docente

- Perfil declarado, grilla horaria, borrador y envio.
- Estados, observaciones, reapertura y panel de Direccion.
- Pruebas funcionales y de permisos en dev.

## Hito 4 - Estructura y asignacion

- Catalogos y estructura academica.
- Matriz de asignacion, calculos y conflictos.
- Auditoria transaccional y pruebas de dominio.

## Hito 5 - Untis y reportes

- GPU014, prevalidacion, historial y reportes.
- Prueba de importacion en Untis con casos controlados.

## Hito 6 - UAT y produccion

- UAT por rol en dev.
- Pruebas de seguridad, rendimiento, backup y restore.
- Gate manual con SHA y confirmacion `DESPLEGAR`.
- Verificacion de produccion y documentacion operativa.

## Nombres previstos

| Recurso | Dev | Prod |
| --- | --- | --- |
| Resource group | `rg-goethe-asignacion-academica-dev` | `rg-goethe-asignacion-academica-prod` |
| Key Vault | `kv-goethe-asigacad-dev` | `kv-goethe-asigacad-prod` |
| Container App | `app-goethe-asigacad-dev` | `app-goethe-asigacad-prod` |
| SQL Server | `sql-goethe-asigacad-dev` | `sql-goethe-asigacad-prod` |
| Base | `sqldb-goethe-asigacad` | `sqldb-goethe-asigacad` |

Los nombres definitivos se validaran por disponibilidad global antes del aprovisionamiento.
