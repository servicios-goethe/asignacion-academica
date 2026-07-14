# Modelo de estructura academica anual

## Principio

La estructura academica no se hardcodea ni se considera un catalogo inmutable. El perfil `Director` la construye para cada ciclo lectivo mediante un ABM simple en el frontend.

Los catalogos reutilizables pueden conservar nombres de materias, modalidades y cursos, pero su combinacion, divisiones, aplicabilidad y horas catedra pertenecen al ciclo. El ciclo 2027 puede comenzar vacio.

## Configuracion del ciclo

El Director administra:

- Nombre y anio del ciclo lectivo.
- Fecha y hora de apertura de disponibilidad.
- Fecha y hora de cierre de disponibilidad.
- Cursos o anos, por ejemplo `1ES`.
- Divisiones del ciclo, por ejemplo `A - IMA1`, `B - IMA2`, `C - IMA3`, `D - IMA4` e `IMA5`.
- Modalidades.
- Materias.
- Cantidad de horas catedra de 45 minutos.
- Aplicabilidad de cada materia a cada division.

Las fechas y la estructura son datos editables con permisos; no quedan fijas en codigo.

## Matriz de trabajo

La interfaz replica el modelo mental de la planilla actual:

| Curso | Modalidad | Materia | Horas 45' | Division A | Division B | Division C |
| --- | --- | --- | ---: | --- | --- | --- |
| 1ES | Comun | Biologia | 3 | Pendiente | Pendiente | No aplica |

- `No aplica`: no existe espacio curricular para esa combinacion; la celda se muestra deshabilitada.
- `Pendiente`: existe el espacio curricular pero no tiene docente asignado.
- `Asignado`: existe el espacio y muestra el docente o los docentes vinculados.

El Director puede agregar, editar, desactivar y ordenar filas; crear divisiones; y activar o desactivar celdas. Las bajas son logicas y quedan auditadas.

## Horas

La interpretacion actual de `Horas 45'` es cantidad semanal de modulos de 45 minutos. Es la carga predeterminada de la fila para todas las divisiones aplicables. Cada celda puede admitir una carga diferente cuando una division sea una excepcion, conservando la carga de la fila como valor por defecto.

La matriz define carga academica semanal, no el dia y hora concretos de dictado. La calendarizacion corresponde a Untis. Esta interpretacion debe confirmarse con Direccion; si se requiere distribuir horas por dia desde este sistema, sera una dimension funcional adicional.

## Separacion entre estructura y asignacion

1. El Director configura y aprueba la estructura anual.
2. El sistema crea un espacio curricular por cada celda aplicable.
3. En la etapa de asignacion, el Director completa las celdas pendientes con docentes que ya declararon disponibilidad.
4. La estructura aprobada y las asignaciones alimentan la exportacion GPU014.
