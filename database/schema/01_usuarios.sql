-- ============================================================
-- EduSistema Pro v5 - Script 1: USUARIOS
-- Archivo: database/schema/01_usuarios.sql
-- ============================================================

-- Tabla: usuarios (base para admin, profesores y estudiantes)
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` VARCHAR(50) PRIMARY KEY,
  `nombre` VARCHAR(200) NOT NULL,
  `ti` VARCHAR(50) NULL COMMENT 'Tarjeta de Identidad o Cédula',
  `usuario` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(64) NOT NULL COMMENT 'Hash SHA-256',
  `role` ENUM('admin', 'profe', 'est') NOT NULL,
  `activo` BOOLEAN DEFAULT 1,
  `blocked` BOOLEAN DEFAULT 0,
  `registrado` DATE NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_usuario (usuario),
  INDEX idx_role (role),
  INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: profesores (extiende usuarios)
CREATE TABLE IF NOT EXISTS `profesores` (
  `id` VARCHAR(50) PRIMARY KEY,
  `ciclo` ENUM('primaria', 'bachillerato') NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: estudiantes (extiende usuarios)
CREATE TABLE IF NOT EXISTS `estudiantes` (
  `id` VARCHAR(50) PRIMARY KEY,
  `salon` VARCHAR(50) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE,
  INDEX idx_salon (salon)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: usuarios_bloqueados
CREATE TABLE IF NOT EXISTS `usuarios_bloqueados` (
  `usuario` VARCHAR(100) PRIMARY KEY,
  `bloqueado` BOOLEAN DEFAULT 1,
  `fecha_bloqueo` DATETIME NOT NULL,
  `razon` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: historial_estudiantes (registro histórico)
CREATE TABLE IF NOT EXISTS `historial_estudiantes` (
  `id` VARCHAR(50) PRIMARY KEY,
  `nombre` VARCHAR(200) NOT NULL,
  `ti` VARCHAR(50) NULL,
  `salon` VARCHAR(50) NULL,
  `fecha_registro` DATE NOT NULL,
  `activo` BOOLEAN DEFAULT 1,
  `fecha_eliminacion` DATE NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE,
  INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
