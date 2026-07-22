# Sprint 0 - Arranque funcional, tecnico y de dimensionamiento

## Objetivo

Dejar una base acordada y auditable, incluyendo la puerta G1, antes de crear servicios Azure o codigo funcional.

## Decisiones confirmadas

- Primer ciclo objetivo: 2027.
- No existe nomina docente inicial dentro del sistema.
- Cualquier cuenta `@goethe.edu.ar` puede autenticarse, identificarse y cargar disponibilidad para el ciclo abierto.
- El Director analiza las cargas, define la estructura y asigna docentes.
- Los roles administrativos no se deducen del dominio: requieren autorizacion explicita.
- Stack de aplicacion: .NET 10, React/TypeScript/Vite; servicios Azure sujetos al dimensionamiento G1, con Azure SQL y Container Apps como baseline.
- Dev y prod se despliegan en resource groups exclusivos del proyecto.

## Entregables

- Plan de implementacion corregido.
- Metodologia Azure incorporada al repositorio.
- DER conceptual y matriz inicial de permisos.
- Backlog trazable y plan de hitos.
- Checklist de acceso y aprovisionamiento Azure.
- `docs/DIMENSIONAMIENTO_Y_COSTOS.md` con perfil de uso, alternativas, costos y objetivos de rendimiento.
- Preguntas funcionales reducidas a decisiones que aun afectan el producto.
- Plan de validacion GPU014.

## Definicion de terminado

- [x] Repositorio GitHub y owner identificados.
- [x] Vision funcional corregida.
- [x] Stack y ambientes definidos.
- [x] Documentacion minima creada.
- [x] Resource groups dev/prod y presupuestos con alertas creados.
- [ ] Reglas abiertas validadas por Direccion.
- [x] Acceso Azure disponible para el alcance del proyecto.
- [ ] Supuestos y arquitectura de `DIMENSIONAMIENTO_Y_COSTOS.md` aprobados por el owner (G1).
- [ ] Autorizacion expresa para crear los servicios seleccionados.
- [ ] Sprint 1 refinado y aprobado.
