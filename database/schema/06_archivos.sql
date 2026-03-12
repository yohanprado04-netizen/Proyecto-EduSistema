-- ============================================================
-- EduSistema Pro v5 - Script 6: ARCHIVOS Y TAREAS
-- Archivo: database/schema/06_archivos.sql
-- ============================================================

-- Tabla: archivos_subidos (tareas de estudiantes)
CREATE TABLE IF NOT EXISTS `archivos_subidos` (
  `id` VARCHAR(50) PRIMARY KEY,
  `nombre` VARCHAR(255) NOT NULL,
  `materia` VARCHAR(100) NOT NULL,
  `periodo` VARCHAR(50) NOT NULL,
  `profesor_id` VARCHAR(50) NULL,
  `profesor_nombre` VARCHAR(200) NULL,
  `descripcion` TEXT NULL,
  `fecha` DATE NOT NULL,
  `tamanio` INT NULL COMMENT 'Tamaño en bytes',
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `tipo_mime` VARCHAR(100) NULL,
  `archivo_base64` LONGTEXT NULL COMMENT 'Archivo codificado en Base64 - considerar almacenamiento externo',
  `archivo_ruta` VARCHAR(500) NULL COMMENT 'Ruta del archivo si se almacena en filesystem',
  `revisado` BOOLEAN DEFAULT 0,
  `fecha_revision` DATE NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
  FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE SET NULL,
  INDEX idx_estudiante (estudiante_id),
  INDEX idx_profesor (profesor_id),
  INDEX idx_materia (materia),
  INDEX idx_periodo (periodo),
  INDEX idx_revisado (revisado),
  INDEX idx_fecha (fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Vista: Archivos pendientes de revisión por profesor
CREATE OR REPLACE VIEW vista_archivos_pendientes AS
SELECT 
    a.id,
    a.nombre,
    a.materia,
    a.periodo,
    a.estudiante_nombre,
    a.fecha,
    a.profesor_id,
    a.profesor_nombre
FROM archivos_subidos a
WHERE a.revisado = 0
ORDER BY a.fecha ASC;
