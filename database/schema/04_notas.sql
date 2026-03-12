-- ============================================================
-- EduSistema Pro v5 - Script 4: NOTAS TRIPARTITAS
-- Archivo: database/schema/04_notas.sql
-- ============================================================

-- Tabla: notas (sistema tripartita)
CREATE TABLE IF NOT EXISTS `notas` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `periodo` VARCHAR(50) NOT NULL,
  `materia` VARCHAR(100) NOT NULL,
  `aptitud` DECIMAL(3,2) DEFAULT 0.00 CHECK (aptitud >= 0 AND aptitud <= 5),
  `actitud` DECIMAL(3,2) DEFAULT 0.00 CHECK (actitud >= 0 AND actitud <= 5),
  `responsabilidad` DECIMAL(3,2) DEFAULT 0.00 CHECK (responsabilidad >= 0 AND responsabilidad <= 5),
  `definitiva` DECIMAL(3,2) GENERATED ALWAYS AS (
    (aptitud * 0.6) + (actitud * 0.2) + (responsabilidad * 0.2)
  ) STORED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_nota (estudiante_id, periodo, materia),
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
  INDEX idx_estudiante (estudiante_id),
  INDEX idx_periodo (periodo),
  INDEX idx_materia (materia),
  INDEX idx_definitiva (definitiva)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: disciplina (por estudiante)
CREATE TABLE IF NOT EXISTS `disciplina` (
  `estudiante_id` VARCHAR(50) PRIMARY KEY,
  `disciplina` ENUM('Excelente', 'Bueno', 'Regular', 'Deficiente') DEFAULT 'Bueno',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: configuracion_fechas (control de rangos de notas)
CREATE TABLE IF NOT EXISTS `configuracion_fechas` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `tipo` ENUM('global', 'periodo', 'extraordinario') NOT NULL,
  `periodo_nombre` VARCHAR(50) NULL,
  `fecha_inicio` DATE NULL,
  `fecha_fin` DATE NULL,
  `periodo_ext_mapeo` VARCHAR(50) NULL COMMENT 'A qué periodo van las notas del periodo extraordinario',
  `activo` BOOLEAN DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_tipo (tipo),
  INDEX idx_periodo (periodo_nombre),
  INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Vista: Promedio por estudiante y periodo
CREATE OR REPLACE VIEW vista_promedios_periodo AS
SELECT 
    estudiante_id,
    periodo,
    AVG(definitiva) as promedio_periodo,
    COUNT(*) as total_materias,
    SUM(CASE WHEN definitiva < 3.0 THEN 1 ELSE 0 END) as materias_perdidas
FROM notas
WHERE definitiva > 0
GROUP BY estudiante_id, periodo;

-- Vista: Promedio general por estudiante
CREATE OR REPLACE VIEW vista_promedios_general AS
SELECT 
    estudiante_id,
    AVG(promedio_periodo) as promedio_general,
    SUM(materias_perdidas) as total_perdidas
FROM vista_promedios_periodo
GROUP BY estudiante_id;

-- Procedimiento: Calcular promedio de un estudiante en un periodo
DELIMITER //
CREATE PROCEDURE calcular_promedio_estudiante(
    IN p_estudiante_id VARCHAR(50),
    IN p_periodo VARCHAR(50)
)
BEGIN
    SELECT AVG(definitiva) as promedio
    FROM notas
    WHERE estudiante_id = p_estudiante_id 
    AND periodo = p_periodo
    AND definitiva > 0;
END //
DELIMITER ;

-- Procedimiento: Obtener materias perdidas de un estudiante
DELIMITER //
CREATE PROCEDURE obtener_materias_perdidas(
    IN p_estudiante_id VARCHAR(50)
)
BEGIN
    SELECT 
        materia,
        AVG(definitiva) as promedio_materia
    FROM notas
    WHERE estudiante_id = p_estudiante_id
    AND definitiva > 0
    GROUP BY materia
    HAVING AVG(definitiva) < 3.0;
END //
DELIMITER ;
