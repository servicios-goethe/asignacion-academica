# Preguntas abiertas de Sprint 0

Las preguntas sobre existencia de una nomina previa quedan cerradas: no existe y no se importara.

## Disponibilidad docente

1. Que campos debe declarar el docente ademas de nombre, cargo, departamento y horas frente a curso?
2. Puede una misma persona declarar varios cargos? La seleccion de varios departamentos ya esta confirmada.
3. Las horas declaradas requieren validacion posterior de Direccion o RRHH?
4. Cuales son los bloques horarios exactos para que los docentes declaren disponibilidad en 2027?
5. Que texto institucional debe explicar la advertencia del 35% al docente?

## Flujo y permisos

1. Asuntos Educativos requiere un rol independiente o alcanza con asignarle perfil `Director`?
2. Puede haber varios usuarios con perfil `Director` o `Admin` desde el primer lanzamiento?
3. Que acciones sensibles quedan reservadas exclusivamente al Superadmin?
4. El perfil `Director` puede observar, aceptar, reabrir, aprobar estructura y finalizar asignaciones, o alguna accion requiere un alcance adicional?

## Estructura y Untis

1. `Horas 45'` representa cantidad semanal de modulos o una distribucion por cada dia?
2. Como se modelan las excepciones NAT/SOC/ECO, IMA y grupos compartidos dentro de la matriz anual?
3. Una misma celda materia-division puede requerir mas de un docente?
4. De donde surgen los codigos Untis de docentes que se autoinscriben?
5. Que version de Untis y variante exacta de GPU014 se usa?
6. Las aulas forman parte del alcance de exportacion?

## Infraestructura

1. Cual es la suscripcion y tenant Azure autorizados?
2. Cual es el presupuesto mensual objetivo para dev y prod?
3. Que dominio o subdominios se usaran para cada ambiente?
4. Quien cargara secretos y configuracion OAuth en los portales?
