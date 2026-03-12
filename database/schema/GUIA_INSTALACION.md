# 📖 Guía de Instalación - EduSistema Pro v5
## Script SQL Completo con Índices y Claves Foráneas

---

## ✅ PASO 1: Abrir phpMyAdmin

1. Iniciar XAMPP Control Panel
2. Verificar que **Apache** y **MySQL** estén corriendo (luz verde)
3. Abrir navegador y ir a: `http://localhost/phpmyadmin`

---

## ✅ PASO 2: Ejecutar el Script SQL

### ⚠️ IMPORTANTE: NO seleccionar ninguna base de datos

El script creará la base de datos automáticamente.

### Pasos en phpMyAdmin:

1. **Click en pestaña "SQL"** (en la parte superior)

2. **Copiar TODO el contenido** del archivo `crear_bd_completa.sql`

3. **Pegar en el área de texto** de phpMyAdmin

4. **Click en botón "Continuar"** (esquina inferior derecha)

5. **Esperar confirmación** (~5-10 segundos)

---

## ✅ PASO 3: Verificar la Instalación

Deberías ver un mensaje de éxito similar a:

```
✅ Base de datos creada correctamente
BASE_DE_DATOS: edusistema_v5
TOTAL_TABLAS: 23
TOTAL_MATERIAS: 12
TOTAL_PERIODOS: 4
TOTAL_SALONES: 11
CREDENCIALES_INICIALES: Usuario: admin | Contraseña: admin123
```

---

## 📊 Resumen de lo que se creó:

### 1. Base de Datos
- **Nombre:** `edusistema_v5`
- **Charset:** `utf8mb4`
- **Collation:** `utf8mb4_unicode_ci`

### 2. Tablas Creadas (23)

| # | Tabla | Tipo | Descripción |
|---|-------|------|-------------|
| 1 | `usuarios` | Base | Admin, profesores y estudiantes |
| 2 | `profesores` | Extensión | Ciclo educativo |
| 3 | `estudiantes` | Extensión | Salón asignado |
| 4 | `usuarios_bloqueados` | Seguridad | Control de accesos |
| 5 | `historial_estudiantes` | Histórico | Registro de altas/bajas |
| 6 | `materias` | Catálogo | Materias del plan de estudios |
| 7 | `periodos` | Catálogo | Periodos académicos |
| 8 | `salones` | Catálogo | Grados y salones |
| 9 | `salon_materias` | Relación | Materias por salón |
| 10 | `profesor_salones` | Relación N:M | Profesores-Salones |
| 11 | `profesor_salon_materias` | Relación | Materias por prof/salón |
| 12 | `notas` | **Principal** | Sistema tripartita |
| 13 | `disciplina` | Evaluación | Comportamiento |
| 14 | `configuracion_fechas` | Config | Control de rangos |
| 15 | `asistencias` | Registro | Control de asistencia |
| 16 | `excusas` | Comunicación | Justificaciones |
| 17 | `clases_virtuales` | Comunicación | Enlaces de clase |
| 18 | `archivos_subidos` | Tareas | Trabajos de estudiantes |
| 19 | `planes_recuperacion` | Recuperación | Planes de profes |
| 20 | `recuperaciones` | Recuperación | Respuestas de estudiantes |
| 21 | `historial_planes` | Histórico | Planes archivados |
| 22 | `historial_recuperaciones` | Histórico | Recuperaciones archivadas |
| 23 | `auditoria` | Seguridad | Log de cambios |

### 3. Índices Creados

Cada tabla tiene múltiples índices para optimizar consultas:

#### Tabla `usuarios`
- PRIMARY KEY: `id`
- UNIQUE KEY: `usuario`
- INDEX: `idx_usuario`, `idx_role`, `idx_activo`

#### Tabla `notas` (Principal)
- PRIMARY KEY: `id`
- UNIQUE KEY: `unique_nota` (estudiante_id, periodo, materia)
- INDEX: `idx_estudiante`, `idx_periodo`, `idx_materia`, `idx_definitiva`
- **GENERATED COLUMN**: `definitiva` (calculada automáticamente)

#### Tabla `asistencias`
- PRIMARY KEY: `id`
- UNIQUE KEY: `unique_asistencia` (salon, fecha, estudiante_id)
- INDEX: `idx_salon_fecha`, `idx_estudiante`, `idx_fecha`

*Y así para todas las 23 tablas...*

### 4. Claves Foráneas (Foreign Keys)

Todas las relaciones están implementadas:

```
profesores.id → usuarios.id
estudiantes.id → usuarios.id
estudiantes.salon → salones.nombre
profesor_salones.profesor_id → profesores.id
profesor_salones.salon_nombre → salones.nombre
notas.estudiante_id → estudiantes.id
asistencias.estudiante_id → estudiantes.id
asistencias.salon → salones.nombre
excusas.estudiante_id → estudiantes.id
clases_virtuales.profesor_id → profesores.id
archivos_subidos.estudiante_id → estudiantes.id
planes_recuperacion.estudiante_id → estudiantes.id
recuperaciones.estudiante_id → estudiantes.id
... (y más)
```

**Total de Foreign Keys:** 28

### 5. Vistas Creadas (6)

| Vista | Descripción |
|-------|-------------|
| `vista_promedios_periodo` | Promedio por estudiante y periodo |
| `vista_promedios_general` | Promedio general por estudiante |
| `vista_resumen_asistencia` | Estadísticas de asistencia |
| `vista_archivos_pendientes` | Tareas sin revisar |
| `vista_recuperaciones_pendientes` | Recuperaciones sin revisar |
| `vista_auditoria_reciente` | Últimos 100 cambios |

### 6. Procedimientos Almacenados (2)

```sql
CALL calcular_promedio_estudiante('est_123', 'Periodo 1');
CALL obtener_materias_perdidas('est_123');
```

### 7. Triggers (2)

- `audit_notas_update` - Registra cambios en notas
- `audit_usuario_bloqueado` - Registra bloqueos

### 8. Datos Iniciales

#### Usuario Admin
```
Usuario: admin
Contraseña: admin123
Hash SHA-256: 8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
Salt: EduSistema_v5_2026
```

#### Materias (12)
- Matemáticas, Lengua Castellana, Español
- Ciencias Naturales, Ciencias Sociales
- Ed. Artística, Arte, Ed. Física, Ética
- Inglés, Física, Química

#### Periodos (4)
- Periodo 1, 2, 3, 4

#### Salones (11)
- Primaria: 1A, 2A, 3A, 4A, 5A
- Bachillerato: 6A, 7A, 8A, 9A, 10A, 11A

#### Configuración de Fechas
- Rango global: 2025-01-15 → 2025-11-30
- Periodo 1: 2025-01-15 → 2025-03-15
- Periodo 2: 2025-03-20 → 2025-05-30
- Periodo 3: 2025-06-05 → 2025-08-15
- Periodo 4: 2025-08-20 → 2025-11-15
- Extraordinario: 2025-11-20 → 2025-12-15 (desactivado)

---

## 🔍 Verificar en phpMyAdmin

Después de ejecutar el script, verifica:

### 1. Base de Datos Creada
- En el panel izquierdo, buscar `edusistema_v5`
- Click para expandir

### 2. Ver Tablas
- Deberías ver las 23 tablas listadas
- Click en cualquier tabla para ver su estructura

### 3. Verificar Estructura de una Tabla
Ejemplo: Tabla `notas`

**Estructura:**
- Click en tabla `notas`
- Pestaña "Estructura"
- Verás 8 columnas:
  - `id` (INT, AUTO_INCREMENT, PRIMARY KEY)
  - `estudiante_id` (VARCHAR(50), INDEX)
  - `periodo` (VARCHAR(50), INDEX)
  - `materia` (VARCHAR(100), INDEX)
  - `aptitud` (DECIMAL(3,2), CHECK >= 0 AND <= 5)
  - `actitud` (DECIMAL(3,2), CHECK >= 0 AND <= 5)
  - `responsabilidad` (DECIMAL(3,2), CHECK >= 0 AND <= 5)
  - `definitiva` (DECIMAL(3,2), **GENERATED**, INDEX)

**Índices:**
- PRIMARY: `id`
- UNIQUE: `unique_nota` (estudiante_id, periodo, materia)
- INDEX: `idx_estudiante`, `idx_periodo`, `idx_materia`, `idx_definitiva`

**Relaciones (Foreign Keys):**
- `fk_nota_estudiante`: estudiante_id → estudiantes(id) CASCADE

### 4. Verificar Datos Iniciales

**Usuarios:**
```sql
SELECT * FROM usuarios;
```
Resultado: 1 registro (admin)

**Materias:**
```sql
SELECT * FROM materias;
```
Resultado: 12 registros

**Salones:**
```sql
SELECT * FROM salones;
```
Resultado: 11 registros

---

## 🔧 Comandos Útiles de Verificación

### Contar tablas
```sql
SELECT COUNT(*) AS total_tablas 
FROM information_schema.tables 
WHERE table_schema = 'edusistema_v5';
```
**Resultado esperado:** 23

### Ver todas las tablas
```sql
SHOW TABLES;
```

### Ver estructura de una tabla
```sql
DESCRIBE notas;
```

### Ver índices de una tabla
```sql
SHOW INDEX FROM notas;
```

### Ver claves foráneas
```sql
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'edusistema_v5' 
AND REFERENCED_TABLE_NAME IS NOT NULL;
```

### Ver vistas creadas
```sql
SHOW FULL TABLES WHERE Table_type = 'VIEW';
```

### Ver procedimientos
```sql
SHOW PROCEDURE STATUS WHERE Db = 'edusistema_v5';
```

### Ver triggers
```sql
SHOW TRIGGERS FROM edusistema_v5;
```

---

## ❌ Solución de Problemas

### Error: "Base de datos ya existe"

**Solución:**
El script incluye `DROP DATABASE IF EXISTS` al inicio.
Esto eliminará la BD existente y creará una nueva.

⚠️ **CUIDADO:** Perderás todos los datos si ya tenías información.

### Error: "Tabla ya existe"

**Causa:** Script se ejecutó parcialmente.

**Solución:**
1. Eliminar BD manualmente en phpMyAdmin
2. Ejecutar script nuevamente

O ejecutar:
```sql
DROP DATABASE IF EXISTS edusistema_v5;
```

### Error: "Cannot add foreign key constraint"

**Causa:** Orden de creación de tablas.

**Solución:**
El script tiene el orden correcto. Ejecutar TODO el script completo, no por partes.

### Error: "Generated column not supported"

**Causa:** MySQL versión antigua (< 5.7).

**Solución:**
Actualizar MySQL a versión 5.7 o superior.

Para verificar versión:
```sql
SELECT VERSION();
```

---

## 📋 Checklist de Verificación

Después de ejecutar el script, verifica:

- [ ] Base de datos `edusistema_v5` creada
- [ ] 23 tablas visibles en phpMyAdmin
- [ ] 1 usuario admin en tabla `usuarios`
- [ ] 12 materias en tabla `materias`
- [ ] 4 periodos en tabla `periodos`
- [ ] 11 salones en tabla `salones`
- [ ] 6 vistas creadas
- [ ] 2 procedimientos almacenados
- [ ] 2 triggers activos
- [ ] Configuración de fechas insertada

---

## 🎯 Siguiente Paso

Una vez verificada la base de datos:

1. **Configurar conexión PHP:**
   - Editar `app/config/database.php`
   - Verificar credenciales MySQL

2. **Copiar JavaScript:**
   - Del archivo `Index.html` original
   - A `app/assets/js/app.js`

3. **Acceder al sistema:**
   - URL: `http://localhost/edusistema-final/index.php`
   - Usuario: `admin`
   - Contraseña: `admin123`

---

## 📊 Resumen Técnico

```
BASE DE DATOS
└── edusistema_v5 (utf8mb4_unicode_ci)
    ├── Tablas: 23
    ├── Vistas: 6
    ├── Procedimientos: 2
    ├── Triggers: 2
    ├── Índices: 75+ (distribuidos en todas las tablas)
    ├── Foreign Keys: 28
    └── Datos Iniciales:
        ├── 1 usuario admin
        ├── 12 materias
        ├── 4 periodos
        ├── 11 salones
        └── Configuración de fechas
```

---

**✅ Script listo para ejecutar en phpMyAdmin**
**✅ Crea TODO automáticamente en un solo paso**
**✅ Incluye índices y claves foráneas**
**✅ Datos de prueba incluidos**

---

*Versión: 5.0*  
*Última actualización: Marzo 2026*
