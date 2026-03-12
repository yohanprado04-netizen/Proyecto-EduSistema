-- ============================================================
-- EduSistema Pro v5 - Script 3: SALONES
-- Archivo: database/schema/03_salones.sql
-- ============================================================

-- Tabla: salones
CREATE TABLE IF NOT EXISTS `salones` (
  `nombre` VARCHAR(50) PRIMARY KEY,
  `ciclo` ENUM('primaria', 'bachillerato') NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_ciclo (ciclo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: salon_materias (materias propias del salón)
CREATE TABLE IF NOT EXISTS `salon_materias` (
  `salon_nombre` VARCHAR(50),
  `materia_nombre` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (salon_nombre, materia_nombre),
  FOREIGN KEY (salon_nombre) REFERENCES salones(nombre) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: profesor_salones (relación N:M)
CREATE TABLE IF NOT EXISTS `profesor_salones` (
  `profesor_id` VARCHAR(50),
  `salon_nombre` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (profesor_id, salon_nombre),
  FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE,
  FOREIGN KEY (salon_nombre) REFERENCES salones(nombre) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: profesor_salon_materias (materias específicas por salón)
CREATE TABLE IF NOT EXISTS `profesor_salon_materias` (
  `profesor_id` VARCHAR(50),
  `salon_nombre` VARCHAR(50),
  `materia_nombre` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (profesor_id, salon_nombre, materia_nombre),
  FOREIGN KEY (profesor_id) REFERENCES profesores(id) ON DELETE CASCADE,
  FOREIGN KEY (salon_nombre) REFERENCES salones(nombre) ON DELETE CASCADE,
  INDEX idx_profesor (profesor_id),
  INDEX idx_salon (salon_nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Actualizar tabla estudiantes con FK a salones
ALTER TABLE `estudiantes` 
ADD CONSTRAINT fk_estudiante_salon 
FOREIGN KEY (salon) REFERENCES salones(nombre) ON DELETE SET NULL;
