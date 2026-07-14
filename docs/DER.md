# DER inicial

El modelo se refinara junto con las reglas funcionales y cada migracion EF Core.

```mermaid
erDiagram
    CiclosLectivos ||--o{ PerfilesDocentes : contiene
    CiclosLectivos ||--o{ PresentacionesDisponibilidad : recibe
    PerfilesDocentes ||--o{ PresentacionesDisponibilidad : realiza
    PresentacionesDisponibilidad ||--o{ BloquesDisponibilidad : incluye
    CiclosLectivos ||--o{ EstructurasAcademicas : define
    EstructurasAcademicas ||--o{ EspaciosCurriculares : contiene
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
      string Departamento
      string Cargo
      decimal HorasFrenteCurso
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
    EspaciosCurriculares {
      int Id PK
      int EstructuraAcademicaId FK
      string Nivel
      string DivisionGrupo
      string Materia
      decimal HorasCatedra
      string CodigoUntis
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

`Usuarios` mantiene roles privilegiados; la autoalta docente se materializa en `PerfilesDocentes`. `Auditoria` es append-only y referencia actores por email.

