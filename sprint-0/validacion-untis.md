# Validacion Untis / GPU014

## Objetivo

Confirmar temprano que el sistema puede generar un archivo GPU014 importable por la version real de Untis usada por el colegio.

## Insumos necesarios

- Archivo GPU014 real usado previamente.
- Manual o especificacion de importacion de Untis.
- Codigos oficiales de docentes.
- Codigos oficiales de materias.
- Codigos oficiales de divisiones/grupos.
- Confirmacion sobre aulas.

## Casos minimos de prueba

1. Una materia simple asignada a una division.
2. Una materia comun replicada en varias divisiones.
3. Una materia de modalidad aplicada solo a divisiones especificas.
4. Un taller de 2 horas catedra.
5. Una materia compartida entre dos divisiones, si aplica.
6. Un caso con docente repetido en varias asignaciones.

## Procedimiento

1. Tomar 3 a 5 asignaciones reales de una planilla actual.
2. Mapear docentes, materias y grupos a codigos Untis.
3. Generar un GPU014 minimo.
4. Importar en Untis en entorno de prueba o copia segura.
5. Registrar errores y advertencias.
6. Ajustar formato y volver a probar.
7. Documentar reglas finales de generacion.

## Resultado esperado

- Archivo GPU014 importado sin errores bloqueantes.
- Lista clara de campos obligatorios.
- Mapeo validado entre entidades del sistema y codigos Untis.
- Decisiones documentadas para aulas, grupos partidos y materias compartidas.

## Estado

Pendiente de obtener muestra real y ambiente de validacion.
