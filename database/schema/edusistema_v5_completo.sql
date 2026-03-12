-- ============================================================
-- EduSistema Pro v5 - Script SQL Completo
-- Archivo: database/edusistema_v5_completo.sql
-- 
-- Instrucciones:
-- 1. Crear base de datos 'edusistema_v5' en phpMyAdmin
-- 2. Seleccionar cotejamiento: utf8mb4_unicode_ci
-- 3. Importar este archivo completo
-- ============================================================

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- ============================================================
-- SECCIÓN 1: USUARIOS Y ROLES
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

-- ============================================================
-- SECCIÓN 2: MATERIAS Y PERIODOS
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

-- ============================================================
-- SECCIÓN 3: SALONES Y RELACIONES
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

-- ============================================================
-- SECCIÓN 4: SISTEMA DE NOTAS TRIPARTITAS
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

-- ============================================================
-- SECCIÓN 5: ASISTENCIAS Y EXCUSAS
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

-- ============================================================
-- SECCIÓN 6: ARCHIVOS Y TAREAS
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
  `archivo_base64` LONGTEXT NULL COMMENT 'Archivo codificado en Base64',
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

-- ============================================================
-- SECCIÓN 7: SISTEMA DE RECUPERACIONES
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

-- ============================================================
-- SECCIÓN 8: AUDITORÍA
-- ============================================================

-- Tabla: auditoria (registro de cambios)
CREATE TABLE IF NOT EXISTS `auditoria` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `timestamp` DATETIME NOT NULL,
  `usuario_id` VARCHAR(50) NULL,
  `usuario_nombre` VARCHAR(200) NOT NULL,
  `role` VARCHAR(20) NOT NULL,
  `estudiante_afectado` VARCHAR(200) NULL,
  `accion` TEXT NOT NULL,
  `campo` VARCHAR(100) NULL,
  `valor_anterior` VARCHAR(255) NULL,
  `valor_nuevo` VARCHAR(255) NULL,
  `extra` TEXT NULL,
  `ip_address` VARCHAR(45) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_timestamp (timestamp),
  INDEX idx_usuario (usuario_id),
  INDEX idx_role (role),
  INDEX idx_accion (accion(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SECCIÓN 9: VISTAS
-- ============================================================

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

-- Vista: Recuperaciones pendientes por profesor
CREATE OR REPLACE VIEW vista_recuperaciones_pendientes AS
SELECT 
    r.id,
    r.estudiante_nombre,
    r.materia,
    r.archivo_nombre,
    r.fecha_envio,
    r.profesor_id,
    p.titulo as plan_titulo
FROM recuperaciones r
LEFT JOIN planes_recuperacion p ON r.plan_id = p.id
WHERE r.revisado = 0
ORDER BY r.fecha_envio ASC;

-- Vista: Auditoría reciente (últimos 100 registros)
CREATE OR REPLACE VIEW vista_auditoria_reciente AS
SELECT 
    a.id,
    a.timestamp,
    a.usuario_nombre,
    a.role,
    a.estudiante_afectado,
    a.accion,
    a.ip_address
FROM auditoria a
ORDER BY a.timestamp DESC
LIMIT 100;

-- ============================================================
-- SECCIÓN 10: PROCEDIMIENTOS ALMACENADOS
-- ============================================================

DELIMITER //

-- Procedimiento: Calcular promedio de un estudiante en un periodo
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

-- Procedimiento: Obtener materias perdidas de un estudiante
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

-- ============================================================
-- SECCIÓN 11: TRIGGERS
-- ============================================================

-- Trigger: Auditar cambios en notas
DELIMITER //
CREATE TRIGGER audit_notas_update
AFTER UPDATE ON notas
FOR EACH ROW
BEGIN
    IF OLD.aptitud != NEW.aptitud OR OLD.actitud != NEW.actitud OR OLD.responsabilidad != NEW.responsabilidad THEN
        INSERT INTO auditoria (timestamp, usuario_id, usuario_nombre, role, estudiante_afectado, accion, extra)
        VALUES (
            NOW(),
            @current_user_id,
            @current_user_name,
            @current_user_role,
            (SELECT nombre FROM usuarios WHERE id = NEW.estudiante_id),
            CONCAT('Actualización de nota - ', NEW.materia, ' (', NEW.periodo, ')'),
            CONCAT('Anterior: A=', OLD.aptitud, ' C=', OLD.actitud, ' R=', OLD.responsabilidad, 
                   ' | Nuevo: A=', NEW.aptitud, ' C=', NEW.actitud, ' R=', NEW.responsabilidad)
        );
    END IF;
END//
DELIMITER ;

-- Trigger: Auditar bloqueos de usuarios
DELIMITER //
CREATE TRIGGER audit_usuario_bloqueado
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    IF OLD.blocked != NEW.blocked AND NEW.blocked = 1 THEN
        INSERT INTO auditoria (timestamp, usuario_id, usuario_nombre, role, accion, extra)
        VALUES (
            NOW(),
            'SYSTEM',
            'Sistema de Seguridad',
            'system',
            CONCAT('Usuario bloqueado: ', NEW.usuario),
            'Bloqueo automático por intentos fallidos de login'
        );
    END IF;
END//
DELIMITER ;

-- ============================================================
-- SECCIÓN 12: DATOS INICIALES
-- ============================================================

-- Usuario administrador
-- Contraseña: admin123 (hash SHA-256 con salt 'EduSistema_v5_2026')
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'admin',
  'Administrador',
  'CC-000001',
  'admin',
  '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
  'admin',
  1,
  0,
  CURDATE()
) ON DUPLICATE KEY UPDATE id=id;

-- Materias
INSERT INTO `materias` (`nombre`, `ciclo`) VALUES
('Matemáticas', 'ambos'),
('Lengua Castellana', 'primaria'),
('Español', 'bachillerato'),
('Ciencias Naturales', 'ambos'),
('Ciencias Sociales', 'ambos'),
('Ed. Artística', 'primaria'),
('Arte', 'bachillerato'),
('Ed. Física', 'ambos'),
('Ética', 'ambos'),
('Inglés', 'bachillerato'),
('Física', 'bachillerato'),
('Química', 'bachillerato')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Periodos académicos
INSERT INTO `periodos` (`nombre`, `orden`) VALUES
('Periodo 1', 1),
('Periodo 2', 2),
('Periodo 3', 3),
('Periodo 4', 4)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Salones de ejemplo
INSERT INTO `salones` (`nombre`, `ciclo`) VALUES
('1A', 'primaria'),
('2A', 'primaria'),
('3A', 'primaria'),
('4A', 'primaria'),
('5A', 'primaria'),
('6A', 'bachillerato'),
('7A', 'bachillerato'),
('8A', 'bachillerato'),
('9A', 'bachillerato'),
('10A', 'bachillerato'),
('11A', 'bachillerato')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- Configuración de fechas (año lectivo 2025)
INSERT INTO `configuracion_fechas` (`tipo`, `fecha_inicio`, `fecha_fin`, `activo`)
VALUES ('global', '2025-01-15', '2025-11-30', 1)
ON DUPLICATE KEY UPDATE activo=VALUES(activo);

INSERT INTO `configuracion_fechas` (`tipo`, `periodo_nombre`, `fecha_inicio`, `fecha_fin`, `activo`)
VALUES 
('periodo', 'Periodo 1', '2025-01-15', '2025-03-15', 1),
('periodo', 'Periodo 2', '2025-03-20', '2025-05-30', 1),
('periodo', 'Periodo 3', '2025-06-05', '2025-08-15', 1),
('periodo', 'Periodo 4', '2025-08-20', '2025-11-15', 1)
ON DUPLICATE KEY UPDATE activo=VALUES(activo);

INSERT INTO `configuracion_fechas` (`tipo`, `fecha_inicio`, `fecha_fin`, `periodo_ext_mapeo`, `activo`)
VALUES ('extraordinario', '2025-11-20', '2025-12-15', 'Periodo 4', 0)
ON DUPLICATE KEY UPDATE activo=VALUES(activo);

-- Registro en auditoría
INSERT INTO `auditoria` (`timestamp`, `usuario_id`, `usuario_nombre`, `role`, `accion`, `extra`, `ip_address`)
VALUES (
  NOW(),
  'admin',
  'Sistema',
  'system',
  'Base de datos inicializada',
  'Usuario admin, materias, periodos y salones creados',
  '127.0.0.1'
);

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================

SET FOREIGN_KEY_CHECKS=1;
COMMIT;

-- Información final
SELECT 'Base de datos inicializada correctamente' AS STATUS;
SELECT COUNT(*) AS total_materias FROM materias;
SELECT COUNT(*) AS total_periodos FROM periodos;
SELECT COUNT(*) AS total_salones FROM salones;
SELECT 'Login: admin / admin123' AS credenciales_iniciales;
