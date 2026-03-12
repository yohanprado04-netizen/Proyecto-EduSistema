-- ============================================================
-- EduSistema Pro v5 - Script SQL Completo
-- Creación de Base de Datos + Todas las Tablas
-- 
-- INSTRUCCIONES PARA phpMyAdmin:
-- 1. NO seleccionar ninguna base de datos
-- 2. Ir a pestaña "SQL"
-- 3. Pegar este script completo
-- 4. Click en "Continuar"
-- 
-- Este script:
-- - Elimina la BD si existe (CUIDADO: borra todo)
-- - Crea la BD nueva
-- - Crea las 23 tablas
-- - Agrega índices y claves foráneas
-- - Inserta datos iniciales
-- ============================================================

-- ============================================================
-- PASO 1: ELIMINAR BD EXISTENTE (si existe) Y CREAR NUEVA
-- ============================================================

DROP DATABASE IF EXISTS `edusistema_v5`;

CREATE DATABASE `edusistema_v5` 
  DEFAULT CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE `edusistema_v5`;

-- ============================================================
-- PASO 2: CONFIGURACIÓN INICIAL
-- ============================================================

SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- ============================================================
-- SECCIÓN 1: TABLAS DE USUARIOS Y ROLES
-- ============================================================

-- Tabla: usuarios (base común para admin, profesores y estudiantes)
CREATE TABLE `usuarios` (
  `id` VARCHAR(50) NOT NULL,
  `nombre` VARCHAR(200) NOT NULL,
  `ti` VARCHAR(50) DEFAULT NULL COMMENT 'Tarjeta de Identidad o Cédula',
  `usuario` VARCHAR(100) NOT NULL,
  `password` VARCHAR(64) NOT NULL COMMENT 'Hash SHA-256 con salt',
  `role` ENUM('admin','profe','est') NOT NULL,
  `activo` TINYINT(1) DEFAULT 1,
  `blocked` TINYINT(1) DEFAULT 0,
  `registrado` DATE DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuario` (`usuario`),
  KEY `idx_usuario` (`usuario`),
  KEY `idx_role` (`role`),
  KEY `idx_activo` (`activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: profesores (extiende usuarios)
CREATE TABLE `profesores` (
  `id` VARCHAR(50) NOT NULL,
  `ciclo` ENUM('primaria','bachillerato') NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_profesor_usuario` FOREIGN KEY (`id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: estudiantes (extiende usuarios)
CREATE TABLE `estudiantes` (
  `id` VARCHAR(50) NOT NULL,
  `salon` VARCHAR(50) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_salon` (`salon`),
  CONSTRAINT `fk_estudiante_usuario` FOREIGN KEY (`id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: usuarios_bloqueados
CREATE TABLE `usuarios_bloqueados` (
  `usuario` VARCHAR(100) NOT NULL,
  `bloqueado` TINYINT(1) DEFAULT 1,
  `fecha_bloqueo` DATETIME NOT NULL,
  `razon` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: historial_estudiantes (registro histórico de altas/bajas)
CREATE TABLE `historial_estudiantes` (
  `id` VARCHAR(50) NOT NULL,
  `nombre` VARCHAR(200) NOT NULL,
  `ti` VARCHAR(50) DEFAULT NULL,
  `salon` VARCHAR(50) DEFAULT NULL,
  `fecha_registro` DATE NOT NULL,
  `activo` TINYINT(1) DEFAULT 1,
  `fecha_eliminacion` DATE DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_activo` (`activo`),
  CONSTRAINT `fk_hist_estudiante` FOREIGN KEY (`id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SECCIÓN 2: TABLAS DE MATERIAS Y PERIODOS
-- ============================================================

-- Tabla: materias
CREATE TABLE `materias` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `ciclo` ENUM('primaria','bachillerato','ambos') DEFAULT 'ambos',
  `activo` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`),
  KEY `idx_ciclo` (`ciclo`),
  KEY `idx_activo` (`activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: periodos
CREATE TABLE `periodos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(50) NOT NULL,
  `orden` INT NOT NULL,
  `activo` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`),
  KEY `idx_orden` (`orden`),
  KEY `idx_activo` (`activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SECCIÓN 3: TABLAS DE SALONES Y RELACIONES
-- ============================================================

-- Tabla: salones
CREATE TABLE `salones` (
  `nombre` VARCHAR(50) NOT NULL,
  `ciclo` ENUM('primaria','bachillerato') NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`nombre`),
  KEY `idx_ciclo` (`ciclo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: salon_materias (materias propias del salón)
CREATE TABLE `salon_materias` (
  `salon_nombre` VARCHAR(50) NOT NULL,
  `materia_nombre` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`salon_nombre`,`materia_nombre`),
  CONSTRAINT `fk_salon_mat_salon` FOREIGN KEY (`salon_nombre`) REFERENCES `salones` (`nombre`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: profesor_salones (relación N:M entre profesores y salones)
CREATE TABLE `profesor_salones` (
  `profesor_id` VARCHAR(50) NOT NULL,
  `salon_nombre` VARCHAR(50) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`profesor_id`,`salon_nombre`),
  KEY `fk_prof_salon_salon` (`salon_nombre`),
  CONSTRAINT `fk_prof_salon_prof` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_prof_salon_salon` FOREIGN KEY (`salon_nombre`) REFERENCES `salones` (`nombre`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: profesor_salon_materias (materias que un profesor da en un salón específico)
CREATE TABLE `profesor_salon_materias` (
  `profesor_id` VARCHAR(50) NOT NULL,
  `salon_nombre` VARCHAR(50) NOT NULL,
  `materia_nombre` VARCHAR(100) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`profesor_id`,`salon_nombre`,`materia_nombre`),
  KEY `idx_profesor` (`profesor_id`),
  KEY `idx_salon` (`salon_nombre`),
  CONSTRAINT `fk_psm_profesor` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_psm_salon` FOREIGN KEY (`salon_nombre`) REFERENCES `salones` (`nombre`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Agregar FK de estudiantes a salones (ahora que salones ya existe)
ALTER TABLE `estudiantes` 
  ADD CONSTRAINT `fk_estudiante_salon` 
  FOREIGN KEY (`salon`) REFERENCES `salones` (`nombre`) ON DELETE SET NULL;

-- ============================================================
-- SECCIÓN 4: SISTEMA DE NOTAS TRIPARTITAS
-- ============================================================

-- Tabla: notas (sistema tripartita con campo calculado)
CREATE TABLE `notas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `periodo` VARCHAR(50) NOT NULL,
  `materia` VARCHAR(100) NOT NULL,
  `aptitud` DECIMAL(3,2) DEFAULT 0.00 CHECK (`aptitud` >= 0 AND `aptitud` <= 5),
  `actitud` DECIMAL(3,2) DEFAULT 0.00 CHECK (`actitud` >= 0 AND `actitud` <= 5),
  `responsabilidad` DECIMAL(3,2) DEFAULT 0.00 CHECK (`responsabilidad` >= 0 AND `responsabilidad` <= 5),
  `definitiva` DECIMAL(3,2) GENERATED ALWAYS AS ((`aptitud` * 0.6) + (`actitud` * 0.2) + (`responsabilidad` * 0.2)) STORED,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_nota` (`estudiante_id`,`periodo`,`materia`),
  KEY `idx_estudiante` (`estudiante_id`),
  KEY `idx_periodo` (`periodo`),
  KEY `idx_materia` (`materia`),
  KEY `idx_definitiva` (`definitiva`),
  CONSTRAINT `fk_nota_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: disciplina (comportamiento por estudiante)
CREATE TABLE `disciplina` (
  `estudiante_id` VARCHAR(50) NOT NULL,
  `disciplina` ENUM('Excelente','Bueno','Regular','Deficiente') DEFAULT 'Bueno',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`estudiante_id`),
  CONSTRAINT `fk_disciplina_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: configuracion_fechas (control de rangos de ingreso de notas)
CREATE TABLE `configuracion_fechas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `tipo` ENUM('global','periodo','extraordinario') NOT NULL,
  `periodo_nombre` VARCHAR(50) DEFAULT NULL,
  `fecha_inicio` DATE DEFAULT NULL,
  `fecha_fin` DATE DEFAULT NULL,
  `periodo_ext_mapeo` VARCHAR(50) DEFAULT NULL COMMENT 'A qué periodo van las notas del extraordinario',
  `activo` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tipo` (`tipo`),
  KEY `idx_periodo` (`periodo_nombre`),
  KEY `idx_activo` (`activo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SECCIÓN 5: ASISTENCIAS, EXCUSAS Y CLASES VIRTUALES
-- ============================================================

-- Tabla: asistencias
CREATE TABLE `asistencias` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `salon` VARCHAR(50) NOT NULL,
  `fecha` DATE NOT NULL,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estado` ENUM('presente','ausente') DEFAULT 'presente',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_asistencia` (`salon`,`fecha`,`estudiante_id`),
  KEY `idx_salon_fecha` (`salon`,`fecha`),
  KEY `idx_estudiante` (`estudiante_id`),
  KEY `idx_fecha` (`fecha`),
  CONSTRAINT `fk_asist_salon` FOREIGN KEY (`salon`) REFERENCES `salones` (`nombre`) ON DELETE CASCADE,
  CONSTRAINT `fk_asist_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: excusas
CREATE TABLE `excusas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) DEFAULT NULL,
  `fecha_ausencia` DATE NOT NULL,
  `destinatario` VARCHAR(200) NOT NULL COMMENT 'Nombre del profesor o Administrador',
  `causa` ENUM('Enfermedad / malestar','Cita médica','Duelo familiar','Problemas de transporte','Emergencia en el hogar','Diligencia personal','Problema con internet','Otro motivo') NOT NULL,
  `descripcion` TEXT DEFAULT NULL,
  `fecha_envio` DATETIME NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_estudiante` (`estudiante_id`),
  KEY `idx_fecha_ausencia` (`fecha_ausencia`),
  KEY `idx_destinatario` (`destinatario`),
  CONSTRAINT `fk_excusa_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: clases_virtuales
CREATE TABLE `clases_virtuales` (
  `id` VARCHAR(50) NOT NULL,
  `profesor_id` VARCHAR(50) NOT NULL,
  `profesor_nombre` VARCHAR(200) NOT NULL,
  `materias` TEXT DEFAULT NULL COMMENT 'Lista de materias separadas por coma',
  `salon` VARCHAR(50) NOT NULL,
  `fecha` DATE NOT NULL,
  `hora` TIME NOT NULL,
  `enlace` TEXT NOT NULL,
  `descripcion` TEXT DEFAULT NULL,
  `fecha_creacion` DATETIME NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_profesor` (`profesor_id`),
  KEY `idx_salon` (`salon`),
  KEY `idx_fecha` (`fecha`),
  CONSTRAINT `fk_vclase_profesor` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vclase_salon` FOREIGN KEY (`salon`) REFERENCES `salones` (`nombre`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SECCIÓN 6: ARCHIVOS Y TAREAS
-- ============================================================

-- Tabla: archivos_subidos (tareas de estudiantes)
CREATE TABLE `archivos_subidos` (
  `id` VARCHAR(50) NOT NULL,
  `nombre` VARCHAR(255) NOT NULL,
  `materia` VARCHAR(100) NOT NULL,
  `periodo` VARCHAR(50) NOT NULL,
  `profesor_id` VARCHAR(50) DEFAULT NULL,
  `profesor_nombre` VARCHAR(200) DEFAULT NULL,
  `descripcion` TEXT DEFAULT NULL,
  `fecha` DATE NOT NULL,
  `tamanio` INT DEFAULT NULL COMMENT 'Tamaño en bytes',
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `tipo_mime` VARCHAR(100) DEFAULT NULL,
  `archivo_base64` LONGTEXT DEFAULT NULL COMMENT 'Archivo codificado en Base64',
  `archivo_ruta` VARCHAR(500) DEFAULT NULL COMMENT 'Ruta si se almacena en filesystem',
  `revisado` TINYINT(1) DEFAULT 0,
  `fecha_revision` DATE DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_estudiante` (`estudiante_id`),
  KEY `idx_profesor` (`profesor_id`),
  KEY `idx_materia` (`materia`),
  KEY `idx_periodo` (`periodo`),
  KEY `idx_revisado` (`revisado`),
  KEY `idx_fecha` (`fecha`),
  CONSTRAINT `fk_archivo_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_archivo_profesor` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SECCIÓN 7: SISTEMA DE RECUPERACIONES
-- ============================================================

-- Tabla: planes_recuperacion (planes enviados por profesores)
CREATE TABLE `planes_recuperacion` (
  `id` VARCHAR(50) NOT NULL,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) DEFAULT NULL,
  `materia` VARCHAR(100) NOT NULL,
  `profesor_id` VARCHAR(50) NOT NULL,
  `profesor_nombre` VARCHAR(200) NOT NULL,
  `titulo` VARCHAR(255) NOT NULL,
  `descripcion` TEXT NOT NULL,
  `fecha_limite` DATE DEFAULT NULL,
  `archivo_nombre` VARCHAR(255) DEFAULT NULL,
  `archivo_base64` LONGTEXT DEFAULT NULL,
  `archivo_ruta` VARCHAR(500) DEFAULT NULL,
  `archivo_tipo` VARCHAR(100) DEFAULT NULL,
  `fecha_envio` DATE NOT NULL,
  `visto` TINYINT(1) DEFAULT 0,
  `es_grupal` TINYINT(1) DEFAULT 0 COMMENT 'True si es para todo el salón',
  `plan_grupo_id` VARCHAR(50) DEFAULT NULL COMMENT 'ID compartido para planes grupales',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_estudiante` (`estudiante_id`),
  KEY `idx_profesor` (`profesor_id`),
  KEY `idx_materia` (`materia`),
  KEY `idx_visto` (`visto`),
  KEY `idx_es_grupal` (`es_grupal`),
  KEY `idx_plan_grupo` (`plan_grupo_id`),
  CONSTRAINT `fk_plan_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_plan_profesor` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: recuperaciones (respuestas de estudiantes a planes)
CREATE TABLE `recuperaciones` (
  `id` VARCHAR(50) NOT NULL,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) DEFAULT NULL,
  `materia` VARCHAR(100) NOT NULL,
  `profesor_id` VARCHAR(50) NOT NULL,
  `plan_id` VARCHAR(50) DEFAULT NULL COMMENT 'FK al plan de recuperación',
  `archivo_nombre` VARCHAR(255) NOT NULL,
  `archivo_tipo` VARCHAR(100) DEFAULT NULL,
  `archivo_base64` LONGTEXT DEFAULT NULL,
  `archivo_ruta` VARCHAR(500) DEFAULT NULL,
  `descripcion` TEXT DEFAULT NULL,
  `fecha_envio` DATE NOT NULL,
  `revisado` TINYINT(1) DEFAULT 0,
  `fecha_revision` DATE DEFAULT NULL,
  `fecha_creacion` DATETIME NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_estudiante` (`estudiante_id`),
  KEY `idx_profesor` (`profesor_id`),
  KEY `idx_plan` (`plan_id`),
  KEY `idx_revisado` (`revisado`),
  KEY `idx_fecha_envio` (`fecha_envio`),
  CONSTRAINT `fk_rec_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiantes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rec_profesor` FOREIGN KEY (`profesor_id`) REFERENCES `profesores` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rec_plan` FOREIGN KEY (`plan_id`) REFERENCES `planes_recuperacion` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: historial_planes (planes archivados de periodos anteriores)
CREATE TABLE `historial_planes` (
  `id` VARCHAR(50) NOT NULL,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) DEFAULT NULL,
  `materia` VARCHAR(100) NOT NULL,
  `profesor_id` VARCHAR(50) NOT NULL,
  `profesor_nombre` VARCHAR(200) NOT NULL,
  `titulo` VARCHAR(255) NOT NULL,
  `descripcion` TEXT NOT NULL,
  `fecha_limite` DATE DEFAULT NULL,
  `archivo_nombre` VARCHAR(255) DEFAULT NULL,
  `archivo_base64` LONGTEXT DEFAULT NULL,
  `archivo_ruta` VARCHAR(500) DEFAULT NULL,
  `archivo_tipo` VARCHAR(100) DEFAULT NULL,
  `fecha_envio` DATE NOT NULL,
  `visto` TINYINT(1) DEFAULT 0,
  `es_grupal` TINYINT(1) DEFAULT 0,
  `plan_grupo_id` VARCHAR(50) DEFAULT NULL,
  `periodo_extraordinario` VARCHAR(100) NOT NULL COMMENT 'Rango de fechas del periodo',
  `fecha_archivo` DATE NOT NULL COMMENT 'Fecha en que se archivó',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_estudiante` (`estudiante_id`),
  KEY `idx_profesor` (`profesor_id`),
  KEY `idx_periodo` (`periodo_extraordinario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: historial_recuperaciones (recuperaciones archivadas)
CREATE TABLE `historial_recuperaciones` (
  `id` VARCHAR(50) NOT NULL,
  `estudiante_id` VARCHAR(50) NOT NULL,
  `estudiante_nombre` VARCHAR(200) NOT NULL,
  `salon` VARCHAR(50) DEFAULT NULL,
  `materia` VARCHAR(100) NOT NULL,
  `profesor_id` VARCHAR(50) NOT NULL,
  `plan_id` VARCHAR(50) DEFAULT NULL,
  `archivo_nombre` VARCHAR(255) NOT NULL,
  `archivo_tipo` VARCHAR(100) DEFAULT NULL,
  `archivo_base64` LONGTEXT DEFAULT NULL,
  `archivo_ruta` VARCHAR(500) DEFAULT NULL,
  `descripcion` TEXT DEFAULT NULL,
  `fecha_envio` DATE NOT NULL,
  `revisado` TINYINT(1) DEFAULT 0,
  `fecha_revision` DATE DEFAULT NULL,
  `fecha_creacion` DATETIME NOT NULL,
  `periodo_extraordinario` VARCHAR(100) NOT NULL,
  `fecha_archivo` DATE NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_estudiante` (`estudiante_id`),
  KEY `idx_profesor` (`profesor_id`),
  KEY `idx_periodo` (`periodo_extraordinario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SECCIÓN 8: AUDITORÍA
-- ============================================================

-- Tabla: auditoria (registro de cambios y acciones sensibles)
CREATE TABLE `auditoria` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `timestamp` DATETIME NOT NULL,
  `usuario_id` VARCHAR(50) DEFAULT NULL,
  `usuario_nombre` VARCHAR(200) NOT NULL,
  `role` VARCHAR(20) NOT NULL,
  `estudiante_afectado` VARCHAR(200) DEFAULT NULL,
  `accion` TEXT NOT NULL,
  `campo` VARCHAR(100) DEFAULT NULL,
  `valor_anterior` VARCHAR(255) DEFAULT NULL,
  `valor_nuevo` VARCHAR(255) DEFAULT NULL,
  `extra` TEXT DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `idx_usuario` (`usuario_id`),
  KEY `idx_role` (`role`),
  KEY `idx_accion` (`accion`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SECCIÓN 9: VISTAS
-- ============================================================

-- Vista: Promedio por estudiante y periodo
CREATE OR REPLACE VIEW `vista_promedios_periodo` AS
SELECT 
    `estudiante_id`,
    `periodo`,
    AVG(`definitiva`) AS `promedio_periodo`,
    COUNT(*) AS `total_materias`,
    SUM(CASE WHEN `definitiva` < 3.0 THEN 1 ELSE 0 END) AS `materias_perdidas`
FROM `notas`
WHERE `definitiva` > 0
GROUP BY `estudiante_id`, `periodo`;

-- Vista: Promedio general por estudiante
CREATE OR REPLACE VIEW `vista_promedios_general` AS
SELECT 
    `estudiante_id`,
    AVG(`promedio_periodo`) AS `promedio_general`,
    SUM(`materias_perdidas`) AS `total_perdidas`
FROM `vista_promedios_periodo`
GROUP BY `estudiante_id`;

-- Vista: Resumen de asistencia por estudiante
CREATE OR REPLACE VIEW `vista_resumen_asistencia` AS
SELECT 
    `estudiante_id`,
    COUNT(*) AS `total_registros`,
    SUM(CASE WHEN `estado` = 'presente' THEN 1 ELSE 0 END) AS `total_presente`,
    SUM(CASE WHEN `estado` = 'ausente' THEN 1 ELSE 0 END) AS `total_ausente`,
    ROUND((SUM(CASE WHEN `estado` = 'presente' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS `porcentaje_asistencia`
FROM `asistencias`
GROUP BY `estudiante_id`;

-- Vista: Archivos pendientes de revisión por profesor
CREATE OR REPLACE VIEW `vista_archivos_pendientes` AS
SELECT 
    a.`id`,
    a.`nombre`,
    a.`materia`,
    a.`periodo`,
    a.`estudiante_nombre`,
    a.`fecha`,
    a.`profesor_id`,
    a.`profesor_nombre`
FROM `archivos_subidos` a
WHERE a.`revisado` = 0
ORDER BY a.`fecha` ASC;

-- Vista: Recuperaciones pendientes por profesor
CREATE OR REPLACE VIEW `vista_recuperaciones_pendientes` AS
SELECT 
    r.`id`,
    r.`estudiante_nombre`,
    r.`materia`,
    r.`archivo_nombre`,
    r.`fecha_envio`,
    r.`profesor_id`,
    p.`titulo` AS `plan_titulo`
FROM `recuperaciones` r
LEFT JOIN `planes_recuperacion` p ON r.`plan_id` = p.`id`
WHERE r.`revisado` = 0
ORDER BY r.`fecha_envio` ASC;

-- Vista: Auditoría reciente (últimos 100 registros)
CREATE OR REPLACE VIEW `vista_auditoria_reciente` AS
SELECT 
    a.`id`,
    a.`timestamp`,
    a.`usuario_nombre`,
    a.`role`,
    a.`estudiante_afectado`,
    a.`accion`,
    a.`ip_address`
FROM `auditoria` a
ORDER BY a.`timestamp` DESC
LIMIT 100;

-- ============================================================
-- SECCIÓN 10: PROCEDIMIENTOS ALMACENADOS
-- ============================================================

DELIMITER //

-- Procedimiento: Calcular promedio de un estudiante en un periodo
DROP PROCEDURE IF EXISTS `calcular_promedio_estudiante`//
CREATE PROCEDURE `calcular_promedio_estudiante`(
    IN p_estudiante_id VARCHAR(50),
    IN p_periodo VARCHAR(50)
)
BEGIN
    SELECT AVG(`definitiva`) AS promedio
    FROM `notas`
    WHERE `estudiante_id` = p_estudiante_id 
    AND `periodo` = p_periodo
    AND `definitiva` > 0;
END//

-- Procedimiento: Obtener materias perdidas de un estudiante
DROP PROCEDURE IF EXISTS `obtener_materias_perdidas`//
CREATE PROCEDURE `obtener_materias_perdidas`(
    IN p_estudiante_id VARCHAR(50)
)
BEGIN
    SELECT 
        `materia`,
        AVG(`definitiva`) AS promedio_materia
    FROM `notas`
    WHERE `estudiante_id` = p_estudiante_id
    AND `definitiva` > 0
    GROUP BY `materia`
    HAVING AVG(`definitiva`) < 3.0;
END//

DELIMITER ;

-- ============================================================
-- SECCIÓN 11: TRIGGERS
-- ============================================================

DELIMITER //

-- Trigger: Auditar cambios en notas
DROP TRIGGER IF EXISTS `audit_notas_update`//
CREATE TRIGGER `audit_notas_update`
AFTER UPDATE ON `notas`
FOR EACH ROW
BEGIN
    IF OLD.`aptitud` != NEW.`aptitud` OR OLD.`actitud` != NEW.`actitud` OR OLD.`responsabilidad` != NEW.`responsabilidad` THEN
        INSERT INTO `auditoria` (`timestamp`, `usuario_id`, `usuario_nombre`, `role`, `estudiante_afectado`, `accion`, `extra`)
        VALUES (
            NOW(),
            @current_user_id,
            @current_user_name,
            @current_user_role,
            (SELECT `nombre` FROM `usuarios` WHERE `id` = NEW.`estudiante_id`),
            CONCAT('Actualización de nota - ', NEW.`materia`, ' (', NEW.`periodo`, ')'),
            CONCAT('Anterior: A=', OLD.`aptitud`, ' C=', OLD.`actitud`, ' R=', OLD.`responsabilidad`, 
                   ' | Nuevo: A=', NEW.`aptitud`, ' C=', NEW.`actitud`, ' R=', NEW.`responsabilidad`)
        );
    END IF;
END//

-- Trigger: Auditar bloqueos de usuarios
DROP TRIGGER IF EXISTS `audit_usuario_bloqueado`//
CREATE TRIGGER `audit_usuario_bloqueado`
AFTER UPDATE ON `usuarios`
FOR EACH ROW
BEGIN
    IF OLD.`blocked` != NEW.`blocked` AND NEW.`blocked` = 1 THEN
        INSERT INTO `auditoria` (`timestamp`, `usuario_id`, `usuario_nombre`, `role`, `accion`, `extra`)
        VALUES (
            NOW(),
            'SYSTEM',
            'Sistema de Seguridad',
            'system',
            CONCAT('Usuario bloqueado: ', NEW.`usuario`),
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
);

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
('Química', 'bachillerato');

-- Periodos académicos
INSERT INTO `periodos` (`nombre`, `orden`) VALUES
('Periodo 1', 1),
('Periodo 2', 2),
('Periodo 3', 3),
('Periodo 4', 4);

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
('11A', 'bachillerato');

-- Configuración de fechas (año lectivo 2025)
INSERT INTO `configuracion_fechas` (`tipo`, `fecha_inicio`, `fecha_fin`, `activo`)
VALUES ('global', '2025-01-15', '2025-11-30', 1);

INSERT INTO `configuracion_fechas` (`tipo`, `periodo_nombre`, `fecha_inicio`, `fecha_fin`, `activo`)
VALUES 
('periodo', 'Periodo 1', '2025-01-15', '2025-03-15', 1),
('periodo', 'Periodo 2', '2025-03-20', '2025-05-30', 1),
('periodo', 'Periodo 3', '2025-06-05', '2025-08-15', 1),
('periodo', 'Periodo 4', '2025-08-20', '2025-11-15', 1);

INSERT INTO `configuracion_fechas` (`tipo`, `fecha_inicio`, `fecha_fin`, `periodo_ext_mapeo`, `activo`)
VALUES ('extraordinario', '2025-11-20', '2025-12-15', 'Periodo 4', 0);

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
-- FINALIZACIÓN
-- ============================================================

SET FOREIGN_KEY_CHECKS=1;
COMMIT;

-- Verificación
SELECT '✅ Base de datos creada correctamente' AS ESTADO;
SELECT 'edusistema_v5' AS BASE_DE_DATOS;
SELECT COUNT(*) AS TOTAL_TABLAS FROM information_schema.tables WHERE table_schema = 'edusistema_v5';
SELECT COUNT(*) AS TOTAL_MATERIAS FROM materias;
SELECT COUNT(*) AS TOTAL_PERIODOS FROM periodos;
SELECT COUNT(*) AS TOTAL_SALONES FROM salones;
SELECT 'Usuario: admin | Contraseña: admin123' AS CREDENCIALES_INICIALES;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
