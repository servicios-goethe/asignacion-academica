# Formulario de disponibilidad docente

## Acceso e identidad

- El acceso es exclusivamente mediante Google SSO.
- Solo se aceptan cuentas del dominio `@goethe.edu.ar`.
- Email, nombre y apellido se obtienen de la cuenta Google autenticada.
- Los datos de identidad se muestran como solo lectura y el docente no puede modificarlos.
- Cualquier cuenta valida del dominio puede crear su perfil docente para el ciclo abierto, sin precarga previa.

El backend valida dominio, issuer, audiencia y claims. El frontend no puede alterar la identidad recibida por la sesion.

## Datos declarados

| Campo | Regla |
| --- | --- |
| Departamentos | Obligatorio, seleccion multiple desde catalogo activo |
| Horas frente a curso | Obligatorio, cantidad semanal de modulos de 45 minutos |
| Cargo | Obligatorio, seleccion unica desde catalogo activo |
| Disponibilidad | Obligatoria, seleccion positiva de bloques en los que puede trabajar |
| Observaciones | Opcional, texto con longitud maxima |

Los cargos actuales observados son Jefe de departamento, Tutor, Full time, Part time y Contratacion por hora. Son datos iniciales de referencia; el perfil `Admin` mantiene el catalogo y el `Director` utiliza sus valores activos en el ciclo.

## Grilla horaria

- Los bloques pertenecen al ciclo lectivo y son configurables.
- La referencia 2026 contiene una grilla para lunes, martes, jueves y viernes entre 7:45 y 16:30, y otra para miercoles entre 7:45 y 13:30.
- El docente marca unicamente bloques en los que tiene disponibilidad.
- El sistema calcula la cantidad de modulos seleccionados.
- Si la disponibilidad no alcanza las horas frente a curso mas 35%, muestra una advertencia visible y permite enviar igualmente.

La configuracion por ciclo evita hardcodear horarios y permite adaptar 2027 sin desplegar codigo.

## Flujo

1. El usuario inicia sesion con Google.
2. La aplicacion muestra identidad de solo lectura.
3. El docente selecciona departamentos y un cargo, informa sus modulos semanales y marca disponibilidad.
4. Puede guardar un borrador.
5. Al enviar, el sistema valida campos, calcula el 35% y muestra la advertencia si corresponde.
6. La presentacion queda `Enviada`; el Director puede observarla, aceptarla o reabrirla.

## Referencias visuales

- `docs/referencias/form-disponibilidad-actual-datos.png`
- `docs/referencias/form-disponibilidad-actual-horarios.png`

El formulario actual usa textos en espanol y aleman. Queda pendiente confirmar si el requisito bilingue aplica a todo el sistema o solamente al portal docente.

