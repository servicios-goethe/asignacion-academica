# Operacion Azure

Actualizado: 2026-07-23. Sprint 1 dev aprovisionado; prod permanece sin
recursos hasta completar Google SSO y validacion funcional.

## Suscripcion y alcance autorizado

- Suscripcion activa: `Treffpunkt Goethe`.
- Region: `brazilsouth`.
- Resource group dev: `rg-goethe-asignacion-academica-dev`.
- Resource group prod: `rg-goethe-asignacion-academica-prod`.
- Fecha de creacion: 2026-07-14.
- Estado verificado: `Succeeded`, sin recursos internos.

Toda operacion del proyecto debe quedar limitada a estos dos resource groups. La creacion de servicios internos requiere una autorizacion posterior.

## Presupuestos

| Ambiente | Presupuesto | Importe | Vigencia | Alertas |
| --- | --- | ---: | --- | --- |
| Dev | `budget-goethe-asignacion-academica-dev` | USD 50/mes | 2026-07-01 a 2028-06-30 | 50%, 80% y 100% a `servicios@goethe.edu.ar` |
| Prod | `budget-goethe-asignacion-academica-prod` | USD 50/mes | 2026-07-01 a 2028-06-30 | 50%, 80% y 100% a `servicios@goethe.edu.ar` |

Los presupuestos generan notificaciones sobre consumo real. No constituyen topes de gasto ni detienen recursos automaticamente. La configuracion declarativa se conserva en `infra/budget-config.json`.

## Principios

- Dev y prod viven en resource groups separados.
- No se modifica ningun recurso fuera de los RG del proyecto.
- Los secretos se cargan en Key Vault por portal.
- `main` despliega automaticamente a dev despues de build y tests.
- Produccion requiere workflow manual, SHA probado y confirmacion `DESPLEGAR`.
- Prod consume exactamente la imagen validada en dev.

## Inventario dev Sprint 1

| Recurso | Nombre | Estado / criterio |
| --- | --- | --- |
| Azure SQL Server | `sql-goethe-asigacad-dev` | `Succeeded`; administrador Entra; Entra-only activo |
| Azure SQL Database | `sqldb-goethe-asigacad-dev` | `Succeeded`; Basic inicial, sujeto a revision por oferta gratuita |
| Storage | `stgoetheasigacaddev` | `Succeeded`; HTTPS, TLS 1.2, Blob privado |
| Key Vault | `kv-goethe-asigacad-dev` | `Succeeded`; RBAC, soft delete |
| ACR compartido | `acrgoetheasigacad` | `Succeeded`; Basic, admin disabled |
| Log Analytics | `log-goethe-asigacad-dev` | `Succeeded`; retencion 30 dias |
| Application Insights | `appi-goethe-asigacad-dev` | `Succeeded`; workspace integrado |
| Container Apps Environment | `cae-goethe-asigacad-dev` | `Succeeded`; logs a Log Analytics |
| Container App | `app-goethe-asigacad-dev` | `Healthy`; imagen `5087af8`, replicas 0-2 |
| Identidad administrada | `id-goethe-asigacad-dev` | `AcrPull` sobre el ACR |

La Container App tiene ingress interno (`external=false`) porque Google SSO y
la autorizacion server-side todavia no estan implementados. No se publica una
URL externa sin autenticacion.

## Despliegue actual

- Imagen: `acrgoetheasigacad.azurecr.io/asignacion-academica:5087af8`.
- Baseline aplicado mediante `infra/main.bicep` y
  `infra/container-app.bicep`.
- Build de imagen ejecutado server-side con `az acr build` (run `cq1`).
- El admin SQL tecnico temporal no queda en el repositorio y la autenticacion
  SQL queda restringida a Entra-only.
- OAuth Google requiere crear un proyecto GCP propio y registrar las URI de
  redirect dev/prod antes de habilitar ingress externo.

## Checklist de corte preliminar

- [ ] UAT aprobado por rol.
- [ ] Backup y restore probados.
- [ ] Alertas y observabilidad operativas.
- [ ] Redirect URI productiva validada.
- [ ] SHA candidato identificado.
- [ ] Promocion manual autorizada.
- [ ] `/healthz` y version desplegada verificados.
