-- ============================================================
-- EduSistema Pro v5 - Script 2: MATERIAS Y SALONES
-- Archivo: database/schema/02_materias.sql
-- ============================================================

-- Tabla: materias
CREATE TABLE IF NOT EXISTS `materias` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(100) NOT NULL UNIQUE,
  `ciclo` ENUM('primaria', 'bachillerato', 'ambos') DEFAULT 'ambos',
  `activo` BOOLEAN DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_ciclo (ciclo),
  INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: periodos
CREATE TABLE IF NOT EXISTS `periodos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(50) NOT NULL UNIQUE,
  `orden` INT NOT NULL,
  `activo` BOOLEAN DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_orden (orden),
  INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
