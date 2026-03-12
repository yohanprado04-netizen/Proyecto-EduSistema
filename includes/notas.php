<?php
/**
 * EduSistema Pro v5 - Gestión de Notas
 * Archivo: includes/notas.php
 * 
 * Funciones para el sistema de notas tripartitas
 */

/**
 * Obtener nota tripartita de un estudiante
 * @param string $estudianteId
 * @param string $periodo
 * @param string $materia
 * @return array|null
 */
function obtenerNota($estudianteId, $periodo, $materia) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("
            SELECT * FROM notas 
            WHERE estudiante_id = :estudiante_id 
            AND periodo = :periodo 
            AND materia = :materia
        ");
        
        $stmt->execute([
            'estudiante_id' => $estudianteId,
            'periodo' => $periodo,
            'materia' => $materia
        ]);
        
        return $stmt->fetch();
        
    } catch (PDOException $e) {
        error_log("Error en obtenerNota: " . $e->getMessage());
        return null;
    }
}

/**
 * Guardar o actualizar nota tripartita
 * @param string $estudianteId
 * @param string $periodo
 * @param string $materia
 * @param float $aptitud
 * @param float $actitud
 * @param float $responsabilidad
 * @return bool
 */
function guardarNota($estudianteId, $periodo, $materia, $aptitud, $actitud, $responsabilidad) {
    try {
        $db = Database::getInstance()->getConnection();
        
        // Validar rangos
        if ($aptitud < 0 || $aptitud > 5 || 
            $actitud < 0 || $actitud > 5 || 
            $responsabilidad < 0 || $responsabilidad > 5) {
            return false;
        }
        
        // Obtener nota anterior para auditoría
        $notaAnterior = obtenerNota($estudianteId, $periodo, $materia);
        
        // Guardar o actualizar
        $stmt = $db->prepare("
            INSERT INTO notas (estudiante_id, periodo, materia, aptitud, actitud, responsabilidad)
            VALUES (:estudiante_id, :periodo, :materia, :aptitud, :actitud, :responsabilidad)
            ON DUPLICATE KEY UPDATE 
                aptitud = :aptitud,
                actitud = :actitud,
                responsabilidad = :responsabilidad
        ");
        
        $result = $stmt->execute([
            'estudiante_id' => $estudianteId,
            'periodo' => $periodo,
            'materia' => $materia,
            'aptitud' => $aptitud,
            'actitud' => $actitud,
            'responsabilidad' => $responsabilidad
        ]);
        
        // Auditoría
        if ($result && isset($_SESSION['user_id'])) {
            $estudiante = getUserById($estudianteId);
            $oldDef = $notaAnterior ? calcularDefinitiva(
                $notaAnterior['aptitud'], 
                $notaAnterior['actitud'], 
                $notaAnterior['responsabilidad']
            ) : 0;
            $newDef = calcularDefinitiva($aptitud, $actitud, $responsabilidad);
            
            logAudit(
                $_SESSION['user_id'],
                $_SESSION['user_name'],
                $_SESSION['user_role'],
                $estudiante['nombre'] ?? $estudianteId,
                "Actualización nota $materia ($periodo)",
                "Anterior: $oldDef → Nuevo: $newDef"
            );
        }
        
        return $result;
        
    } catch (PDOException $e) {
        error_log("Error en guardarNota: " . $e->getMessage());
        return false;
    }
}

/**
 * Calcular promedio de un estudiante en un periodo
 * @param string $estudianteId
 * @param string $periodo
 * @return float
 */
function calcularPromedioEstudiantePeriodo($estudianteId, $periodo) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("CALL calcular_promedio_estudiante(:estudiante_id, :periodo)");
        $stmt->execute([
            'estudiante_id' => $estudianteId,
            'periodo' => $periodo
        ]);
        
        $result = $stmt->fetch();
        return $result ? floatval($result['promedio']) : 0.0;
        
    } catch (PDOException $e) {
        error_log("Error en calcularPromedioEstudiantePeriodo: " . $e->getMessage());
        return 0.0;
    }
}

/**
 * Calcular promedio general de un estudiante
 * @param string $estudianteId
 * @return float
 */
function calcularPromedioGeneral($estudianteId) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("
            SELECT promedio_general 
            FROM vista_promedios_general 
            WHERE estudiante_id = :estudiante_id
        ");
        
        $stmt->execute(['estudiante_id' => $estudianteId]);
        $result = $stmt->fetch();
        
        return $result ? floatval($result['promedio_general']) : 0.0;
        
    } catch (PDOException $e) {
        error_log("Error en calcularPromedioGeneral: " . $e->getMessage());
        return 0.0;
    }
}

/**
 * Obtener materias perdidas de un estudiante
 * @param string $estudianteId
 * @return array
 */
function obtenerMateriasPerdidas($estudianteId) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("CALL obtener_materias_perdidas(:estudiante_id)");
        $stmt->execute(['estudiante_id' => $estudianteId]);
        
        return $stmt->fetchAll();
        
    } catch (PDOException $e) {
        error_log("Error en obtenerMateriasPerdidas: " . $e->getMessage());
        return [];
    }
}

/**
 * Obtener todas las notas de un estudiante
 * @param string $estudianteId
 * @return array
 */
function obtenerNotasEstudiante($estudianteId) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("
            SELECT * FROM notas 
            WHERE estudiante_id = :estudiante_id 
            ORDER BY periodo, materia
        ");
        
        $stmt->execute(['estudiante_id' => $estudianteId]);
        return $stmt->fetchAll();
        
    } catch (PDOException $e) {
        error_log("Error en obtenerNotasEstudiante: " . $e->getMessage());
        return [];
    }
}

/**
 * Guardar disciplina de un estudiante
 * @param string $estudianteId
 * @param string $disciplina
 * @return bool
 */
function guardarDisciplina($estudianteId, $disciplina) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $validos = ['Excelente', 'Bueno', 'Regular', 'Deficiente'];
        if (!in_array($disciplina, $validos)) {
            return false;
        }
        
        $stmt = $db->prepare("
            INSERT INTO disciplina (estudiante_id, disciplina)
            VALUES (:estudiante_id, :disciplina)
            ON DUPLICATE KEY UPDATE disciplina = :disciplina
        ");
        
        return $stmt->execute([
            'estudiante_id' => $estudianteId,
            'disciplina' => $disciplina
        ]);
        
    } catch (PDOException $e) {
        error_log("Error en guardarDisciplina: " . $e->getMessage());
        return false;
    }
}

/**
 * Obtener disciplina de un estudiante
 * @param string $estudianteId
 * @return string
 */
function obtenerDisciplina($estudianteId) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("
            SELECT disciplina FROM disciplina 
            WHERE estudiante_id = :estudiante_id
        ");
        
        $stmt->execute(['estudiante_id' => $estudianteId]);
        $result = $stmt->fetch();
        
        return $result ? $result['disciplina'] : 'Bueno';
        
    } catch (PDOException $e) {
        error_log("Error en obtenerDisciplina: " . $e->getMessage());
        return 'Bueno';
    }
}
?>
