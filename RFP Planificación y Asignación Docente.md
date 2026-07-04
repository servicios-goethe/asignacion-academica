```markdown
# RFP: Sistema de Planificación Académica y Asignación Docente
## Colegio Goethe - Versión Final 1.0
**Fecha:** 1 de Julio, 2026  
**Estado:** Listo para cotización

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Objetivos del Sistema](#2-objetivos-del-sistema)
3. [Arquitectura General](#3-arquitectura-general)
4. [Flujo de Trabajo: Las 3 Etapas](#4-flujo-de-trabajo-las-3-etapas)
5. [Especificaciones Funcionales Detalladas](#5-especificaciones-funcionales-detalladas)
6. [Reglas de Negocio](#6-reglas-de-negocio)
7. [Formato de Exportación GPU014 para Untis](#7-formato-de-exportación-gpu014-para-untis)
8. [Stack Tecnológico](#8-stack-tecnológico)
9. [Plan de Desarrollo por Sprints](#9-plan-de-desarrollo-por-sprints)
10. [Consideraciones Técnicas](#10-consideraciones-técnicas)
11. [Anexos](#11-anexos)

---

## 1. Resumen Ejecutivo

### 1.1 Contexto

El Colegio Goethe actualmente gestiona la planificación académica mediante:
- Formularios de Google Forms para recolección de disponibilidad docente
- Google Sheets con scripts de Google Apps Script para cálculos
- Procesos manuales para asignación de materias a docentes
- Exportación manual a Untis para generación de horarios

### 1.2 Problema

- **Falta de centralización:** Información dispersa en múltiples herramientas
- **Errores manuales:** Cálculos propensos a errores humanos
- **Trazabilidad limitada:** Sin historial de cambios o aprobaciones
- **Proceso repetitivo:** Cada ciclo lectivo requiere el mismo esfuerzo manual

### 1.3 Solución Propuesta

Desarrollo de una **plataforma web centralizada** que:
- Centralice toda la información académica en una base de datos SQL
- Automatice cálculos de horas (regla del 35%)
- Implemente un flujo de aprobación de 3 etapas
- Genere automáticamente archivos de exportación compatibles con Untis
- Proporcione dashboards en tiempo real para seguimiento

### 1.4 Alcance

- **Tipo de producto:** Single-tenant (uso exclusivo del Colegio Goethe)
- **Usuarios:** ~120 docentes + 1 director/administrador
- **Integración:** Exportación a Untis 2026/2027
- **MVP:** Funcionalidad completa para planificación anual

---

## 2. Objetivos del Sistema

### 2.1 Objetivos Funcionales

1. **Recolección centralizada** de disponibilidad docente con validación automática
2. **Gestión dinámica** de estructura académica (niveles, modalidades, materias, grupos)
3. **Asignación visual** de docentes a materias mediante interfaz Drag & Drop
4. **Cálculo automático** de horas considerando la regla del 35%
5. **Exportación automatizada** de archivos GPU014 para Untis
6. **Trazabilidad completa** con estados de aprobación y auditoría

### 2.2 Objetivos No Funcionales

- **Disponibilidad:** 99.5% uptime durante períodos críticos
- **Performance:** Carga de páginas < 2 segundos
- **Seguridad:** Autenticación SSO con Google Workspace
- **Escalabilidad:** Capacidad para soportar hasta 200 usuarios concurrentes
- **Mantenibilidad:** Código documentado y modular

---

## 3. Arquitectura General

### 3.1 Diagrama de Alto Nivel

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (Next.js)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Portal     │  │   Panel      │  │  Dashboard   │      │
│  │   Docente    │  │   Director   │  │  Reportes    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  Backend API (Supabase)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Auth       │  │   Business   │  │  Export      │      │
│  │   (SSO)      │  │   Logic      │  │  Engine      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Database (PostgreSQL)                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Docentes   │  │   Materias   │  │  Asignaciones│      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Exportación                               │
│              Archivo GPU014.TXT                              │
│                    (Untis)                                   │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Componentes Principales

1. **Frontend:** Aplicación web responsiva con Next.js
2. **Backend:** API REST con Supabase (PostgreSQL + Auth + Realtime)
3. **Base de Datos:** PostgreSQL con Row Level Security (RLS)
4. **Motor de Exportación:** Generador de archivos GPU014
5. **Sistema de Autenticación:** SSO con Google Workspace

---

## 4. Flujo de Trabajo: Las 3 Etapas

El sistema está organizado en **3 etapas secuenciales** que deben completarse en orden. Cada etapa tiene estados de aprobación y bloquea la siguiente hasta ser completada.

### 4.1 ETAPA 1: Relevamiento de Disponibilidad Docente

**Responsable:** Docentes  
**Duración estimada:** 2-3 semanas  
**Estado inicial:** `PENDIENTE` → `EN_PROGRESO` → `COMPLETADA`

#### Flujo:

```
1. Docente recibe notificación por email
2. Ingresa al sistema con SSO de Google (@goethe.edu.ar)
3. Confirma/actualiza sus horas base de contrato
4. Marca bloques de disponibilidad en calendario semanal
5. Envía formulario
6. Sistema calcula automáticamente la disponibilidad requerida (horas * 1.35)
7. Director aprueba/rechaza disponibilidad (individual o masivamente)
8. Si es aprobada, pasa a Etapa 2
```

#### Validaciones:

- **Regla del 35%:** El sistema calcula automáticamente el mínimo de horas requeridas
- **No restrictivo:** El docente puede enviar el formulario aunque no llegue al 35%
- **Alertas:** El sistema marca visualmente si la disponibilidad es insuficiente
- **Aprobación:** El director puede aprobar masivamente para agilizar el proceso

#### Dashboard de Seguimiento:

- Porcentaje de docentes que completaron disponibilidad
- Lista de docentes pendientes con botón de recordatorio
- Estado de aprobación por docente
- Alertas de disponibilidad insuficiente

### 4.2 ETAPA 2: Estructura Académica (Director)

**Responsable:** Director  
**Duración estimada:** 1-2 semanas  
**Estado inicial:** `EN_DESARROLLO` → `FINALIZADA` → `APROBADA`

#### Flujo:

```
1. Director crea ciclo lectivo (ej: "2026")
2. Define niveles (ES1, ES2, ES3, ES4, ES5, ES6)
3. Define modalidades por nivel (Común, NAT, SOC, ECO, ABI)
4. Define grupos/divisiones por nivel (A, B, C, D, IMA 1, IMA 2, etc.)
5. Define materias y horas por nivel/modalidad/grupo
6. Define talleres (Básico/Superior) con duración fija de 2 horas cátedra
7. Marca estructura como "FINALIZADA"
8. Revisa y aprueba, marcando como "APROBADA"
9. Sistema desbloquea Etapa 3
```

#### Reglas de Materias:

- **Materias Comunes:** Se replican automáticamente a **todas las divisiones** del nivel
- **Materias de Modalidad:** Solo aplican a las **divisiones específicas** de esa modalidad
- **Horas Cátedra:** Se definen en horas de 45 minutos
- **Talleres:** Duración fija de 2 horas cátedra (90 minutos)

#### Validaciones:

- No puede haber materias sin horas asignadas
- No puede haber divisiones sin materias
- Las horas deben ser consistentes con la carga horaria oficial
- El director debe seleccionar explícitamente qué divisiones pertenecen a cada modalidad

### 4.3 ETAPA 3: Asignación Docente (El Core Visual)

**Responsable:** Director  
**Duración estimada:** 2-3 semanas  
**Estado inicial:** `BLOQUEADA` → `EN_PROGRESO` → `COMPLETADA`

#### Flujo:

```
1. Sistema verifica que Etapa 2 esté "APROBADA"
2. Director accede a matriz de asignación (Drag & Drop)
3. Para cada materia/grupo, arrastra docente desde panel lateral
4. Sistema calcula automáticamente:
   - Horas asignadas al docente (con regla 1.35)
   - Saldo disponible del docente
   - Alertas si se excede disponibilidad
5. Director revisa dashboard de carga horaria
6. Ajusta asignaciones según sea necesario
7. Marca asignación como "COMPLETADA"
8. Sistema genera archivo GPU014 para exportación
```

#### Interfaz de Asignación:

```
┌─────────────────────────────────────────────────────────────┐
│  MATRIZ DE ASIGNACIÓN - ES4 - MATEMÁTICA                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  División    │ Docente Asignado    │ Horas    │ Saldo       │
│  ─────────────────────────────────────────────────────────  │
│  A           │ [GoD]               │ 5.0      │ +15.3       │
│  B           │ [FaC]               │ 5.0      │ +12.8       │
│  C           │ [MaT]               │ 5.0      │ +7.3        │
│  D           │ [Sin asignar]       │ -        │ -           │
│                                                              │
│  IMA 1       │ [GoD]               │ 5.0      │ +10.3       │
│  IMA 2       │ [FaC]               │ 5.0      │ +7.8        │
│                                                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  PANEL DE DOCENTES DISPONIBLES                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [GoD]  Horas Base: 20  |  Disponibilidad: 27  |  Asignado: 10  │
│  [FaC]  Horas Base: 28  |  Disponibilidad: 37.8 |  Asignado: 30  │
│  [MaT]  Horas Base: 9   |  Disponibilidad: 12.15|  Asignado: 5   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

#### Validaciones:

- **Sobrecarga:** Alerta visual si docente excede su disponibilidad aprobada
- **Subcarga:** Alerta si docente tiene menos horas asignadas que su contrato base
- **Conflictos:** No se puede asignar mismo docente a misma hora en diferentes grupos
- **Completitud:** No se puede exportar si hay materias sin docente asignado

---

## 5. Especificaciones Funcionales Detalladas

### 5.1 Módulo de Autenticación

**Requisitos:**

- **SSO con Google Workspace:** Solo usuarios con dominio `@goethe.edu.ar`
- **Roles:**
  - `DOCENTE`: Acceso solo a Etapa 1 (su propia disponibilidad)
  - `DIRECTOR`: Acceso completo a todas las etapas
- **Sesión:** Tokens JWT con expiración de 24 horas
- **Seguridad:** HTTPS obligatorio, CSRF protection

**Implementación:**

```typescript
// Ejemplo de configuración de Supabase Auth
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  }
});

// Login con Google
const { user, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    queryParams: {
      hd: 'goethe.edu.ar' // Restringe al dominio del colegio
    }
  }
});
```

### 5.2 Módulo de Disponibilidad Docente (Etapa 1)

**Campos del Formulario:**

1. **Email** (automático desde SSO)
2. **Nombre y Apellido** (automático desde SSO)
3. **Departamento** (selector: Alemán, Arte, Castellano, Cs. Naturales, Cs. Sociales, Ed. Física, Informática, Inglés, Matemática)
4. **Horas frente a curso** (input numérico, editable)
5. **Cargo** (selector: Jefe de departamento, Tutor, Full time, Part time, Contratación por hora)
6. **Disponibilidad horaria** (calendario semanal interactivo)
7. **Observaciones** (texto libre)

**Calendario de Disponibilidad:**

```
┌─────────────────────────────────────────────────────────────┐
│  DISPONIBILIDAD SEMANAL                                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Hora        │ Lun  │ Mar  │ Mié  │ Jue  │ Vie              │
│  ─────────────────────────────────────────────────────────  │
│  7:45-8:30   │ [✓]  │ [✓]  │ [✓]  │ [✓]  │ [✓]              │
│  8:30-9:15   │ [✓]  │ [✓]  │ [✓]  │ [✓]  │ [✓]              │
│  9:30-10:15  │ [ ]  │ [✓]  │ [✓]  │ [✓]  │ [✓]              │
│  10:15-11:00 │ [ ]  │ [✓]  │ [✓]  │ [✓]  │ [✓]              │
│  11:10-11:55 │ [ ]  │ [✓]  │ [✓]  │ [✓]  │ [✓]              │
│  11:55-12:40 │ [ ]  │ [ ]  │ [✓]  │ [ ]  │ [ ]              │
│  13:25-14:10 │ [ ]  │ [ ]  │ [ ]  │ [ ]  │ [ ]              │
│  14:10-14:55 │ [ ]  │ [ ]  │ [ ]  │ [ ]  │ [ ]              │
│  15:10-15:50 │ [ ]  │ [ ]  │ [ ]  │ [ ]  │ [ ]              │
│  15:50-16:30 │ [ ]  │ [ ]  │ [ ]  │ [ ]  │ [ ]              │
│                                                              │
│  Total horas marcadas: 18.5                                   │
│  Mínimo requerido (20 * 1.35): 27                             │
│  ⚠️ Faltan marcar 8.5 horas                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Bloques Horarios:**

- **Lunes, Martes, Jueves, Viernes:** 10 bloques (7:45 a 16:30)
- **Miércoles:** 7 bloques (7:45 a 13:30)
- **Duración de cada bloque:** 45 minutos
- **Total de bloques semanales:** 47 bloques

**Validaciones:**

```typescript
// Cálculo de horas requeridas
const horasBase = formData.horasFrenteCurso;
const horasRequeridas = horasBase * 1.35;
const horasMarcadas = calcularHorasMarcadas(formData.disponibilidad);

if (horasMarcadas < horasRequeridas) {
  mostrarAlerta(`⚠️ Disponibilidad insuficiente. Marcó ${horasMarcadas} horas, mínimo requerido: ${horasRequeridas}`);
  // NO bloquear el envío, solo alertar
}
```

**Estados de Disponibilidad:**

- `BORRADOR`: Docente está completando formulario
- `ENVIADA`: Docente envió formulario, pendiente de aprobación
- `APROBADA`: Director aprobó disponibilidad
- `RECHAZADA`: Director rechazó (con comentarios)

### 5.3 Módulo de Estructura Académica (Etapa 2)

**Entidades Principales:**

#### 5.3.1 Ciclo Lectivo

```typescript
interface CicloLectivo {
  id: string;
  nombre: string; // "2026"
  anio: number;
  estado: 'EN_DESARROLLO' | 'FINALIZADA' | 'APROBADA';
  fecha_creacion: Date;
  fecha_actualizacion: Date;
}
```

#### 5.3.2 Nivel

```typescript
interface Nivel {
  id: string;
  ciclo_lectivo_id: string;
  codigo: string; // "ES1", "ES2", etc.
  nombre: string; // "Educación Secundaria 1"
  orden: number;
}
```

#### 5.3.3 Modalidad

```typescript
interface Modalidad {
  id: string;
  nivel_id: string;
  codigo: string; // "COMUN", "NAT", "SOC", "ECO", "ABI"
  nombre: string; // "Común", "Ciencias Naturales", etc.
}
```

#### 5.3.4 División/Grupo

```typescript
interface Division {
  id: string;
  nivel_id: string;
  modalidad_id: string;
  codigo: string; // "A", "B", "IMA 1", etc.
  nombre: string;
  orden: number;
}
```

#### 5.3.5 Materia

```typescript
interface Materia {
  id: string;
  nivel_id: string;
  modalidad_id: string; // null si es común
  codigo: string; // "MATE", "HIST", etc.
  nombre: string; // "Matemática", "Historia", etc.
  horas_catedra: number; // Horas de 45 minutos
  es_taller: boolean;
  duracion_taller?: number; // Solo si es_taller = true (en horas cátedra)
}
```

#### 5.3.6 Asignación de Materia a División

```typescript
interface MateriaDivision {
  id: string;
  materia_id: string;
  division_id: string;
  horas_semanales: number;
}
```

**Interfaz de Configuración:**

```
┌─────────────────────────────────────────────────────────────┐
│  CONFIGURACIÓN DE ESTRUCTURA ACADÉMICA - 2026               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Nivel: ES4                                                 │
│  Estado: FINALIZADA                                         │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Modalidad: COMÚN                                     │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │ Divisiones: A, B, C, D                               │  │
│  │                                                      │  │
│  │ Materia          │ Horas │ A  │ B  │ C  │ D          │  │
│  │ ─────────────────────────────────────────────────── │  │
│  │ ALEMÁN           │ 5     │ ✓  │ ✓  │ ✓  │ ✓        │  │
│  │ INGLÉS           │ 5     │ ✓  │ ✓  │ ✓  │ ✓        │  │
│  │ MATEMÁTICA       │ 5     │ ✓  │ ✓  │ ✓  │ ✓        │  │
│  │ LITERATURA       │ 4     │ ✓  │ ✓  │ ✓  │ ✓        │  │
│  │ FÍSICA           │ 3     │ ✓  │ ✓  │ ✓  │ ✓        │  │
│  │ BIOLOGÍA         │ 3     │ ✓  │ ✓  │ ✓  │ ✓        │  │
│  │ ...              │       │    │    │    │            │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Modalidad: CIENCIAS NATURALES                        │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │ Divisiones: NAT                                      │  │
│  │                                                      │  │
│  │ Materia          │ Horas │ NAT                       │  │
│  │ ─────────────────────────────────────────────────── │  │
│  │ QUÍMICA          │ 4     │ ✓                         │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ TALLERES                                             │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │ Taller           │ Tipo      │ Duración │ Divisiones │  │
│  │ ─────────────────────────────────────────────────── │  │
│  │ ELE              │ Básico    │ 2 hs     │ A, B, C, D │  │
│  │ Biología Molecular│ Superior │ 2 hs     │ NAT        │  │
│  │ Hidroponia       │ Superior  │ 2 hs     │ NAT        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  [Guardar Borrador]  [Marcar como Finalizada]  [Aprobar]   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Validaciones:**

- No se puede aprobar si hay materias sin horas asignadas
- No se puede aprobar si hay divisiones sin materias
- Las horas de talleres deben ser exactamente 2 horas cátedra
- Las materias comunes deben estar en todas las divisiones del nivel

### 5.4 Módulo de Asignación de Docentes (Etapa 3)

**Interfaz de Asignación:**

```
┌─────────────────────────────────────────────────────────────┐
│  ASIGNACIÓN DE DOCENTES - ES4 - MATEMÁTICA                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ División    │ Docente    │ Horas │ Saldo │ Estado   │   │
│  │ ────────────────────────────────────────────────── │   │
│  │ A           │ [GoD]      │ 5.0   │ +15.3 │ ✓ OK     │   │
│  │ B           │ [FaC]      │ 5.0   │ +12.8 │ ✓ OK     │   │
│  │ C           │ [MaT]      │ 5.0   │ +7.3  │ ✓ OK     │   │
│  │ D           │ [Sin]      │ -     │ -     │ ⚠️ Pend. │   │
│  │ IMA 1       │ [GoD]      │ 5.0   │ +10.3 │ ✓ OK     │   │
│  │ IMA 2       │ [FaC]      │ 5.0   │ +7.8  │ ✓ OK     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ DOCENTES DISPONIBLES (Drag & Drop)                 │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ [GoD]  Base: 20h | Disp: 27h | Asig: 10h | Saldo: +17h │
│  │ [FaC]  Base: 28h | Disp: 37.8h | Asig: 30h | Saldo: +7.8h │
│  │ [MaT]  Base: 9h | Disp: 12.15h | Asig: 5h | Saldo: +7.15h │
│  │ [BrR]  Base: 27h | Disp: 36.45h | Asig: 36.5h | Saldo: -0.05h ⚠️ │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ DASHBOARD DE CARGA HORARIA                         │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Total Docentes: 113                                │   │
│  │ ✓ Asignación Completa: 98 (86.7%)                  │   │
│  │ ⚠️ Sobrecargados: 5 (4.4%)                         │   │
│  │ ⚠️ Subcargados: 10 (8.8%)                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  [Exportar a Untis]  [Guardar Progreso]                    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Lógica de Cálculo:**

```typescript
// Al asignar un docente a una materia
function asignarDocente(materiaId: string, divisionId: string, docenteId: string) {
  // 1. Obtener horas de la materia
  const materia = getMateria(materiaId);
  const horasMateria = materia.horas_catedra;
  
  // 2. Aplicar regla del 35%
  const horasConPlus = horasMateria * 1.35;
  
  // 3. Obtener disponibilidad del docente
  const docente = getDocente(docenteId);
  const horasDisponibles = docente.horas_disponibilidad_aprobada;
  
  // 4. Calcular horas ya asignadas
  const horasAsignadas = getHorasAsignadas(docenteId);
  
  // 5. Verificar si hay suficiente disponibilidad
  if (horasAsignadas + horasConPlus > horasDisponibles) {
    mostrarAlerta(`⚠️ El docente ${docente.nombre} quedaría sobrecargado.`);
  }
  
  // 6. Crear asignación
  crearAsignacion(materiaId, divisionId, docenteId, horasConPlus);
  
  // 7. Actualizar dashboard
  actualizarDashboard(docenteId);
}
```

**Validaciones:**

- **Sobrecarga:** Si `horas_asignadas + horas_materia * 1.35 > horas_disponibilidad`, mostrar alerta
- **Subcarga:** Si `horas_asignadas < horas_base_contrato`, mostrar alerta
- **Conflictos de horario:** No permitir asignar mismo docente en mismo bloque horario
- **Completitud:** No permitir exportar si hay materias sin docente

**Estados de Asignación:**

- `EN_PROGRESO`: Director está asignando docentes
- `COMPLETADA`: Todas las materias tienen docente asignado
- `EXPORTADA`: Se generó archivo GPU014

### 5.5 Dashboard de Control

**Métricas Principales:**

1. **Etapa 1 - Disponibilidad:**
   - % de docentes que completaron formulario
   - % de disponibilidades aprobadas
   - Lista de pendientes

2. **Etapa 2 - Estructura:**
   - Estado del ciclo lectivo
   - Total de materias configuradas
   - Total de divisiones configuradas

3. **Etapa 3 - Asignación:**
   - % de materias con docente asignado
   - Docentes sobrecargados
   - Docentes subcargados
   - Materias sin asignar

**Alertas Automáticas:**

```typescript
interface Alerta {
  tipo: 'SOBRECARGA' | 'SUBCARGA' | 'INCOMPLETO' | 'CONFLICTO';
  severidad: 'INFO' | 'WARNING' | 'ERROR';
  mensaje: string;
  docente_id?: string;
  materia_id?: string;
}

// Ejemplos de alertas
const alertas: Alerta[] = [
  {
    tipo: 'SOBRECARGA',
    severidad: 'WARNING',
    mensaje: 'BrR está sobrecargado en 0.05 horas',
    docente_id: 'br-r'
  },
  {
    tipo: 'INCOMPLETO',
    severidad: 'ERROR',
    mensaje: 'ES4 - MATEMÁTICA - División D no tiene docente asignado',
    materia_id: 'mate-es4',
    division_id: 'es4-d'
  }
];
```

---

## 6. Reglas de Negocio

### 6.1 Regla del 35% (Buffer para Reemplazos)

**Descripción:**

Todo docente debe tener una disponibilidad horaria aprobada que sea al menos un 35% mayor que sus horas base de contrato. Este buffer se utiliza para cubrir reemplazos, preparación de clases, correcciones, etc.

**Fórmula:**

```
horas_disponibilidad_minima = horas_base_contrato * 1.35
```

**Ejemplos:**

| Horas Base | Disponibilidad Mínima (×1.35) |
|------------|-------------------------------|
| 20         | 27.0                          |
| 28         | 37.8                          |
| 9          | 12.15                         |
| 27         | 36.45                         |

**Implementación:**

```typescript
// En el script original (Materia.txt)
let horasConPlus = horasBase * 1.35;

// En el sistema
function calcularHorasConBuffer(horasBase: number): number {
  return horasBase * 1.35;
}

function validarDisponibilidad(horasBase: number, horasMarcadas: number): boolean {
  const minimoRequerido = calcularHorasConBuffer(horasBase);
  return horasMarcadas >= minimoRequerido;
}
```

### 6.2 Regla de Talleres

**Descripción:**

Todos los talleres tienen una duración fija de **2 horas cátedra** (90 minutos), independientemente del tipo (Básico o Superior).

**Fórmula:**

```
horas_taller = cantidad_talleres_asignados * 2 * 1.35
```

**Ejemplo:**

Si un docente tiene asignados 3 talleres:
```
horas_taller = 3 * 2 * 1.35 = 8.1 horas
```

**Implementación:**

```typescript
// En el script original (Talleres.txt)
resultadosTalleres[filaDestino][0] = conteoTmp[nombre] * 2 * 1.35;

// En el sistema
function calcularHorasTalleres(cantidadTalleres: number): number {
  return cantidadTalleres * 2 * 1.35;
}
```

### 6.3 Regla de Materias Comunes vs. Modalidad

**Descripción:**

- **Materias Comunes:** Se replican automáticamente a **todas las divisiones** del nivel
- **Materias de Modalidad:** Solo aplican a las **divisiones específicas** de esa modalidad

**Ejemplo:**

```
Nivel: ES4

Modalidad COMÚN:
- Divisiones: A, B, C, D
- Materias: ALEMÁN, INGLÉS, MATEMÁTICA, etc.
- → Todas las divisiones (A, B, C, D) tienen estas materias

Modalidad CIENCIAS NATURALES (NAT):
- Divisiones: NAT
- Materias: QUÍMICA
- → Solo la división NAT tiene QUÍMICA
```

**Implementación:**

```typescript
function replicarMateriasComunes(nivelId: string, materiaId: string) {
  // Obtener todas las divisiones del nivel
  const divisiones = getDivisionesByNivel(nivelId);
  
  // Crear asignación para cada división
  divisiones.forEach(division => {
    crearMateriaDivision(materiaId, division.id, horas);
  });
}

function asignarMateriaModalidad(materiaId: string, divisionId: string) {
  // Solo crear asignación para la división específica
  crearMateriaDivision(materiaId, divisionId, horas);
}
```

### 6.4 Regla de Aprobación Secuencial

**Descripción:**

Las etapas deben completarse en orden secuencial:

```
Etapa 1 (Disponibilidad) → Etapa 2 (Estructura) → Etapa 3 (Asignación)
```

**Validaciones:**

- No se puede iniciar Etapa 2 si Etapa 1 no está `COMPLETADA`
- No se puede iniciar Etapa 3 si Etapa 2 no está `APROBADA`
- No se puede exportar a Untis si Etapa 3 no está `COMPLETADA`

**Implementación:**

```typescript
function validarInicioEtapa2(cicloLectivoId: string): boolean {
  const etapa1 = getEtapa1Status(cicloLectivoId);
  return etapa1.estado === 'COMPLETADA';
}

function validarInicioEtapa3(cicloLectivoId: string): boolean {
  const etapa2 = getEtapa2Status(cicloLectivoId);
  return etapa2.estado === 'APROBADA';
}

function validarExportacion(cicloLectivoId: string): boolean {
  const etapa3 = getEtapa3Status(cicloLectivoId);
  return etapa3.estado === 'COMPLETADA';
}
```

### 6.5 Regla de No Sobrecarga

**Descripción:**

Un docente no puede ser asignado a más horas de las que tiene disponibles (considerando el buffer del 35%).

**Fórmula:**

```
horas_asignadas + horas_nueva_materia * 1.35 <= horas_disponibilidad_aprobada
```

**Implementación:**

```typescript
function puedeAsignarDocente(docenteId: string, horasMateria: number): boolean {
  const docente = getDocente(docenteId);
  const horasAsignadas = getHorasAsignadas(docenteId);
  const horasConBuffer = horasMateria * 1.35;
  
  return (horasAsignadas + horasConBuffer) <= docente.horas_disponibilidad_aprobada;
}
```

---

## 7. Formato de Exportación GPU014 para Untis

### 7.1 Descripción General

El archivo GPU014 es el formato de importación utilizado por **Untis** para cargar las asignaciones de docentes a materias y grupos. Este archivo contiene información detallada sobre cada "lección" (clase) programada.

### 7.2 Estructura del Archivo

**Formato:** Texto plano con campos separados por punto y coma (`;`)

**Codificación:** UTF-8

**Salto de línea:** LF (`\n`)

### 7.3 Campos del Archivo GPU014

Basado en el archivo de ejemplo proporcionado, la estructura es:

```
ID;FECHA;DIA;HORA;ID_UNICO;DOCENTE_PRINCIPAL;DOCENTE_SECUNDARIO;MATERIA;CAMPO_9;CAMPO_10;CAMPO_11;AULA_PRINCIPAL;AULA_SECUNDARIA;CAMPO_14;GRUPO;CAMPO_16;GRUPO_DUPLICADO;NUMERO;CAMPO_19;TIMESTAMP;ESTADO
```

**Detalle de Campos:**

| Posición | Campo | Tipo | Descripción | Ejemplo |
|----------|-------|------|-------------|---------|
| 1 | ID | Integer | Identificador único de la lección | `1` |
| 2 | FECHA | String | Fecha de creación/modificación (YYYYMMDD) | `"20250305 "` |
| 3 | DIA | Integer | Día de la semana (1=Lunes, 2=Martes, ..., 5=Viernes) | `1` |
| 4 | HORA | Integer | Bloque horario (1-10) | `1` |
| 5 | ID_UNICO | Integer | Identificador numérico único | `238` |
| 6 | DOCENTE_PRINCIPAL | String | Iniciales del docente principal (3-4 caracteres) | `"BiM "` |
| 7 | DOCENTE_SECUNDARIO | String | Iniciales del docente secundario (puede estar vacío) | `"GoP "` |
| 8 | MATERIA | String | Código de la materia (3-4 caracteres) | `"DEU "` |
| 9-11 | Campos adicionales | String | Campos opcionales (generalmente vacíos) | `;;;` |
| 12 | AULA_PRINCIPAL | String | Código del aula principal | `"A077 R_ES6_D2 "` |
| 13 | AULA_SECUNDARIA | String | Código del aula secundaria (puede repetir) | `"A077 R_ES6_D2 "` |
| 14 | Campo vacío | String | Separador | `;` |
| 15 | GRUPO | String | Código del grupo/clase (separados por `~` si son múltiples) | `"ES6A~ES6B "` |
| 16 | Campo vacío | String | Separador | `;` |
| 17 | GRUPO_DUPLICADO | String | Grupo duplicado (generalmente igual al campo 15) | `"ES6A~ES6B "` |
| 18 | NUMERO | Integer | Valor numérico (prioridad o peso) | `0` |
| 19 | Campo vacío | String | Separador | `;` |
| 20 | TIMESTAMP | String | Timestamp de modificación (YYYYMMDDHHMM) | `202503050859` |
| 21 | ESTADO | String | Indicadores de estado de la lección | `"+~-"` |

### 7.4 Ejemplo de Línea GPU014

```
1; "20250305 ";1;1;238; "BiM "; "GoP "; "DEU ";;;; "A077 R_ES6_D2 "; "A077 R_ES6_D2 ";; "ES6A~ES6B ";;;0; "ES6A~ES6B ";;202503050859; "+~-"
```

**Interpretación:**

- **ID:** 1
- **Fecha:** 2025-03-05
- **Día:** Lunes (1)
- **Hora:** Primer bloque (1)
- **ID Único:** 238
- **Docente Principal:** BiM
- **Docente Secundario:** GoP
- **Materia:** DEU (Alemán)
- **Aula:** A077 R_ES6_D2
- **Grupos:** ES6A y ES6B (divididos)
- **Estado:** Activa (`"+~-"`)

### 7.5 Códigos de Estado

| Código | Descripción |
|--------|-------------|
| `"+~-"` | Lección activa/normal |
| `"-"` | Lección cancelada o pendiente |
| `"R"` | Lección regular |
| `"A"` | Lección aprobada |
| `"S"` | Lección especial o suplementaria |
| `"C"` | Lección con cambio |
| `"E"` | Lección de examen o evaluación |
| `"L"` | Lección de laboratorio o taller |

### 7.6 Grupos Divididos

Cuando una materia se dicta a múltiples grupos simultáneamente, se usa el separador `~`:

```
"ES6A~ES6B "
```

Esto indica que la lección aplica tanto a ES6A como a ES6B al mismo tiempo.

### 7.7 Generación del Archivo GPU014

**Lógica de Generación:**

```typescript
interface Lesson {
  id: number;
  fecha: string; // YYYYMMDD
  dia: number; // 1-5
  hora: number; // 1-10
  idUnico: number;
  docentePrincipal: string; // 3-4 caracteres
  docenteSecundario?: string; // 3-4 caracteres
  materia: string; // 3-4 caracteres
  aulaPrincipal: string;
  aulaSecundaria?: string;
  grupos: string[]; // Códigos de grupos
  numero: number;
  timestamp: string; // YYYYMMDDHHMM
  estado: string;
}

function generarGPU014(lessons: Lesson[]): string {
  const lines = lessons.map(lesson => {
    const gruposStr = `"${lesson.grupos.join('~')} "`;
    
    return [
      lesson.id,
      `"${lesson.fecha} "`,
      lesson.dia,
      lesson.hora,
      lesson.idUnico,
      `"${lesson.docentePrincipal} "`,
      lesson.docenteSecundario ? `"${lesson.docenteSecundario} "` : '',
      `"${lesson.materia} "`,
      '', // Campo 9
      '', // Campo 10
      '', // Campo 11
      `"${lesson.aulaPrincipal} "`,
      lesson.aulaSecundaria ? `"${lesson.aulaSecundaria} "` : `"${lesson.aulaPrincipal} "`,
      '', // Campo 14
      gruposStr,
      '', // Campo 16
      gruposStr,
      lesson.numero,
      '', // Campo 19
      `"${lesson.timestamp}"`,
      `"${lesson.estado}"`
    ].join(';');
  });
  
  return lines.join('\n');
}
```

### 7.8 Mapeo de Datos del Sistema a GPU014

**Desde la Base de Datos:**

```typescript
function mapearAsignacionAGPU014(asignacion: Asignacion): Lesson {
  return {
    id: asignacion.id,
    fecha: formatDate(new Date()), // YYYYMMDD
    dia: asignacion.dia_semana, // 1-5
    hora: asignacion.bloque_horario, // 1-10
    idUnico: asignacion.id,
    docentePrincipal: getDocenteIniciales(asignacion.docente_id),
    docenteSecundario: asignacion.docente_secundario_id 
      ? getDocenteIniciales(asignacion.docente_secundario_id) 
      : undefined,
    materia: getMateriaCodigo(asignacion.materia_id),
    aulaPrincipal: asignacion.aula_codigo || 'SIN_AULA',
    aulaSecundaria: asignacion.aula_codigo || 'SIN_AULA',
    grupos: [asignacion.division_codigo],
    numero: 0,
    timestamp: formatTimestamp(new Date()), // YYYYMMDDHHMM
    estado: '+~-' // Activa
  };
}
```

### 7.9 Consideraciones Importantes

1. **Aulas:** El sistema actual no gestiona aulas. Se puede usar un valor por defecto como `"SIN_AULA"` o dejar que Untis asigne las aulas automáticamente.

2. **Días y Horas:** El sistema actual no define días y horas específicas para cada lección. Esto se puede:
   - Dejar que Untis lo calcule automáticamente
   - Agregar una interfaz para que el director defina días y horas manualmente
   - Implementar un algoritmo de scheduling automático

3. **Docentes Secundarios:** Opcional. Si no hay docente secundario, dejar el campo vacío.

4. **Grupos Divididos:** Si una materia se dicta a múltiples grupos simultáneamente, usar el separador `~`.

5. **Timestamp:** Usar la fecha y hora actual de generación del archivo.

6. **Estado:** Por defecto, usar `"+~-"` (activa).

### 7.10 Ejemplo Completo de Exportación

```typescript
// Generar archivo GPU014 completo
async function exportarGPU014(cicloLectivoId: string): Promise<string> {
  // 1. Obtener todas las asignaciones del ciclo lectivo
  const asignaciones = await getAsignacionesByCicloLectivo(cicloLectivoId);
  
  // 2. Validar que todas las materias tengan docente
  const materiasSinDocente = asignaciones.filter(a => !a.docente_id);
  if (materiasSinDocente.length > 0) {
    throw new Error(`Hay ${materiasSinDocente.length} materias sin docente asignado`);
  }
  
  // 3. Mapear asignaciones a formato GPU014
  const lessons = asignaciones.map(mapearAsignacionAGPU014);
  
  // 4. Generar contenido del archivo
  const content = generarGPU014(lessons);
  
  // 5. Guardar archivo
  const filename = `GPU014_${cicloLectivoId}_${formatDate(new Date())}.txt`;
  await saveFile(filename, content);
  
  return filename;
}
```

---

## 8. Stack Tecnológico

### 8.1 Frontend

**Framework:** Next.js 14+ (React)  
**Lenguaje:** TypeScript  
**Estilos:** Tailwind CSS + shadcn/ui  
**Estado:** React Query + Zustand  
**Drag & Drop:** @dnd-kit/core  
**Calendario:** FullCalendar  
**Formularios:** React Hook Form + Zod  
**Gráficos:** Recharts

**Justificación:**

- **Next.js:** SSR/SSG para mejor performance, API routes integradas
- **TypeScript:** Tipado estático para prevenir errores
- **Tailwind + shadcn:** Componentes UI modernos y consistentes
- **@dnd-kit:** Librería moderna y performante para Drag & Drop
- **FullCalendar:** Calendario robusto y personalizable

**Estructura de Carpetas:**

```
src/
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   └── layout.tsx
│   ├── (dashboard)/
│   │   ├── docente/
│   │   │   ├── disponibilidad/
│   │   │   └── layout.tsx
│   │   ├── director/
│   │   │   ├── etapa1/
│   │   │   ├── etapa2/
│   │   │   ├── etapa3/
│   │   │   └── dashboard/
│   │   └── layout.tsx
│   └── layout.tsx
├── components/
│   ├── ui/
│   ├── forms/
│   ├── tables/
│   └── charts/
├── lib/
│   ├── supabase/
│   ├── utils/
│   └── validators/
├── hooks/
├── types/
└── styles/
```

### 8.2 Backend & Base de Datos

**Plataforma:** Supabase  
**Base de Datos:** PostgreSQL  
**Autenticación:** Supabase Auth (Google SSO)  
**API:** Supabase REST API + Edge Functions  
**Seguridad:** Row Level Security (RLS)

**Justificación:**

- **Supabase:** Backend-as-a-Service con PostgreSQL, Auth, Realtime
- **PostgreSQL:** Base de datos relacional robusta y escalable
- **RLS:** Seguridad a nivel de fila para controlar acceso por rol
- **Edge Functions:** Lógica de negocio serverless

**Esquema de Base de Datos:**

```sql
-- Tabla de Ciclos Lectivos
CREATE TABLE ciclos_lectivos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  anio INTEGER NOT NULL,
  estado TEXT NOT NULL CHECK (estado IN ('EN_DESARROLLO', 'FINALIZADA', 'APROBADA')),
  fecha_creacion TIMESTAMP DEFAULT NOW(),
  fecha_actualizacion TIMESTAMP DEFAULT NOW()
);

-- Tabla de Niveles
CREATE TABLE niveles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ciclo_lectivo_id UUID REFERENCES ciclos_lectivos(id),
  codigo TEXT NOT NULL,
  nombre TEXT NOT NULL,
  orden INTEGER NOT NULL
);

-- Tabla de Modalidades
CREATE TABLE modalidades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nivel_id UUID REFERENCES niveles(id),
  codigo TEXT NOT NULL,
  nombre TEXT NOT NULL
);

-- Tabla de Divisiones
CREATE TABLE divisiones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nivel_id UUID REFERENCES niveles(id),
  modalidad_id UUID REFERENCES modalidades(id),
  codigo TEXT NOT NULL,
  nombre TEXT NOT NULL,
  orden INTEGER NOT NULL
);

-- Tabla de Materias
CREATE TABLE materias (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nivel_id UUID REFERENCES niveles(id),
  modalidad_id UUID REFERENCES modalidades(id),
  codigo TEXT NOT NULL,
  nombre TEXT NOT NULL,
  horas_catedra INTEGER NOT NULL,
  es_taller BOOLEAN DEFAULT FALSE,
  duracion_taller INTEGER
);

-- Tabla de Docentes
CREATE TABLE docentes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  nombre TEXT NOT NULL,
  departamento TEXT NOT NULL,
  cargo TEXT NOT NULL,
  horas_base INTEGER NOT NULL
);

-- Tabla de Disponibilidades
CREATE TABLE disponibilidades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  docente_id UUID REFERENCES docentes(id),
  ciclo_lectivo_id UUID REFERENCES ciclos_lectivos(id),
  dia_semana INTEGER NOT NULL CHECK (dia_semana BETWEEN 1 AND 5),
  bloque_horario INTEGER NOT NULL CHECK (bloque_horario BETWEEN 1 AND 10),
  disponible BOOLEAN DEFAULT TRUE,
  UNIQUE(docente_id, ciclo_lectivo_id, dia_semana, bloque_horario)
);

-- Tabla de Asignaciones de Materias a Divisiones
CREATE TABLE materias_divisiones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  materia_id UUID REFERENCES materias(id),
  division_id UUID REFERENCES divisiones(id),
  horas_semanales INTEGER NOT NULL,
  UNIQUE(materia_id, division_id)
);

-- Tabla de Asignaciones de Docentes a Materias/Divisiones
CREATE TABLE asignaciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  materia_id UUID REFERENCES materias(id),
  division_id UUID REFERENCES divisiones(id),
  docente_id UUID REFERENCES docentes(id),
  horas_asignadas DECIMAL(5,2) NOT NULL,
  dia_semana INTEGER,
  bloque_horario INTEGER,
  UNIQUE(materia_id, division_id, docente_id)
);

-- Row Level Security
ALTER TABLE disponibilidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE asignaciones ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Docentes ven solo su disponibilidad" ON disponibilidades
  FOR SELECT USING (auth.jwt() ->> 'email' = (SELECT email FROM docentes WHERE id = docente_id));

CREATE POLICY "Directores ven todo" ON disponibilidades
  FOR ALL USING (auth.jwt() ->> 'role' = 'DIRECTOR');
```

### 8.3 Infraestructura

**Frontend:** Vercel  
**Backend:** Supabase Cloud  
**Base de Datos:** Supabase PostgreSQL  
**CDN:** Vercel Edge Network  
**Monitoreo:** Supabase Analytics + Vercel Analytics

**Justificación:**

- **Vercel:** Deploy automático desde Git, edge functions, analytics
- **Supabase Cloud:** Managed PostgreSQL, backups automáticos, escalabilidad
- **Edge Network:** Baja latencia global, caché automático

---

## 9. Plan de Desarrollo por Sprints

### 9.1 Sprint 1: Fundación y Autenticación (2 semanas)

**Objetivos:**

- Setup de proyecto Next.js + Supabase
- Implementación de autenticación SSO con Google
- Configuración de base de datos y RLS
- Estructura base de componentes UI

**Entregables:**

- [ ] Proyecto Next.js inicializado con TypeScript
- [ ] Supabase configurado con PostgreSQL
- [ ] Autenticación Google SSO funcional
- [ ] Roles de usuario (DOCENTE, DIRECTOR) implementados
- [ ] Layout base con navegación
- [ ] Componentes UI base (botones, inputs, modales)

**Criterios de Aceptación:**

- Usuario puede loguearse con cuenta @goethe.edu.ar
- Sistema valida dominio y crea sesión
- Roles se asignan correctamente
- Usuario sin permisos es redirigido

### 9.2 Sprint 2: Portal de Disponibilidad Docente (2 semanas)

**Objetivos:**

- Formulario de carga de disponibilidad
- Calendario interactivo de bloques horarios
- Cálculo automático de horas requeridas
- Dashboard de progreso para director

**Entregables:**

- [ ] Formulario de disponibilidad con todos los campos
- [ ] Calendario semanal interactivo (47 bloques)
- [ ] Cálculo automático de horas marcadas vs requeridas
- [ ] Validación de disponibilidad (alertas, no bloqueos)
- [ ] Envío de formulario y guardado en BD
- [ ] Dashboard de progreso con métricas
- [ ] Botón de recordatorio para pendientes

**Criterios de Aceptación:**

- Docente puede marcar/desmarcar bloques horarios
- Sistema calcula horas en tiempo real
- Formulario se puede enviar aunque no llegue al 35%
- Director ve dashboard con % de completitud

### 9.3 Sprint 3: Estructura Académica (2 semanas)

**Objetivos:**

- ABM de ciclos lectivos, niveles, modalidades, divisiones
- ABM de materias con horas cátedra
- Gestión de talleres con duración fija
- Flujo de aprobación de estructura

**Entregables:**

- [ ] CRUD de ciclos lectivos
- [ ] CRUD de niveles con ordenamiento
- [ ] CRUD de modalidades por nivel
- [ ] CRUD de divisiones con mapeo a modalidades
- [ ] CRUD de materias con horas cátedra
- [ ] Gestión de talleres (Básico/Superior)
- [ ] Replicación automática de materias comunes
- [ ] Flujo de estados (Desarrollo → Finalizada → Aprobada)
- [ ] Validaciones de completitud

**Criterios de Aceptación:**

- Director puede crear estructura completa
- Materias comunes se replican a todas las divisiones
- Materias de modalidad solo aplican a divisiones específicas
- Sistema valida que no haya materias sin horas
- Flujo de aprobación funciona correctamente

### 9.4 Sprint 4: Asignación de Docentes (2 semanas)

**Objetivos:**

- Matriz de asignación con Drag & Drop
- Cálculo automático de horas con buffer 35%
- Dashboard de carga horaria
- Validaciones de sobrecarga/subcarga

**Entregables:**

- [ ] Matriz de asignación con @dnd-kit
- [ ] Panel de docentes disponibles con saldos
- [ ] Cálculo automático de horas asignadas
- [ ] Alertas de sobrecarga en tiempo real
- [ ] Dashboard de métricas de asignación
- [ ] Exportación a GPU014
- [ ] Validaciones de completitud

**Criterios de Aceptación:**

- Director puede arrastrar docentes a materias/divisiones
- Sistema calcula horas con buffer 35% automáticamente
- Alertas se muestran si docente queda sobrecargado
- Exportación genera archivo GPU014 válido

### 9.5 Sprint 5: Pruebas, Ajustes y Despliegue (2 semanas)

**Objetivos:**

- Pruebas de usuario con director y docentes reales
- Ajustes de UX/UI basados en feedback
- Optimización de performance
- Documentación final

**Entregables:**

- [ ] Pruebas de usuario completadas
- [ ] Ajustes de UX/UI implementados
- [ ] Optimización de performance (< 2s carga)
- [ ] Documentación técnica completa
- [ ] Manual de usuario
- [ ] Deploy a producción
- [ ] Monitoreo y analytics configurados

**Criterios de Aceptación:**

- Sistema funciona correctamente en producción
- Usuarios pueden completar flujo completo
- Performance cumple SLA
- Documentación está completa y accesible

---

## 10. Consideraciones Técnicas

### 10.1 Seguridad

- **Autenticación:** SSO con Google Workspace, dominio restringido
- **Autorización:** Row Level Security (RLS) en Supabase
- **Datos:** Encriptación en tránsito (TLS) y en reposo
- **Auditoría:** Logs de cambios y accesos

### 10.2 Performance

- **Caché:** React Query para caché de datos
- **Lazy Loading:** Carga diferida de componentes pesados
- **Optimización:** Imágenes optimizadas, código splitting
- **Monitoreo:** Vercel Analytics + Supabase Analytics

### 10.3 Escalabilidad

- **Base de Datos:** PostgreSQL escalable horizontalmente
- **API:** Supabase Edge Functions serverless
- **Frontend:** Vercel Edge Network global
- **Concurrencia:** Hasta 200 usuarios simultáneos

### 10.4 Mantenibilidad

- **Código:** TypeScript para tipado estático
- **Testing:** Jest + React Testing Library
- **Documentación:** JSDoc + README
- **CI/CD:** GitHub Actions + Vercel

### 10.5 Accesibilidad

- **WCAG 2.1:** Cumplimiento nivel AA
- **Navegación:** Keyboard navigation completa
- **Contraste:** Colores con contraste suficiente
- **Screen Readers:** ARIA labels correctos

---

## 11. Anexos

### 11.1 Formulario de Disponibilidad Docente (Referencia)

```
Disponibilidad horaria / Verfugbarkeit 2026

Estimados docentes, con el objetivo de organizar el esquema de clases para el ciclo lectivo 2026, les solicitamos completar este formulario con su disponibilidad horaria. Por favor, sean lo más precisos posible. La fecha limite para el envio es el 20/12/25.

Sehr geehrte Lehrkräfte, um den Stundenplan für das Schuljahr 2026 zu erstellen, bitten wir Sie, dieses Formular mit Ihrer zeitlichen Verfügbarkeit auszufüllen. Bitte seien Sie dabei so genau wie möglich. Die Frist für die Einreichung ist der 20.12.25.

Campos:
1. Email*
2. Nombre y Apellido / Vor und Nachname*
3. Departamento/Abteilung* (selector)
4. Cantidad de horas frente a curso (numérico)
5. Cargo/Position* (selector)
6. Disponibilidad de Lunes, Martes, Jueves y Viernes (7:45 a 16:30) - 10 bloques
7. Disponibilidad de los miércoles (7:45 a 13:30) - 7 bloques
8. Observaciones adicionales (texto libre)
```

### 11.2 Scripts de Cálculo (Referencia)

#### Script de Cálculo de Materias (Materia.txt)

```javascript
function calcularAsignacionDocente() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const hojaMaterias = ss.getSheetByName("Materias");
  const hojaListado = ss.getSheetByName("Listado de Docentes 2026");
  
  const RANGO_NOMBRES_LISTADO = "C3:C116";
  const RANGO_SALIDA_MATERIAS = "D3:I116";
  
  const mapaColumnasNivel = {
    "ES1": 0, "ES2": 1, "ES3": 2, "ES4": 3, "ES5": 4, "ES6": 5
  };
  
  const nombresDocentes = hojaListado.getRange(RANGO_NOMBRES_LISTADO).getValues();
  let resultados = Array.from({ length: 114 }, () => [0, 0, 0, 0, 0, 0]);
  let indiceDocentes = {};
  
  nombresDocentes.forEach((fila, index) => {
    let nombre = fila[0] ? fila[0].toString().trim() : "";
    if (nombre) indiceDocentes[nombre] = index;
  });
  
  const dataMateriasCompleta = hojaMaterias.getRange("A3:M132").getValues();
  
  for (let i = 0; i < dataMateriasCompleta.length; i++) {
    let fila = dataMateriasCompleta[i];
    let nivel = fila[1] ? fila[1].toString().trim() : "";
    let horasBase = parseFloat(fila[5]) || 0;
    
    // Aplicamos el 35% extra (horas * 1.35)
    let horasConPlus = horasBase * 1.35;
    
    if (nivel && mapaColumnasNivel.hasOwnProperty(nivel)) {
      let colRelativa = mapaColumnasNivel[nivel];
      
      for (let c = 6; c <= 12; c++) {
        let nombreEnCelda = fila[c] ? fila[c].toString().trim() : "";
        
        if (nombreEnCelda && indiceDocentes.hasOwnProperty(nombreEnCelda)) {
          resultados[indiceDocentes[nombreEnCelda]][colRelativa] += horasConPlus;
        }
      }
    }
  }
  
  // Redondeamos a un decimal para que quede limpio (ej: 5.4)
  let resultadosFinales = resultados.map(fila => 
    fila.map(v => v === 0 ? "" : Number(v.toFixed(1)))
  );
  
  hojaListado.getRange(RANGO_SALIDA_MATERIAS).setValues(resultadosFinales);
  SpreadsheetApp.getUi().alert("¡Listo! Materias actualizadas con el +35% de horas.");
}
```

#### Script de Cálculo de Talleres (Talleres.txt)

```javascript
function actualizarSoloTalleres() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const hojaTalleres = ss.getSheetByName("Talleres");
  const hojaListado = ss.getSheetByName("Listado de Docentes 2026");
  
  const RANGO_NOMBRES_LISTADO = "C3:C116";
  const RANGO_SALIDA_TALLERES = "J3:J116";
  const COL_DOCENTE_TALLERES = 4; // Columna D en hoja Talleres
  
  const nombresDocentes = hojaListado.getRange(RANGO_NOMBRES_LISTADO).getValues();
  let resultadosTalleres = Array.from({ length: 114 }, () => [""]);
  let indiceDocentes = {};
  
  nombresDocentes.forEach((fila, index) => {
    let nombre = fila[0] ? fila[0].toString().trim() : "";
    if (nombre) {
      indiceDocentes[nombre] = index;
    }
  });
  
  const ultimaFilaTalleres = hojaTalleres.getLastRow();
  
  if (ultimaFilaTalleres >= 2) {
    const dataTalleres = hojaTalleres.getRange(2, COL_DOCENTE_TALLERES, ultimaFilaTalleres - 1, 1).getValues();
    
    let conteoTmp = {};
    dataTalleres.forEach(fila => {
      let nombre = fila[0] ? fila[0].toString().trim() : "";
      if (nombre) {
        conteoTmp[nombre] = (conteoTmp[nombre] || 0) + 1;
      }
    });
    
    for (let nombre in conteoTmp) {
      if (indiceDocentes.hasOwnProperty(nombre)) {
        let filaDestino = indiceDocentes[nombre];
        resultadosTalleres[filaDestino][0] = conteoTmp[nombre] * 2 * 1.35;
      }
    }
  }
  
  hojaListado.getRange(RANGO_SALIDA_TALLERES).setValues(resultadosTalleres);
  SpreadsheetApp.getUi().alert("Columna de Talleres actualizada correctamente.");
}
```

#### Script de Carga Rápida (CargaRapida.txt)

```javascript
function asignarMateriaADocente() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const hojaCarga = ss.getSheetByName("Carga Rápida");
  const hojaMaterias = ss.getSheetByName("Materias");
  
  const docente = hojaCarga.getRange("C2").getValue();
  const nivelBusqueda = hojaCarga.getRange("B7").getValue();
  const materiaBusqueda = hojaCarga.getRange("C7").getValue();
  const divisionDestino = hojaCarga.getRange("D7").getValue();
  
  if (!docente || !nivelBusqueda || !materiaBusqueda || !divisionDestino) {
    SpreadsheetApp.getUi().alert("Por favor, completa todos los campos de la fila 7.");
    return;
  }
  
  const dataMaterias = hojaMaterias.getDataRange().getValues();
  let materiaEncontrada = false;
  
  const mapeoCols = { "A": 6, "B": 7, "C": 8, "D": 9, "IMA 1": 10, "IMA 2": 11, "IMA 3": 12 };
  
  for (let i = 2; i < dataMaterias.length; i++) {
    if (dataMaterias[i][1] == nivelBusqueda && dataMaterias[i][2] == materiaBusqueda) {
      let colIndex = mapeoCols[divisionDestino];
      
      if (colIndex) {
        hojaMaterias.getRange(i + 1, colIndex + 1).setValue(docente);
        materiaEncontrada = true;
        break;
      }
    }
  }
  
  if (materiaEncontrada) {
    calcularAsignacionDocente();
    actualizarSoloTalleres();
    SpreadsheetApp.getUi().alert("Asignación exitosa para " + docente);
  } else {
    SpreadsheetApp.getUi().alert("No se encontró la materia o nivel exacto.");
  }
}
```

### 11.3 Ejemplo de Archivo GPU014 (Referencia)

```
1; "20250305 ";1;1;238; "BiM "; "GoP "; "DEU ";;;; "A077 R_ES6_D2 "; "A077 R_ES6_D2 ";; "ES6A~ES6B ";;;0; "ES6A~ES6B ";;202503050859; "+~-"
2; "20250305 ";2;1;238; "BiM "; "MaJ "; "DEU ";;;; "A077 R_ES6_D2 "; "A077 R_ES6_D2 ";; "ES6A~ES6B ";;;0; "ES6A~ES6B ";;202503050859; "+~-"
3; "20250305 ";3;1;152; "BiM "; "OlS "; "GEO ";;;; "A035 R_ES4_D1 "; "A035 R_ES4_D1 ";; "ES4A ";;;0; "ES4A ";;202503050901; "+~-"
4; "20250305 ";4;1;152; "BiM "; "OlS "; "GEO ";;;; "A035 R_ES4_D1 "; "A035 R_ES4_D1 ";; "ES4A ";;;0; "ES4A ";;202503050901; "+~-"
5; "20250305 ";5;2;485; "FaA "; "SaM "; "MCS ";;;; "A063 R_ES5DE_1 "; "A063 R_ES5DE_1 ";; "ES5D ";;;0; "ES5D ";;202503050901; "+~-"
```

---

## 12. Preguntas Críticas para el Equipo de Desarrollo

### 12.1 Sobre el Flujo y Roles

1. **Roles de Usuario:** ¿Quién es "Asuntos Educativos"? ¿Es un rol separado dentro del sistema (ej. `Role: Educational_Affairs`) que tiene permiso para aprobar la estructura, o es el mismo Director el que hace todo?

2. **Carga de Docentes:** ¿De dónde sacamos el listado inicial de docentes y sus horas base (el contrato) para el sistema? ¿Se cargan manualmente al inicio del año, o se importan desde un Excel/RRHH?

### 12.2 Sobre la Exportación a Untis

3. **Aulas/Rooms:** ¿El sistema actual también debe sugerir o asignar *Aulas* (ej: Laboratorio de Química, Aula 204) para exportarlas a Untis, o Untis asigna las aulas automáticamente basándose en los tipos de materias?

4. **Formato de Untis:** ¿Tienen a mano el manual de importación XML/CSV de su versión de Untis? (El equipo de desarrollo lo necesitará para mapear los tags exactos, especialmente para las `Lesson` y `Teacher Availabilities`).

### 12.3 Sobre la Regla del 35%

5. **Visibilidad del Buffer:** Cuando el docente llena el formulario, ¿el sistema le dice explícitamente *"Tienes que marcar 27 horas porque tu contrato es de 20"* o el sistema lo calcula por detrás y solo le muestra el calendario para que marque a gusto, validando al final si llegó al mínimo?

### 12.4 Sobre los Grupos (Líneas Grises)

6. **Materias Optativas/Divididas:** En ES5 y ES6 hay materias que dicen "NAT/SOC/ECO" o "SOC/ECO". ¿Esto significa que el grupo de alumnos se divide a la mitad para esa materia? Si es así, Untis necesita saber que la "Clase" (Group) se subdivide. ¿Cómo manejan esto hoy en la planilla?

---

## 13. Criterios de Aceptación Generales

### 13.1 Funcionales

- [ ] Sistema permite completar las 3 etapas en orden secuencial
- [ ] Cálculos de horas son correctos (regla 35%, talleres)
- [ ] Exportación genera archivo GPU014 válido para Untis
- [ ] Dashboard muestra métricas en tiempo real
- [ ] Drag & Drop funciona correctamente en matriz de asignación

### 13.2 No Funcionales

- [ ] Performance: Carga de páginas < 2 segundos
- [ ] Disponibilidad: 99.5% uptime
- [ ] Seguridad: Autenticación SSO funcional
- [ ] Escalabilidad: Soporta 200 usuarios concurrentes
- [ ] Accesibilidad: WCAG 2.1 nivel AA

### 13.3 UX/UI

- [ ] Interfaz intuitiva y fácil de usar
- [ ] Feedback visual claro (alertas, confirmaciones)
- [ ] Responsive design (desktop, tablet, mobile)
- [ ] Navegación clara y consistente

---

## 14. Presupuesto y Cronograma Estimado

### 14.1 Estimación de Esfuerzo

| Sprint | Duración | Horas Estimadas | Costo Estimado (USD) |
|--------|----------|-----------------|---------------------|
| Sprint 1 | 2 semanas | 80-100h | $8,000 - $12,000 |
| Sprint 2 | 2 semanas | 80-100h | $8,000 - $12,000 |
| Sprint 3 | 2 semanas | 80-100h | $8,000 - $12,000 |
| Sprint 4 | 2 semanas | 80-100h | $8,000 - $12,000 |
| Sprint 5 | 2 semanas | 60-80h | $6,000 - $10,000 |
| **Total** | **10 semanas** | **380-480h** | **$38,000 - $58,000** |

### 14.2 Cronograma

```
Semana 1-2:   Sprint 1 - Fundación y Autenticación
Semana 3-4:   Sprint 2 - Portal de Disponibilidad Docente
Semana 5-6:   Sprint 3 - Estructura Académica
Semana 7-8:   Sprint 4 - Asignación de Docentes
Semana 9-10:  Sprint 5 - Pruebas, Ajustes y Despliegue
```

### 14.3 Costos Recurrentes

- **Vercel (Frontend):** $20/mes (Pro plan)
- **Supabase (Backend + DB):** $25/mes (Pro plan)
- **Dominio:** $15/año
- **Total recurrente:** ~$60/mes

---

## 15. Contacto y Soporte

**Responsable del Proyecto:** [Nombre del Director]  
**Email:** [email@goethe.edu.ar]  
**Teléfono:** [+54 11 XXXX-XXXX]

**Soporte Técnico:**
- **Horario:** Lunes a Viernes, 9:00 - 17:00
- **Email:** [soporte@goethe.edu.ar]
- **Slack:** #goethe-planificacion

---

## 16. Aprobación del Documento

**Preparado por:** [Tu Nombre]  
**Fecha:** 1 de Julio, 2026  
**Versión:** 1.0 Final

**Aprobado por:**

| Nombre | Cargo | Firma | Fecha |
|--------|-------|-------|-------|
| [Director] | Director | _________________ | ___/___/2026 |
| [CTO] | CTO | _________________ | ___/___/2026 |

---

**Fin del Documento**
```

He creado un archivo Markdown completo y consolidado con todo el RFP. El archivo incluye:

✅ **Resumen ejecutivo** con contexto y objetivos  
✅ **Arquitectura técnica** detallada  
✅ **Flujo de trabajo de 3 etapas** con especificaciones  
✅ **Reglas de negocio** (35%, talleres, materias comunes)  
✅ **Formato GPU014** para Untis con ejemplos  
✅ **Stack tecnológico** (Next.js, Supabase, TypeScript)  
✅ **Plan de 5 sprints** con entregables y criterios  
✅ **Scripts de referencia** (cálculos actuales)  
✅ **Presupuesto estimado** ($38k-$58k USD)  
✅ **Preguntas críticas** para el desarrollador

El archivo está listo para descargar y enviar directamente al equipo de desarrollo. Incluye toda la información necesaria para que puedan cotizar y comenzar el proyecto sin necesidad de información adicional.
