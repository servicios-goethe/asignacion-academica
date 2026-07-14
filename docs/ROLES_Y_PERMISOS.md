# Roles y permisos

## Principio de acceso

El sistema no requiere precarga de docentes. Una cuenta Google valida de `@goethe.edu.ar` puede iniciar sesion y crear su participacion para el ciclo lectivo abierto. Esto no concede permisos administrativos.

## Referentes y perfiles

- Quien tenga perfil `Director` actua como referente funcional de Direccion y valida reglas, pantallas y resultados academicos.
- Quien tenga perfil `Admin` actua como referente tecnico y administra ciclos, catalogos, configuracion y soporte dentro de su alcance.
- `servicios@goethe.edu.ar` es el `Superadmin` fijo y conserva la capacidad de administrar los perfiles privilegiados.
- El sponsor es una responsabilidad organizacional de aprobacion y prioridad; no es un rol, permiso ni dato hardcodeado de la aplicacion.

Los perfiles `Director` y `Admin` se almacenan en base de datos y pueden asignarse o revocarse sin modificar codigo. Puede haber mas de una persona por perfil si la operacion futura lo requiere.

| Accion | Docente | Director | Admin tecnico | Superadmin |
| --- | ---: | ---: | ---: | ---: |
| Iniciar sesion con cuenta Goethe | Si | Si | Si | Si |
| Crear perfil propio del ciclo | Si | Si | Si | Si |
| Editar disponibilidad propia | Si | Si | Si | Si |
| Ver presentaciones de terceros | No | Si | Si | Si |
| Observar/reabrir presentaciones | No | Si | Si | Si |
| Gestionar estructura academica | No | Si | Si | Si |
| Realizar asignaciones | No | Si | Si | Si |
| Generar GPU014 | No | Si | Si | Si |
| Administrar ciclos y catalogos | No | No | Si | Si |
| Otorgar roles privilegiados | No | No | Limitado | Si |

El unico dato de identidad fijo en codigo es el email de Superadmin `servicios@goethe.edu.ar`. La matriz de capacidades de cada perfil se implementa en codigo y se cubre con tests; ocultar opciones en la interfaz no reemplaza la autorizacion del backend.
