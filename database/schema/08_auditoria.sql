-- ============================================================
-- EduSistema Pro v5 - Script 8: AUDITORÍA
-- Archivo: database/schema/08_auditoria.sql
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
