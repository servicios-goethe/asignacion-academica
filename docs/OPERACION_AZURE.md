# Operacion Azure

Documento inicial. Se completara durante Sprint 1 con identificadores reales y procedimientos probados.

## Suscripcion y alcance autorizado

- Suscripcion activa: `Treffpunkt Goethe`.
- Region: `brazilsouth`.
- Resource group dev: `rg-goethe-asignacion-academica-dev`.
- Resource group prod: `rg-goethe-asignacion-academica-prod`.
- Fecha de creacion: 2026-07-14.
- Estado verificado: `Succeeded`, sin recursos internos.

Toda operacion del proyecto debe quedar limitada a estos dos resource groups. La creacion de servicios internos requiere una autorizacion posterior.

## Principios

- Dev y prod viven en resource groups separados.
- No se modifica ningun recurso fuera de los RG del proyecto.
- Los secretos se cargan en Key Vault por portal.
- `main` despliega automaticamente a dev despues de build y tests.
- Produccion requiere workflow manual, SHA probado y confirmacion `DESPLEGAR`.
- Prod consume exactamente la imagen validada en dev.

## Checklist de corte preliminar

- [ ] UAT aprobado por rol.
- [ ] Backup y restore probados.
- [ ] Alertas y observabilidad operativas.
- [ ] Redirect URI productiva validada.
- [ ] SHA candidato identificado.
- [ ] Promocion manual autorizada.
- [ ] `/healthz` y version desplegada verificados.
