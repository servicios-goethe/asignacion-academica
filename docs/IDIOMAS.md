# Idiomas del sistema

## Alcance

Toda la aplicacion debe estar disponible en espanol y aleman. Esto incluye autenticacion, portal docente, panel de Direccion, administracion, validaciones, modales, estados, reportes y mensajes de error.

## Comportamiento

- El usuario puede cambiar idioma desde un selector visible en la interfaz.
- La preferencia se persiste en su perfil y se aplica en futuros ingresos.
- En el primer acceso se usa el idioma del navegador si es `es` o `de`; cualquier otro idioma inicia en espanol.
- El frontend usa `react-i18next` y claves de traduccion versionadas.
- Fechas y numeros respetan el locale seleccionado.
- Los datos ingresados por usuarios, nombres propios, materias y catalogos institucionales no se traducen automaticamente.
- Los textos institucionales configurables pueden tener variantes ES y DE cuando corresponda.
- El backend devuelve codigos de error estables; el frontend presenta el texto traducido.

Los tests deben detectar claves faltantes y verificar que ninguna pantalla principal dependa de textos hardcodeados.

