# Asignacion Academica Goethe

Sistema para relevar disponibilidad docente, definir la estructura academica, asignar docentes y exportar la planificacion a Untis.

El primer ciclo objetivo es 2027. El sistema comienza sin una nomina precargada: cualquier usuario autenticado del dominio `@goethe.edu.ar` puede identificarse y presentar su disponibilidad para el ciclo abierto. Los permisos de Direccion y administracion se asignan explicitamente.

## Stack

- .NET 10 LTS, ASP.NET Core Minimal APIs y EF Core.
- React, TypeScript y Vite.
- Azure SQL Database.
- Azure Container Apps, Key Vault, Blob Storage, Application Insights y Log Analytics.
- Google OAuth para `goethe.edu.ar`.
- GitHub Actions con OIDC federado para Azure.

## Orden de lectura

1. `docs/METODOLOGIA_PROYECTOS_AZURE.md`
2. `docs/PLAN_MIGRACION_AZURE.md`
3. `plan-implementacion-sprints.md`
4. `docs/ROLES_Y_PERMISOS.md`
5. `docs/DER.md`
6. `sprint-0/README.md`

## Estado

Sprint 0 en curso. No se crean recursos Azure hasta contar con autorizacion expresa del owner.

## Repositorio

Owner tecnico: `servicios@goethe.edu.ar`.

