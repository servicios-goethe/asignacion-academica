# Asignacion Academica Goethe

Sistema para relevar disponibilidad docente, definir la estructura academica, asignar docentes y exportar la planificacion a Untis.

El primer ciclo objetivo es 2027. El sistema comienza sin una nomina precargada: cualquier usuario autenticado del dominio `@goethe.edu.ar` puede identificarse y presentar su disponibilidad para el ciclo abierto. Los permisos de Direccion y administracion se asignan explicitamente.

## Stack

- .NET 10 LTS, ASP.NET Core Minimal APIs y EF Core.
- React, TypeScript y Vite.
- `react-i18next` para interfaz completa en espanol y aleman.
- Azure SQL Database.
- Azure Container Apps, Key Vault, Blob Storage, Application Insights y Log Analytics.
- Google OAuth para `goethe.edu.ar`.
- GitHub Actions con OIDC federado para Azure.

## Orden de lectura

1. `docs/METODOLOGIA_PROYECTOS_AZURE.md`
2. `docs/PLAN_MIGRACION_AZURE.md`
3. `docs/DIMENSIONAMIENTO_Y_COSTOS.md`
4. `plan-implementacion-sprints.md`
5. `docs/ROLES_Y_PERMISOS.md`
6. `docs/DER.md`
7. `docs/FORMULARIO_DISPONIBILIDAD.md`
8. `docs/IDIOMAS.md`
9. `docs/BLOQUES_HORARIOS_2027.md`
10. `sprint-0/README.md`

## Estado

Sprint 1 iniciado: esqueleto local, health check, pantalla bilingue y CI en construccion. G1 aprobado por el owner el 2026-07-22; el aprovisionamiento verifica precios y SKU antes de crear servicios.

## Ejecucion local

API:

```powershell
dotnet run --project src\AsignacionAcademica.Api\AsignacionAcademica.Api.csproj --launch-profile http
```

Frontend:

```powershell
cd web
npm.cmd install
npm.cmd run dev
```

La API queda en `http://localhost:5050` y Vite en `http://localhost:5173`.
El frontend permite alternar ES/DE y muestra el estado de `/healthz`.

## Repositorio

Owner tecnico: `servicios@goethe.edu.ar`.
