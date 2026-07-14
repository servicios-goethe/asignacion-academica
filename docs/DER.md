# DER inicial

El modelo se refinara junto con las reglas funcionales y cada migracion EF Core.

```mermaid
erDiagram
    CiclosLectivos ||--o{ PerfilesDocentes : contiene
    PerfilesDocentes ||--o{ PerfilesDocentesDepartamentos : integra
    Departamentos ||--o{ PerfilesDocentesDepartamentos : clasifica
    CiclosLectivos ||--o{ PresentacionesDisponibilidad : recibe
    PerfilesDocentes ||--o{ PresentacionesDisponibilidad : realiza
    PresentacionesDisponibilidad ||--o{ BloquesDisponibilidad : incluye
    CiclosLectivos ||--o{ EstructurasAcademicas : define
    CiclosLectivos ||--o{ DivisionesCiclo : habilita
    EstructurasAcademicas ||--o{ OfertasAcademicas : contiene
    OfertasAcademicas ||--o{ EspaciosCurriculares : aplica
    DivisionesCiclo ||--o{ EspaciosCurriculares : recibe
    EspaciosCurriculares ||--o{ AsignacionesDocentes : recibe
    PerfilesDocentes ||--o{ AsignacionesDocentes : ocupa
    CiclosLectivos ||--o{ ExportacionesUntis : genera

    CiclosLectivos {
      int Id PK
      int Anio UK
      string Estado
      datetime2 AperturaDisponibilidadUtc
      datetime2 CierreDisponibilidadUtc
    }
    PerfilesDocentes {
      int Id PK
      int CicloLectivoId FK
      string Email
      string NombreCompleto
      string Cargo
      decimal HorasFrenteCurso
    }
    Departamentos {
      int Id PK
      string Nombre UK
      bool Activo
    }
    PerfilesDocentesDepartamentos {
      int PerfilDocenteId PK, FK
      int DepartamentoId PK, FK
    }
    PresentacionesDisponibilidad {
      int Id PK
      int CicloLectivoId FK
      int PerfilDocenteId FK
      string Estado
      datetime2 FechaEnvioUtc
      string Observaciones
    }
    BloquesDisponibilidad {
      int Id PK
      int PresentacionDisponibilidadId FK
      int DiaSemana
      time HoraInicio
      time HoraFin
    }
    EstructurasAcademicas {
      int Id PK
      int CicloLectivoId FK
      string Estado
    }
    DivisionesCiclo {
      int Id PK
      int CicloLectivoId FK
      string Curso
      string Nombre
      int Orden
      bool Activo
    }
    OfertasAcademicas {
      int Id PK
      int EstructuraAcademicaId FK
      string Curso
      string Modalidad
      string Materia
      decimal HorasCatedra45
      int Orden
      bool Activo
    }
    EspaciosCurriculares {
      int Id PK
      int OfertaAcademicaId FK
      int DivisionCicloId FK
      decimal HorasCatedra45
      string CodigoUntis
      bool Activo
    }
    AsignacionesDocentes {
      int Id PK
      int EspacioCurricularId FK
      int PerfilDocenteId FK
      decimal HorasAsignadas
    }
    ExportacionesUntis {
      int Id PK
      int CicloLectivoId FK
      string HashSha256
      string GeneradaPor
      datetime2 FechaGeneracionUtc
    }
```

`Usuarios` mantiene roles privilegiados; la autoalta docente se materializa en `PerfilesDocentes`. Cada perfil puede vincularse con varios `Departamentos` mediante una relacion muchos-a-muchos. `OfertasAcademicas` representa las filas de la matriz y `EspaciosCurriculares` solo sus celdas aplicables; una celda sin registro equivale a "No aplica". `Auditoria` es append-only y referencia actores por email.
