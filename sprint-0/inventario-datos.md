# Inventario de datos y configuracion

No se migran disponibilidades ni asignaciones historicas. La nomina docente 2027 se construye con las personas que ingresan y completan su perfil.

| Elemento | Tipo | Origen | Estado | Uso |
| --- | --- | --- | --- | --- |
| Identidad docente | Dato nuevo | Google OAuth + declaracion del usuario | Definido | Autoalta del ciclo |
| Email, nombre y apellido | Identidad | Google SSO | Definido | Solo lectura en perfil 2027 |
| Cargo | Dato nuevo | Un valor declarado desde catalogo | Definido | Perfil 2027 |
| Departamentos del docente | Relacion multiple | Seleccionados por el docente desde catalogo | Definido | Perfil 2027 y filtros |
| Horas frente a curso | Dato nuevo | Modulos semanales de 45 minutos declarados por el docente | Definido | Regla 35% y asignacion |
| Bloques disponibles | Dato nuevo | Declarado por el docente | Por validar | Analisis y conflictos |
| Departamentos | Catalogo | Direccion | Pendiente | Selector multiple y filtros |
| Cargos | Catalogo | Direccion | Pendiente | Selector y reglas |
| Bloques horarios | Catalogo por ciclo | Direccion | Propuesta preparada | Grilla 2027; pendiente confirmar ultimo tramo del miercoles |
| Cargos | Catalogo | Admin | Referencia disponible | Seleccion unica |
| Niveles, divisiones y modalidades | Catalogo | Direccion | Pendiente | Estructura academica |
| Materias y talleres | Catalogo | Direccion/Untis | Pendiente | Estructura y exportacion |
| Codigos Untis | Catalogo tecnico | Untis/Direccion | Pendiente | GPU014 |
| Archivo GPU014 de referencia | Evidencia tecnica | Referente Untis | Pendiente | Validacion del exportador |
| Scripts actuales | Referencia de reglas | RFP/planillas existentes | Parcial | Matriz de pruebas, no migracion |

Los datos historicos pueden usarse como casos de prueba y referencia operativa, pero no como carga inicial productiva.
