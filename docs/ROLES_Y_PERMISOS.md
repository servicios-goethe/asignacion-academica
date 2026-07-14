# Roles y permisos

## Principio de acceso

El sistema no requiere precarga de docentes. Una cuenta Google valida de `@goethe.edu.ar` puede iniciar sesion y crear su participacion para el ciclo lectivo abierto. Esto no concede permisos administrativos.

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

El superadministrador inicial es `servicios@goethe.edu.ar`. La matriz se implementa en codigo y se cubre con tests; ocultar opciones en la interfaz no reemplaza la autorizacion del backend.

