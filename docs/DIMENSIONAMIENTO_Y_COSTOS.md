# Dimensionamiento y costos - Asignacion Academica

Version 1.1 - 2026-07-22
Estado: G1 aprobado por el owner

## 1. Decision ejecutiva

Para el ciclo 2027 se propone una arquitectura administrada de bajo costo,
separada por ambiente y compatible con el stack institucional:

- Azure Container Apps Consumption para la aplicacion .NET + React.
- Azure SQL Database: oferta gratuita para dev si esta habilitada en la
  suscripcion; tier Basic provisionado para prod como punto de partida.
- Azure Blob Storage Standard LRS para archivos y claves de Data Protection.
- Un Azure Container Registry Basic compartido por dev y prod del proyecto.
- Key Vault separado por ambiente.
- Application Insights + Log Analytics con muestreo, limites y retencion
  acotada.
- Sin NAT Gateway, Application Gateway, Front Door, Redis, APIM, endpoints
  privados ni Kubernetes en la primera version, salvo que el analisis de
  seguridad o las pruebas demuestren una necesidad.

La seleccion queda condicionada a la prueba de carga de Sprint 1 y a la
verificacion de disponibilidad y precios en la suscripcion `Treffpunkt
Goethe`. Ningun tier se considera definitivo.

## 2. Perfil de uso

No existen mediciones historicas porque el sistema comienza vacio para el
ciclo 2027. Los siguientes valores son **supuestos de dimensionamiento**
confirmados por el owner para la primera etapa; se reemplazaran por metricas
reales despues del despliegue.

| Variable | Supuesto inicial | Margen para prueba | Fuente / observacion |
| --- | ---: | ---: | --- |
| Docentes potenciales | 80 | 80 | Primera etapa confirmada por el owner |
| Usuarios administrativos | 10 | 15 | Director, Admin y soporte |
| Usuarios activos mensuales | 80 | 95 | Alta concentrada al inicio del ciclo |
| Concurrencia normal | 5 | 15 | Uso individual durante jornada |
| Concurrencia pico esperada | 10 | 10 | Uso normal durante apertura/cierre |
| Concurrencia de estres | 40 | 40 | Caso extremo y muy improbable; limite de prueba |
| Solicitudes HTTP normales | 2 req/s | 10 req/s | CRUD, grillas y consultas |
| Solicitudes HTTP pico | 5 req/s | 10 req/s | Carga coordinada de disponibilidad |
| Datos estructurados iniciales | < 1 GB | 2 GB | Perfiles, disponibilidad, estructura y auditoria |
| Crecimiento anual de datos | < 1 GB | 3 GB | Un ciclo anual y auditoria |
| Archivos | < 500 MB | 2 GB | Exportaciones y archivos controlados de Untis |
| Operacion | Intermitente y estacional | Pico de 4 semanas | Luego uso aislado durante el resto del ano |
| Ambientes | Dev y prod | UAT dentro de dev | Separacion de RG y secretos |

### 2.1 Datos que deben confirmar Direccion

Las cifras de esta seccion fueron confirmadas por el owner el 2026-07-22:

- 80 docentes en la primera etapa.
- 40 usuarios simultaneos como escenario de estres muy exagerado, no como
  concurrencia esperada.
- Cuatro semanas de pico de proceso y uso aislado durante el resto del ano.

Pendiente operativo: confirmar la fecha exacta de apertura/cierre y la
retencion de historicos por ciclo antes de definir backups definitivos.

## 3. Objetivos de rendimiento y continuidad

| Objetivo | Dev / UAT | Prod inicial | Condicion de escalado |
| --- | --- | --- | --- |
| Latencia p95 CRUD | <= 3 s | <= 2 s | Revisar consultas y subir tier si persiste |
| Latencia p95 grilla/matriz | <= 5 s | <= 3 s | Paginacion, indices y capacidad SQL |
| Error rate | < 1% | < 0,5% | Investigar antes de ampliar capacidad |
| Cold start | <= 15 s aceptable | No durante ventana activa | Mantener replica minima activa |
| Concurrencia probada | 15 | 40 | El escenario de 40 es una prueba de estres extrema |
| Disponibilidad | Durante pruebas | Ventana de servicio acordada | Alta disponibilidad solo si el RTO lo exige |
| RTO | Por confirmar | Objetivo inicial <= 8 h | Backup/restore y runbook |
| RPO | Por confirmar | Objetivo inicial <= 24 h | Ajustar backup segun impacto |

Los objetivos de RTO/RPO y disponibilidad deben ser aprobados por Direccion.
No se contrataran redundancias costosas sin ese requisito.

## 4. Alternativas comparadas

### Alternativa A - Administrada y optimizada para uso estacional

- Container Apps Consumption: dev con `minReplicas=0`; prod con una replica
  durante la ventana activa y posibilidad de bajar a cero fuera de ella si
  Direccion acepta cold start.
- SQL Database: oferta gratuita serverless para dev, si esta disponible; Basic
  provisionado para prod.
- Blob Standard LRS, ACR Basic unico, Key Vault por ambiente y observabilidad
  con limites.

Ventajas: menor operacion, aislamiento, backups administrados, escalado simple,
mantiene .NET/EF Core y permite subir capacidad por configuracion. Riesgo:
SQL Basic y el cold start deben validarse con la carga de la matriz.

### Alternativa B - PostgreSQL Flexible Server

- PostgreSQL Flexible Server separado por ambiente.
- Compute Burstable pequeno para dev/prod, con stop/start de dev cuando sea
  posible.
- Mismo hosting Container Apps, Storage, ACR y observabilidad.

Ventajas: portabilidad y buen encaje si aparecen extensiones o necesidades
especificas de PostgreSQL. Riesgos: el costo base provisionado puede ser mayor
que SQL Basic para un sistema pequeno, la comparacion depende de la region y
se agrega una decision de motor que no aporta valor funcional conocido hoy.

### Comparacion de decision

| Criterio | Alternativa A | Alternativa B |
| --- | --- | --- |
| Costo con baja actividad | Mejor si dev usa oferta gratuita y prod es Basic | Depende de stop/start y SKU disponible |
| Rendimiento inicial | Predecible en prod; validar 5 DTU | Predecible; validar burst y conexiones |
| Cold start | Dev puede pausarse; prod puede mantener replica | Dev puede detenerse; servidor prod activo |
| Operacion | Alineada al stack institucional existente | Requiere decisiones y conocimiento adicional |
| Portabilidad | Menor que PostgreSQL | Mayor |
| Riesgo de Sprint 1 | Bajo | Medio |
| Decision | **Seleccionada como baseline** | Reserva si pruebas o requisitos lo justifican |

PostgreSQL o MySQL no se descartan. Se descartan como eleccion automatica por
precio: el costo total debe incluir compute, almacenamiento, backups,
disponibilidad, conexiones, soporte y operacion.

## 5. Estimacion de costo

Valores orientativos en USD, sin impuestos, compromisos, soporte, descuentos,
egreso extraordinario ni cargos que dependan del consumo. Se deben recalcular
en Azure Pricing Calculator y en la suscripcion antes de crear cada recurso.

### 5.1 Envolvente mensual propuesta

| Servicio | Dev normal | Prod normal | Prod pico | Base del calculo |
| --- | ---: | ---: | ---: | --- |
| SQL Database | USD 0-6 | USD 6-15 | USD 15-35 | Oferta gratuita dev si aplica; Basic y posible upgrade prod |
| Container Apps | USD 0-5 | USD 0-10 | USD 5-25 | Consumption, franquicia y replicas segun ventana |
| ACR compartido | USD 5-8 | Incluido en compartido | Incluido en compartido | Un registry, limpieza de imagenes |
| Storage + backups | USD 0-5 | USD 1-8 | USD 2-12 | Standard LRS, volumen bajo y retencion definida |
| Key Vault | USD 0-3 | USD 0-5 | USD 0-8 | Pocas operaciones, un vault por ambiente |
| App Insights + Log Analytics | USD 0-8 | USD 0-12 | USD 5-25 | Muestreo, limites y franquicias verificadas |
| Red y otros | USD 0-3 | USD 0-5 | USD 0-10 | Sin servicios de red fijos en baseline |
| **Total indicativo** | **USD 5-38** | **USD 7-60** | **USD 27-115** | Revisar contra presupuesto y uso real |

El presupuesto actual de USD 50 por ambiente es suficiente como objetivo de
operacion normal, pero puede resultar insuficiente durante un pico si se
amplia SQL, aumenta la retencion de logs o se agregan servicios de red. Las
alertas 50/80/100% ya creadas notifican consumo, pero no detienen recursos.

### 5.2 Escenarios anuales

| Escenario | Hipotesis | Estimacion anual orientativa |
| --- | --- | ---: |
| Normal | 48 semanas de uso bajo/aislado + 4 semanas activas, sin upgrade mayor | USD 120-360 |
| Campana intensa | 4 semanas pico con SQL superior y mayor telemetria | USD 180-550 |
| Crecimiento | Mas de 80 docentes o uso continuo no previsto | Recalcular antes de ampliar |

Estos rangos sirven para decidir y no para facturacion. La factura real se
controlara en Cost Management y se comparara con los supuestos.

## 6. Capacidad y escalado

Baseline inicial:

- Dev: una replica maxima, escala a cero fuera de uso; SQL gratuita si esta
  disponible y pausado automatico solo si no afecta las pruebas.
- Prod: una replica minima durante la ventana activa; maximo dos replicas
  hasta validar concurrencia y costo.
- SQL prod: Basic inicial; escalar a S0/S1 o equivalente si la prueba muestra
  saturacion, bloqueos, latencia p95 o falta de conexiones.
- Container Apps: aumentar CPU/memoria o replicas solo luego de observar el
  cuello de botella; no usar replicas como solucion automatica a consultas
  lentas.
- Logs: muestreo adaptativo para telemetria de alto volumen; auditoria,
  seguridad y errores relevantes siempre preservados.

Umbrales de revision:

- CPU o memoria sostenida > 70% durante 15 minutos.
- Latencia p95 por encima del objetivo durante 5 minutos.
- Error rate >= 1% o throttling.
- SQL con saturacion sostenida, bloqueos o conexiones agotadas.
- Proyeccion de costo mensual >= 80% del presupuesto antes del cierre.

## 7. Medicion y validacion

Antes de G2:

- verificar disponibilidad de los SKU y oferta gratuita en `brazilsouth`;
- recalcular estimaciones con la suscripcion real;
- probar login, perfil, disponibilidad, matriz y auditoria;
- ejecutar carga de 15 usuarios normales y 75 concurrentes de margen;
- medir p95, errores, CPU, memoria, conexiones SQL, almacenamiento y logs;
- registrar resultado y ajustar el documento antes del aprovisionamiento prod.

Despues de desplegar dev:

- revisar a las 24 horas y a los 7 dias;
- comparar uso real con las hipotesis;
- revisar a los 30 dias y despues de la campaña 2027;
- cambiar SKU, limites o replicas mediante un cambio documentado.

## 8. Seguridad y restricciones

- Dev y prod permanecen en RG separados.
- No se comparte base, Key Vault ni datos entre ambientes.
- No se agregan servicios de red pagos para compensar una falta de analisis.
- Backups, auditoria, logs de seguridad y controles de acceso no se eliminan
  para cumplir el presupuesto.
- Los secretos los carga el owner en Key Vault; no se incluyen en IaC ni repo.
- El dimensionamiento no reemplaza el registro de riesgos de
  `SEGURIDAD_ISO27001.md`.

## 9. Decision G1

**Estado: APROBADO por el owner el 2026-07-22.**

Decisiones aprobadas:

1. 80 docentes en la primera etapa.
2. 40 usuarios simultaneos como escenario de estres extremo, no esperado.
3. Pico de proceso de cuatro semanas y uso aislado el resto del ano.
4. p95 de 2 segundos para operaciones y 3 segundos para la matriz en prod.
5. SQL gratuita para dev si la suscripcion la habilita y SQL Basic para prod.
6. Presupuesto normal de hasta USD 50 por ambiente y alertas 50/80/100%.
7. RTO inicial de 8 horas y RPO inicial de 24 horas.

Responsable de aprobacion: Joaquin Salas, `servicios@goethe.edu.ar`. La
arquitectura puede pasar a Sprint 1. Los SKU se vuelven a verificar en la
suscripcion antes de aprovisionar y la prueba de carga conserva el escenario
extremo de 40 usuarios.

## 10. Referencias de precios y producto

- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [Azure SQL Database pricing](https://azure.microsoft.com/pricing/details/azure-sql-database/)
- [Azure SQL Database free offer FAQ](https://learn.microsoft.com/azure/azure-sql/database/free-offer-faq)
- [Azure Container Apps pricing](https://azure.microsoft.com/pricing/details/container-apps/)
- [Azure Database for PostgreSQL pricing](https://azure.microsoft.com/pricing/details/postgresql/flexible-server/)
- [Azure Database for MySQL pricing](https://azure.microsoft.com/pricing/details/mysql/)
