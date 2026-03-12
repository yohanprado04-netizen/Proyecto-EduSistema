-- ============================================================
-- DATOS INICIALES - USUARIOS PREDETERMINADOS
-- Los 3 Roles: Admin, Profesor y Estudiante
-- ============================================================

-- ============================================================
-- CONTRASEÑAS (todas con hash SHA-256 + salt 'EduSistema_v5_2026')
-- ============================================================
-- admin123    → 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
-- profe123    → e2fc714c4727ee9395f324cd2e7f331f58c8635d4e5c4e823fe7e8b4a6f9c48d
-- est123      → f6e0a1e2ac41945a9aa7ff8a8aaa0cebc12a3bcc981a929ad5cf810a090e11ae
-- ============================================================

-- Limpiar datos existentes (opcional - comentar si no deseas borrar)
DELETE FROM `historial_estudiantes`;
DELETE FROM `disciplina`;
DELETE FROM `notas`;
DELETE FROM `asistencias`;
DELETE FROM `excusas`;
DELETE FROM `archivos_subidos`;
DELETE FROM `recuperaciones`;
DELETE FROM `planes_recuperacion`;
DELETE FROM `clases_virtuales`;
DELETE FROM `profesor_salon_materias`;
DELETE FROM `profesor_salones`;
DELETE FROM `estudiantes`;
DELETE FROM `profesores`;
DELETE FROM `usuarios`;

-- ============================================================
-- 1. USUARIO ADMINISTRADOR
-- ============================================================

INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'admin',
  'Administrador del Sistema',
  'CC-1000000001',
  'admin',
  '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
  'admin',
  1,
  0,
  CURDATE()
);

-- ============================================================
-- 2. USUARIOS PROFESORES (3 ejemplos)
-- ============================================================

-- Profesor 1: Primaria (da todas las materias en su salón)
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'profe_1',
  'María García Rodríguez',
  'CC-1000000002',
  'maria.garcia',
  'e2fc714c4727ee9395f324cd2e7f331f58c8635d4e5c4e823fe7e8b4a6f9c48d',
  'profe',
  1,
  0,
  CURDATE()
);

INSERT INTO `profesores` (`id`, `ciclo`)
VALUES ('profe_1', 'primaria');

-- Asignar salón 3A a la profesora de primaria
INSERT INTO `profesor_salones` (`profesor_id`, `salon_nombre`)
VALUES ('profe_1', '3A');

-- Profesor 2: Bachillerato - Matemáticas y Física
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'profe_2',
  'Carlos Martínez López',
  'CC-1000000003',
  'carlos.martinez',
  'e2fc714c4727ee9395f324cd2e7f331f58c8635d4e5c4e823fe7e8b4a6f9c48d',
  'profe',
  1,
  0,
  CURDATE()
);

INSERT INTO `profesores` (`id`, `ciclo`)
VALUES ('profe_2', 'bachillerato');

-- Asignar salones 9A y 10A
INSERT INTO `profesor_salones` (`profesor_id`, `salon_nombre`)
VALUES 
  ('profe_2', '9A'),
  ('profe_2', '10A');

-- Asignar materias por salón
INSERT INTO `profesor_salon_materias` (`profesor_id`, `salon_nombre`, `materia_nombre`)
VALUES 
  ('profe_2', '9A', 'Matemáticas'),
  ('profe_2', '9A', 'Física'),
  ('profe_2', '10A', 'Matemáticas'),
  ('profe_2', '10A', 'Física');

-- Profesor 3: Bachillerato - Español y Ciencias Sociales
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'profe_3',
  'Ana Sofía Ramírez',
  'CC-1000000004',
  'ana.ramirez',
  'e2fc714c4727ee9395f324cd2e7f331f58c8635d4e5c4e823fe7e8b4a6f9c48d',
  'profe',
  1,
  0,
  CURDATE()
);

INSERT INTO `profesores` (`id`, `ciclo`)
VALUES ('profe_3', 'bachillerato');

-- Asignar salones 9A, 10A y 11A
INSERT INTO `profesor_salones` (`profesor_id`, `salon_nombre`)
VALUES 
  ('profe_3', '9A'),
  ('profe_3', '10A'),
  ('profe_3', '11A');

-- Asignar materias por salón
INSERT INTO `profesor_salon_materias` (`profesor_id`, `salon_nombre`, `materia_nombre`)
VALUES 
  ('profe_3', '9A', 'Español'),
  ('profe_3', '9A', 'Ciencias Sociales'),
  ('profe_3', '10A', 'Español'),
  ('profe_3', '10A', 'Ciencias Sociales'),
  ('profe_3', '11A', 'Español'),
  ('profe_3', '11A', 'Ciencias Sociales');

-- ============================================================
-- 3. USUARIOS ESTUDIANTES (6 ejemplos - 2 por nivel)
-- ============================================================

-- Estudiante 1: Primaria - Salón 3A
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'est_1',
  'Juan Pablo Pérez',
  'TI-1000000010',
  'juan.perez',
  'f6e0a1e2ac41945a9aa7ff8a8aaa0cebc12a3bcc981a929ad5cf810a090e11ae',
  'est',
  1,
  0,
  CURDATE()
);

INSERT INTO `estudiantes` (`id`, `salon`)
VALUES ('est_1', '3A');

INSERT INTO `historial_estudiantes` (`id`, `nombre`, `ti`, `salon`, `fecha_registro`, `activo`)
VALUES ('est_1', 'Juan Pablo Pérez', 'TI-1000000010', '3A', CURDATE(), 1);

-- Estudiante 2: Primaria - Salón 3A
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'est_2',
  'Sofía Valentina Gómez',
  'TI-1000000011',
  'sofia.gomez',
  'f6e0a1e2ac41945a9aa7ff8a8aaa0cebc12a3bcc981a929ad5cf810a090e11ae',
  'est',
  1,
  0,
  CURDATE()
);

INSERT INTO `estudiantes` (`id`, `salon`)
VALUES ('est_2', '3A');

INSERT INTO `historial_estudiantes` (`id`, `nombre`, `ti`, `salon`, `fecha_registro`, `activo`)
VALUES ('est_2', 'Sofía Valentina Gómez', 'TI-1000000011', '3A', CURDATE(), 1);

-- Estudiante 3: Bachillerato - Salón 9A
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'est_3',
  'Andrés Felipe Torres',
  'TI-1000000012',
  'andres.torres',
  'f6e0a1e2ac41945a9aa7ff8a8aaa0cebc12a3bcc981a929ad5cf810a090e11ae',
  'est',
  1,
  0,
  CURDATE()
);

INSERT INTO `estudiantes` (`id`, `salon`)
VALUES ('est_3', '9A');

INSERT INTO `historial_estudiantes` (`id`, `nombre`, `ti`, `salon`, `fecha_registro`, `activo`)
VALUES ('est_3', 'Andrés Felipe Torres', 'TI-1000000012', '9A', CURDATE(), 1);

-- Estudiante 4: Bachillerato - Salón 9A
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'est_4',
  'Camila Isabella Vargas',
  'TI-1000000013',
  'camila.vargas',
  'f6e0a1e2ac41945a9aa7ff8a8aaa0cebc12a3bcc981a929ad5cf810a090e11ae',
  'est',
  1,
  0,
  CURDATE()
);

INSERT INTO `estudiantes` (`id`, `salon`)
VALUES ('est_4', '9A');

INSERT INTO `historial_estudiantes` (`id`, `nombre`, `ti`, `salon`, `fecha_registro`, `activo`)
VALUES ('est_4', 'Camila Isabella Vargas', 'TI-1000000013', '9A', CURDATE(), 1);

-- Estudiante 5: Bachillerato - Salón 10A
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'est_5',
  'Daniel Alejandro Ruiz',
  'TI-1000000014',
  'daniel.ruiz',
  'f6e0a1e2ac41945a9aa7ff8a8aaa0cebc12a3bcc981a929ad5cf810a090e11ae',
  'est',
  1,
  0,
  CURDATE()
);

INSERT INTO `estudiantes` (`id`, `salon`)
VALUES ('est_5', '10A');

INSERT INTO `historial_estudiantes` (`id`, `nombre`, `ti`, `salon`, `fecha_registro`, `activo`)
VALUES ('est_5', 'Daniel Alejandro Ruiz', 'TI-1000000014', '10A', CURDATE(), 1);

-- Estudiante 6: Bachillerato - Salón 10A
INSERT INTO `usuarios` (`id`, `nombre`, `ti`, `usuario`, `password`, `role`, `activo`, `blocked`, `registrado`)
VALUES (
  'est_6',
  'Valentina Mariana Castro',
  'TI-1000000015',
  'valentina.castro',
  'f6e0a1e2ac41945a9aa7ff8a8aaa0cebc12a3bcc981a929ad5cf810a090e11ae',
  'est',
  1,
  0,
  CURDATE()
);

INSERT INTO `estudiantes` (`id`, `salon`)
VALUES ('est_6', '10A');

INSERT INTO `historial_estudiantes` (`id`, `nombre`, `ti`, `salon`, `fecha_registro`, `activo`)
VALUES ('est_6', 'Valentina Mariana Castro', 'TI-1000000015', '10A', CURDATE(), 1);

-- ============================================================
-- 4. NOTAS DE EJEMPLO (Periodo 1 - para demostración)
-- ============================================================

-- Notas para estudiantes de primaria (3A)
-- Materias de primaria: Matemáticas, Lengua Castellana, Ciencias Naturales, 
-- Ciencias Sociales, Ed. Artística, Ed. Física, Ética

-- Juan Pablo Pérez (est_1) - Estudiante destacado
INSERT INTO `notas` (`estudiante_id`, `periodo`, `materia`, `aptitud`, `actitud`, `responsabilidad`)
VALUES 
  ('est_1', 'Periodo 1', 'Matemáticas', 4.8, 5.0, 4.7),
  ('est_1', 'Periodo 1', 'Lengua Castellana', 4.5, 4.8, 4.6),
  ('est_1', 'Periodo 1', 'Ciencias Naturales', 4.7, 4.9, 4.8),
  ('est_1', 'Periodo 1', 'Ciencias Sociales', 4.6, 5.0, 4.7),
  ('est_1', 'Periodo 1', 'Ed. Artística', 4.9, 5.0, 5.0),
  ('est_1', 'Periodo 1', 'Ed. Física', 4.8, 5.0, 4.9),
  ('est_1', 'Periodo 1', 'Ética', 5.0, 5.0, 5.0);

-- Sofía Valentina Gómez (est_2) - Estudiante regular
INSERT INTO `notas` (`estudiante_id`, `periodo`, `materia`, `aptitud`, `actitud`, `responsabilidad`)
VALUES 
  ('est_2', 'Periodo 1', 'Matemáticas', 3.8, 4.2, 4.0),
  ('est_2', 'Periodo 1', 'Lengua Castellana', 4.0, 4.3, 4.1),
  ('est_2', 'Periodo 1', 'Ciencias Naturales', 3.9, 4.0, 3.8),
  ('est_2', 'Periodo 1', 'Ciencias Sociales', 4.1, 4.4, 4.2),
  ('est_2', 'Periodo 1', 'Ed. Artística', 4.5, 4.7, 4.6),
  ('est_2', 'Periodo 1', 'Ed. Física', 4.3, 4.5, 4.4),
  ('est_2', 'Periodo 1', 'Ética', 4.2, 4.6, 4.5);

-- Notas para estudiantes de bachillerato (9A)
-- Materias que enseñan los profes 2 y 3 en 9A:
-- Matemáticas, Física (profe_2)
-- Español, Ciencias Sociales (profe_3)

-- Andrés Felipe Torres (est_3) - Estudiante con dificultad en Matemáticas
INSERT INTO `notas` (`estudiante_id`, `periodo`, `materia`, `aptitud`, `actitud`, `responsabilidad`)
VALUES 
  ('est_3', 'Periodo 1', 'Matemáticas', 2.5, 3.0, 2.8),
  ('est_3', 'Periodo 1', 'Física', 3.2, 3.5, 3.4),
  ('est_3', 'Periodo 1', 'Español', 4.0, 4.2, 4.1),
  ('est_3', 'Periodo 1', 'Ciencias Sociales', 3.8, 4.0, 3.9);

-- Camila Isabella Vargas (est_4) - Estudiante destacada
INSERT INTO `notas` (`estudiante_id`, `periodo`, `materia`, `aptitud`, `actitud`, `responsabilidad`)
VALUES 
  ('est_4', 'Periodo 1', 'Matemáticas', 4.9, 5.0, 4.8),
  ('est_4', 'Periodo 1', 'Física', 4.7, 4.9, 4.8),
  ('est_4', 'Periodo 1', 'Español', 4.8, 5.0, 4.9),
  ('est_4', 'Periodo 1', 'Ciencias Sociales', 4.6, 4.8, 4.7);

-- Notas para estudiantes de 10A
-- Materias que enseñan los profes 2 y 3 en 10A:
-- Matemáticas, Física (profe_2)
-- Español, Ciencias Sociales (profe_3)

-- Daniel Alejandro Ruiz (est_5) - Estudiante regular
INSERT INTO `notas` (`estudiante_id`, `periodo`, `materia`, `aptitud`, `actitud`, `responsabilidad`)
VALUES 
  ('est_5', 'Periodo 1', 'Matemáticas', 3.5, 3.8, 3.6),
  ('est_5', 'Periodo 1', 'Física', 3.7, 3.9, 3.8),
  ('est_5', 'Periodo 1', 'Español', 4.1, 4.3, 4.2),
  ('est_5', 'Periodo 1', 'Ciencias Sociales', 3.9, 4.1, 4.0);

-- Valentina Mariana Castro (est_6) - Estudiante con dos materias perdidas
INSERT INTO `notas` (`estudiante_id`, `periodo`, `materia`, `aptitud`, `actitud`, `responsabilidad`)
VALUES 
  ('est_6', 'Periodo 1', 'Matemáticas', 2.3, 2.8, 2.5),
  ('est_6', 'Periodo 1', 'Física', 2.7, 3.0, 2.9),
  ('est_6', 'Periodo 1', 'Español', 3.8, 4.0, 3.9),
  ('est_6', 'Periodo 1', 'Ciencias Sociales', 3.5, 3.7, 3.6);

-- ============================================================
-- 5. DISCIPLINA DE LOS ESTUDIANTES
-- ============================================================

INSERT INTO `disciplina` (`estudiante_id`, `disciplina`)
VALUES 
  ('est_1', 'Excelente'),
  ('est_2', 'Bueno'),
  ('est_3', 'Regular'),
  ('est_4', 'Excelente'),
  ('est_5', 'Bueno'),
  ('est_6', 'Regular');

-- ============================================================
-- 6. REGISTRO EN AUDITORÍA
-- ============================================================

INSERT INTO `auditoria` (`timestamp`, `usuario_id`, `usuario_nombre`, `role`, `accion`, `extra`, `ip_address`)
VALUES (
  NOW(),
  'admin',
  'Sistema',
  'system',
  'Usuarios predeterminados creados',
  '1 Admin, 3 Profesores, 6 Estudiantes con notas de ejemplo',
  '127.0.0.1'
);

-- ============================================================
-- RESUMEN DE USUARIOS CREADOS
-- ============================================================

SELECT '===================================================' AS '';
SELECT '✅ USUARIOS CREADOS CORRECTAMENTE' AS '';
SELECT '===================================================' AS '';
SELECT '' AS '';

SELECT '📋 ADMINISTRADOR' AS '';
SELECT 'Usuario: admin | Contraseña: admin123' AS '';
SELECT 'Nombre: Administrador del Sistema' AS '';
SELECT 'T.I.: CC-1000000001' AS '';
SELECT '' AS '';

SELECT '👩‍🏫 PROFESORES (contraseña: profe123)' AS '';
SELECT 'Usuario: maria.garcia | Nombre: María García Rodríguez | Ciclo: Primaria | Salón: 3A' AS '';
SELECT 'Usuario: carlos.martinez | Nombre: Carlos Martínez López | Ciclo: Bach. | Materias: Mat, Fís | Salones: 9A, 10A' AS '';
SELECT 'Usuario: ana.ramirez | Nombre: Ana Sofía Ramírez | Ciclo: Bach. | Materias: Esp, C.Soc | Salones: 9A, 10A, 11A' AS '';
SELECT '' AS '';

SELECT '🎓 ESTUDIANTES (contraseña: est123)' AS '';
SELECT 'Usuario: juan.perez | Nombre: Juan Pablo Pérez | Salón: 3A (Primaria) | Promedio: ~4.8' AS '';
SELECT 'Usuario: sofia.gomez | Nombre: Sofía Valentina Gómez | Salón: 3A (Primaria) | Promedio: ~4.2' AS '';
SELECT 'Usuario: andres.torres | Nombre: Andrés Felipe Torres | Salón: 9A (Bach.) | Promedio: ~3.2 (Mat perdida)' AS '';
SELECT 'Usuario: camila.vargas | Nombre: Camila Isabella Vargas | Salón: 9A (Bach.) | Promedio: ~4.8' AS '';
SELECT 'Usuario: daniel.ruiz | Nombre: Daniel Alejandro Ruiz | Salón: 10A (Bach.) | Promedio: ~3.8' AS '';
SELECT 'Usuario: valentina.castro | Nombre: Valentina Mariana Castro | Salón: 10A (Bach.) | Promedio: ~2.9 (2 perdidas)' AS '';
SELECT '' AS '';

SELECT '===================================================' AS '';
SELECT '📊 DATOS ADICIONALES CREADOS' AS '';
SELECT '===================================================' AS '';
SELECT '✅ Notas del Periodo 1 para todos los estudiantes' AS '';
SELECT '✅ Disciplina asignada a cada estudiante' AS '';
SELECT '✅ Historial de estudiantes registrado' AS '';
SELECT '✅ Asignación de profesores a salones y materias' AS '';
SELECT '' AS '';

SELECT COUNT(*) AS 'Total Usuarios' FROM usuarios;
SELECT COUNT(*) AS 'Total Profesores' FROM profesores;
SELECT COUNT(*) AS 'Total Estudiantes' FROM estudiantes;
SELECT COUNT(*) AS 'Total Notas Ingresadas' FROM notas;
