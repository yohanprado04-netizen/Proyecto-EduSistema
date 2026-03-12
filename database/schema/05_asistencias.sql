-- ============================================================
-- EduSistema Pro v5 - Script 5: ASISTENCIAS Y EXCUSAS
-- Archivo: database/schema/05_asistencias.sql
-- ============================================================

-- Tabla: asistencias
CREATE TABLE IF NOT EXISTS `asistencias` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `salon` VARCHAR(50) NOT NULL,
  `fecha` DATE NOT NULL,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estado` ENUM('presente', 'ausente') DEFAULT 'presente',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_asistencia (salon, fecha, estudiante_id),
  FOREIGN KEY (salon) REFERENCES salones(nombre) ON DELETE CASCADE,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
  INDEX idx_salon_fecha (salon, fecha),
  INDEX idx_estudiante (estudiante_id),
  INDEX idx_fecha (fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: excusas
CREATE TABLE IF NOT EXISTS `excusas` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) NULL,
  `fecha_ausencia` DATE NOT NULL,
  `destinatario` VARCHAR(200) NOT NULL COMMENT 'Nombre del profesor o Administrador',
  `causa` ENUM(
    'Enfermedad / malestar',
    'Cita médica',
    'Duelo familiar',
    'Problemas de transporte',
    'Emergencia en el hogar',
    'Diligencia personal',
    'Problema con internet',
    'Otro motivo'
  ) NOT NULL,
  `descripcion` TEXT NULL,
  `fecha_envio` DATETIME NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
  INDEX idx_estudiante (estudiante_id),
  INDEX idx_fecha_ausencia (fecha_ausencia),
  INDEX idx_destinatario (destinatario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: clases_virtuales
CREATE TABLE IF NOT EXISTS `clases_virtuales` (
  `id` VARCHAR(50) PRIMARY KEY,
  `profesor_id` VARCHAR(50) NOT NULL,
  `profesor_nombre` VARCHAR(200) NOT NULL,
  `materias` TEXT NULL COMMENT 'Lista de materias separadas por coma',
  `salon` VARCHAR(50) NOT NULL,
  `fecha` DATE NOT NULL,
  `hora` TIME NOT NULL,
  `enlace` TEXT NOT NULL,
  `descripcion` TEXT NULL,
  `fecha_creacion` DATETIME NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE,
  FOREIGN KEY (salon) REFERENCES salones(nombre) ON DELETE CASCADE,
  INDEX idx_profesor (profesor_id),
  INDEX idx_salon (salon),
  INDEX idx_fecha (fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Vista: Resumen de asistencia por estudiante
CREATE OR REPLACE VIEW vista_resumen_asistencia AS
SELECT 
    estudiante_id,
    COUNT(*) as total_registros,
    SUM(CASE WHEN estado = 'presente' THEN 1 ELSE 0 END) as total_presente,
    SUM(CASE WHEN estado = 'ausente' THEN 1 ELSE 0 END) as total_ausente,
    ROUND((SUM(CASE WHEN estado = 'presente' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) as porcentaje_asistencia
FROM asistencias
GROUP BY estudiante_id;
