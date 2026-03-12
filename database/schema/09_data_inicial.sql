-- ============================================================
-- EduSistema Pro v5 - Script 9: DATOS INICIALES
-- Archivo: database/schema/09_data_inicial.sql
-- ============================================================

-- =====================
-- USUARIO ADMINISTRADOR
-- =====================
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

-- =====================
-- MATERIAS PRIMARIA
-- =====================
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

-- =====================
-- PERIODOS ACADÉMICOS
-- =====================
INSERT INTO `periodos` (`nombre`, `orden`) VALUES
('Periodo 1', 1),
('Periodo 2', 2),
('Periodo 3', 3),
('Periodo 4', 4)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

-- =====================
-- SALONES DE EJEMPLO
-- =====================
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

-- =====================
-- CONFIGURACIÓN DE FECHAS
-- =====================
-- Rango global (ejemplo: año lectivo 2025)
INSERT INTO `configuracion_fechas` (`tipo`, `fecha_inicio`, `fecha_fin`, `activo`)
VALUES ('global', '2025-01-15', '2025-11-30', 1)
ON DUPLICATE KEY UPDATE activo=VALUES(activo);

-- Periodo 1
INSERT INTO `configuracion_fechas` (`tipo`, `periodo_nombre`, `fecha_inicio`, `fecha_fin`, `activo`)
VALUES ('periodo', 'Periodo 1', '2025-01-15', '2025-03-15', 1)
ON DUPLICATE KEY UPDATE activo=VALUES(activo);

-- Periodo 2
INSERT INTO `configuracion_fechas` (`tipo`, `periodo_nombre`, `fecha_inicio`, `fecha_fin`, `activo`)
VALUES ('periodo', 'Periodo 2', '2025-03-20', '2025-05-30', 1)
ON DUPLICATE KEY UPDATE activo=VALUES(activo);

-- Periodo 3
INSERT INTO `configuracion_fechas` (`tipo`, `periodo_nombre`, `fecha_inicio`, `fecha_fin`, `activo`)
VALUES ('periodo', 'Periodo 3', '2025-06-05', '2025-08-15', 1)
ON DUPLICATE KEY UPDATE activo=VALUES(activo);

-- Periodo 4
INSERT INTO `configuracion_fechas` (`tipo`, `periodo_nombre`, `fecha_inicio`, `fecha_fin`, `activo`)
VALUES ('periodo', 'Periodo 4', '2025-08-20', '2025-11-15', 1)
ON DUPLICATE KEY UPDATE activo=VALUES(activo);

-- Periodo Extraordinario (inicialmente inactivo)
INSERT INTO `configuracion_fechas` (`tipo`, `fecha_inicio`, `fecha_fin`, `periodo_ext_mapeo`, `activo`)
VALUES ('extraordinario', '2025-11-20', '2025-12-15', 'Periodo 4', 0)
ON DUPLICATE KEY UPDATE activo=VALUES(activo);

-- =====================
-- REGISTRO EN AUDITORÍA
-- =====================
INSERT INTO `auditoria` (`timestamp`, `usuario_id`, `usuario_nombre`, `role`, `accion`, `extra`, `ip_address`)
VALUES (
  NOW(),
  'admin',
  'Sistema',
  'system',
  'Datos iniciales cargados',
  'Usuario admin, materias, periodos y salones creados',
  '127.0.0.1'
);

-- =====================
-- INFORMACIÓN
-- =====================
SELECT 'Base de datos inicializada correctamente' AS STATUS;
SELECT COUNT(*) AS total_materias FROM materias;
SELECT COUNT(*) AS total_periodos FROM periodos;
SELECT COUNT(*) AS total_salones FROM salones;
