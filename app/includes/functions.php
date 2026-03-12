<?php
/**
 * EduSistema Pro v5 - Funciones Auxiliares
 * Archivo: includes/functions.php
 */

function getUserById($id) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("
            SELECT u.*, 
                   CASE WHEN u.role = 'profe' THEN p.ciclo ELSE NULL END as ciclo,
                   CASE WHEN u.role = 'est' THEN e.salon ELSE NULL END as salon
            FROM usuarios u
            LEFT JOIN profesores p ON u.id = p.id AND u.role = 'profe'
            LEFT JOIN estudiantes e ON u.id = e.id AND u.role = 'est'
            WHERE u.id = :id
            LIMIT 1
        ");
        
        $stmt->execute(['id' => $id]);
        return $stmt->fetch();
        
    } catch (PDOException $e) {
        error_log("Error en getUserById: " . $e->getMessage());
        return null;
    }
}

function logAudit($userId, $userName, $userRole, $estudianteAfectado, $accion, $extra = '') {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("
            INSERT INTO auditoria 
            (timestamp, usuario_id, usuario_nombre, role, estudiante_afectado, accion, extra, ip_address)
            VALUES (NOW(), :user_id, :user_name, :role, :estudiante, :accion, :extra, :ip)
        ");
        
        $stmt->execute([
            'user_id' => $userId,
            'user_name' => $userName,
            'role' => $userRole,
            'estudiante' => $estudianteAfectado,
            'accion' => $accion,
            'extra' => $extra,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1'
        ]);
        
        return true;
        
    } catch (PDOException $e) {
        error_log("Error en logAudit: " . $e->getMessage());
        return false;
    }
}

function calcularDefinitiva($aptitud, $actitud, $responsabilidad) {
    return round(($aptitud * 0.6) + ($actitud * 0.2) + ($responsabilidad * 0.2), 2);
}

function getNotaColor($nota) {
    $nota = floatval($nota);
    if ($nota === 0.0) return '#a0aec0';
    if ($nota < 3.0) return '#e53e3e';
    if ($nota < 4.0) return '#ed8936';
    if ($nota <= 4.5) return '#38a169';
    return '#2b6cb0';
}

function getNotaClass($nota) {
    $nota = floatval($nota);
    if ($nota === 0.0) return 'scz';
    if ($nota < 3.0) return 'scr';
    if ($nota < 4.0) return 'sco';
    if ($nota <= 4.5) return 'scg';
    return 'scb';
}

function formatearFecha($fecha, $formato = 'd/m/Y') {
    if (empty($fecha)) return '—';
    
    try {
        $dt = new DateTime($fecha);
        return $dt->format($formato);
    } catch (Exception $e) {
        return $fecha;
    }
}

function formatearTamano($bytes) {
    if ($bytes >= 1073741824) {
        return number_format($bytes / 1073741824, 2) . ' GB';
    } elseif ($bytes >= 1048576) {
        return number_format($bytes / 1048576, 2) . ' MB';
    } elseif ($bytes >= 1024) {
        return number_format($bytes / 1024, 2) . ' KB';
    }
    return $bytes . ' bytes';
}

function sendJsonResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function generarId($prefix = '') {
    return $prefix . '_' . time() . '_' . mt_rand(1000, 9999);
}

function validateUploadedFile($file, $maxSize = 5242880, $allowedTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx']) {
    $errors = [];
    
    if (!isset($file) || $file['error'] !== UPLOAD_ERR_OK) {
        $errors[] = 'Error al subir el archivo';
        return $errors;
    }
    
    if ($file['size'] > $maxSize) {
        $errors[] = 'El archivo excede el tamaño máximo permitido (' . formatearTamano($maxSize) . ')';
    }
    
    $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (!in_array($extension, $allowedTypes)) {
        $errors[] = 'Tipo de archivo no permitido. Permitidos: ' . implode(', ', $allowedTypes);
    }
    
    return $errors;
}
?>
