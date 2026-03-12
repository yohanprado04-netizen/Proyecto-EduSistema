-- ============================================================
-- EduSistema Pro v5 - Script 7: RECUPERACIONES
-- Archivo: database/schema/07_recuperaciones.sql
-- ============================================================

-- Tabla: planes_recuperacion (planes enviados por profesores)
CREATE TABLE IF NOT EXISTS `planes_recuperacion` (
  `id` VARCHAR(50) PRIMARY KEY,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) NULL,
  `materia` VARCHAR(100) NOT NULL,
  `profesor_id` VARCHAR(50) NOT NULL,
  `profesor_nombre` VARCHAR(200) NOT NULL,
  `titulo` VARCHAR(255) NOT NULL,
  `descripcion` TEXT NOT NULL,
  `fecha_limite` DATE NULL,
  `archivo_nombre` VARCHAR(255) NULL,
  `archivo_base64` LONGTEXT NULL,
  `archivo_ruta` VARCHAR(500) NULL,
  `archivo_tipo` VARCHAR(100) NULL,
  `fecha_envio` DATE NOT NULL,
  `visto` BOOLEAN DEFAULT 0,
  `es_grupal` BOOLEAN DEFAULT 0 COMMENT 'True si es para todo el salón',
  `plan_grupo_id` VARCHAR(50) NULL COMMENT 'ID compartido para planes grupales',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
  FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE,
  INDEX idx_estudiante (estudiante_id),
  INDEX idx_profesor (profesor_id),
  INDEX idx_materia (materia),
  INDEX idx_visto (visto),
  INDEX idx_es_grupal (es_grupal),
  INDEX idx_plan_grupo (plan_grupo_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: recuperaciones (respuestas de estudiantes)
CREATE TABLE IF NOT EXISTS `recuperaciones` (
  `id` VARCHAR(50) PRIMARY KEY,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) NULL,
  `materia` VARCHAR(100) NOT NULL,
  `profesor_id` VARCHAR(50) NOT NULL,
  `plan_id` VARCHAR(50) NULL COMMENT 'FK al plan de recuperación',
  `archivo_nombre` VARCHAR(255) NOT NULL,
  `archivo_tipo` VARCHAR(100) NULL,
  `archivo_base64` LONGTEXT NULL,
  `archivo_ruta` VARCHAR(500) NULL,
  `descripcion` TEXT NULL,
  `fecha_envio` DATE NOT NULL,
  `revisado` BOOLEAN DEFAULT 0,
  `fecha_revision` DATE NULL,
  `fecha_creacion` DATETIME NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
  FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE,
  FOREIGN KEY (plan_id) REFERENCES planes_recuperacion(id) ON DELETE SET NULL,
  INDEX idx_estudiante (estudiante_id),
  INDEX idx_profesor (profesor_id),
  INDEX idx_plan (plan_id),
  INDEX idx_revisado (revisado),
  INDEX idx_fecha_envio (fecha_envio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: historial_planes (planes archivados de periodos anteriores)
CREATE TABLE IF NOT EXISTS `historial_planes` (
  `id` VARCHAR(50) PRIMARY KEY,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) NULL,
  `materia` VARCHAR(100) NOT NULL,
  `profesor_id` VARCHAR(50) NOT NULL,
  `profesor_nombre` VARCHAR(200) NOT NULL,
  `titulo` VARCHAR(255) NOT NULL,
  `descripcion` TEXT NOT NULL,
  `fecha_limite` DATE NULL,
  `archivo_nombre` VARCHAR(255) NULL,
  `archivo_base64` LONGTEXT NULL,
  `archivo_ruta` VARCHAR(500) NULL,
  `archivo_tipo` VARCHAR(100) NULL,
  `fecha_envio` DATE NOT NULL,
  `visto` BOOLEAN DEFAULT 0,
  `es_grupal` BOOLEAN DEFAULT 0,
  `plan_grupo_id` VARCHAR(50) NULL,
  `periodo_extraordinario` VARCHAR(100) NOT NULL COMMENT 'Rango de fechas del periodo',
  `fecha_archivo` DATE NOT NULL COMMENT 'Fecha en que se archivó',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_estudiante (estudiante_id),
  INDEX idx_profesor (profesor_id),
  INDEX idx_periodo (periodo_extraordinario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: historial_recuperaciones (recuperaciones archivadas)
CREATE TABLE IF NOT EXISTS `historial_recuperaciones` (
  `id` VARCHAR(50) PRIMARY KEY,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) NULL,
  `materia` VARCHAR(100) NOT NULL,
  `profesor_id` VARCHAR(50) NOT NULL,
  `plan_id` VARCHAR(50) NULL,
  `archivo_nombre` VARCHAR(255) NOT NULL,
  `archivo_tipo` VARCHAR(100) NULL,
  `archivo_base64` LONGTEXT NULL,
  `archivo_ruta` VARCHAR(500) NULL,
  `descripcion` TEXT NULL,
  `fecha_envio` DATE NOT NULL,
  `revisado` BOOLEAN DEFAULT 0,
  `fecha_revision` DATE NULL,
  `fecha_creacion` DATETIME NOT NULL,
  `periodo_extraordinario` VARCHAR(100) NOT NULL,
  `fecha_archivo` DATE NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_estudiante (estudiante_id),
  INDEX idx_profesor (profesor_id),
  INDEX idx_periodo (periodo_extraordinario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Vista: Recuperaciones pendientes por profesor
CREATE OR REPLACE VIEW vista_recuperaciones_pendientes AS
SELECT 
    r.id,
    r.estudiante_nombre,
    r.materia,
    r.archivo_nombre,
    r.fecha_envio,
    r.profesor_id,
    r.profesor_id as profesor_nombre,
    p.titulo as plan_titulo
FROM recuperaciones r
LEFT JOIN planes_recuperacion p ON r.plan_id = p.id
WHERE r.revisado = 0
ORDER BY r.fecha_envio ASC;
