# Checklist Sprint 0

## Repositorio y gobierno

- [x] Confirmar repositorio `servicios-goethe/asignacion-academica`.
- [x] Confirmar owner tecnico `servicios@goethe.edu.ar`.
- [x] Incorporar metodologia Azure institucional.
- [x] Crear backlog, plan de mejoras y bitacora.
- [x] Definir al perfil `Director` como referente funcional de Direccion.
- [x] Definir al perfil `Admin` como referente tecnico.
- [x] Confirmar `servicios@goethe.edu.ar` como unico Superadmin fijo.
- [ ] Identificar al sponsor organizacional para prioridades y aprobacion ejecutiva; no afecta permisos del sistema.

## Alcance 2027

- [x] Confirmar que el ciclo inicia sin nomina docente precargada.
- [x] Confirmar acceso para cualquier cuenta `@goethe.edu.ar`.
- [x] Separar autoalta docente de roles administrativos.
- [x] Confirmar que apertura y cierre son configurables por ciclo desde el ABM del Director.
- [ ] Confirmar regla y permisos de reapertura de disponibilidad.
- [x] Confirmar que una persona puede pertenecer a varios departamentos.
- [ ] Confirmar si una persona puede declarar mas de un cargo.
- [ ] Confirmar campos obligatorios del perfil declarado.

## Reglas funcionales

- [x] Definir el 35% como advertencia visible y no bloqueante.
- [ ] Confirmar bloques horarios 2027 y excepcion de los miercoles.
- [x] Confirmar que cursos, divisiones, modalidades, materias, horas y aplicabilidad varian por ciclo y son administrados por el Director.
- [ ] Confirmar que `Horas 45'` representa modulos semanales y no una distribucion por dia.
- [ ] Confirmar reglas particulares para NAT/SOC/ECO, IMA y grupos compartidos.
- [ ] Confirmar reglas de talleres y redondeos.
- [ ] Confirmar estados y responsables de aprobacion/reapertura.

## Untis

- [ ] Obtener version de Untis y especificacion GPU014.
- [ ] Obtener un GPU014 real valido como referencia tecnica.
- [ ] Definir origen de codigos de docentes, materias, grupos y aulas.
- [ ] Confirmar si el sistema exporta aulas.
- [ ] Importar un archivo minimo generado en un entorno seguro de Untis.

## Azure y Google

- [x] Confirmar suscripcion y tenant Azure.
- [x] Confirmar presupuesto mensual esperado: USD 50 por ambiente.
- [x] Configurar alertas de consumo real al 50/80/100% para dev y prod.
- [ ] Confirmar disponibilidad de `brazilsouth` para los servicios elegidos.
- [x] Autorizar creacion de `rg-goethe-asignacion-academica-dev` y `-prod`.
- [x] Crear y verificar ambos resource groups en `brazilsouth`.
- [ ] Configurar OIDC de GitHub sin secretos persistentes.
- [ ] Crear un proyecto Google OAuth exclusivo y registrar redirects dev/prod.
- [ ] Cargar secretos exclusivamente en Key Vault por portal.

## Cierre

- [ ] Resolver o aceptar explicitamente los riesgos pendientes.
- [ ] Aprobar criterios de aceptacion del Sprint 1.
- [ ] Autorizar inicio del aprovisionamiento Azure.
