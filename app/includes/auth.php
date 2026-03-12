<?php
/**
 * EduSistema Pro v5 - Autenticación y Sesiones
 * Archivo: includes/auth.php
 */

define('SESSION_TIMEOUT', 20 * 60); // 20 minutos

function authenticateUser($usuario, $password) {
    try {
        $db = Database::getInstance()->getConnection();
        
        $stmt = $db->prepare("
            SELECT u.*, 
                   CASE 
                       WHEN u.role = 'profe' THEN (SELECT p.ciclo FROM profesores p WHERE p.id = u.id)
                       WHEN u.role = 'est' THEN (SELECT e.salon FROM estudiantes e WHERE e.id = u.id)
                       ELSE NULL
                   END as extra_info
            FROM usuarios u
            WHERE u.usuario = :usuario AND u.activo = 1
            LIMIT 1
        ");
        
        $stmt->execute(['usuario' => $usuario]);
        $user = $stmt->fetch();
        
        if (!$user) return null;
        
        // Verificar bloqueo
        if ($user['blocked']) {
            $stmt = $db->prepare("SELECT fecha_bloqueo FROM usuarios_bloqueados WHERE usuario = :usuario");
            $stmt->execute(['usuario' => $usuario]);
            $bloqueo = $stmt->fetch();
            
            if ($bloqueo) {
                $fechaBloqueo = new DateTime($bloqueo['fecha_bloqueo']);
                $ahora = new DateTime();
                $diff = $ahora->diff($fechaBloqueo);
                
                if ($diff->i >= 30 || $diff->h > 0 || $diff->days > 0) {
                    $stmt = $db->prepare("UPDATE usuarios SET blocked = 0 WHERE id = :id");
                    $stmt->execute(['id' => $user['id']]);
                    
                    $stmt = $db->prepare("UPDATE usuarios_bloqueados SET bloqueado = 0 WHERE usuario = :usuario");
                    $stmt->execute(['usuario' => $usuario]);
                } else {
                    return ['error' => 'blocked', 'message' => 'Usuario bloqueado. Intenta en 30 minutos.'];
                }
            }
        }
        
        if (!verifyPassword($password, $user['password'])) {
            return null;
        }
        
        return $user;
        
    } catch (PDOException $e) {
        error_log("Error en authenticateUser: " . $e->getMessage());
        return null;
    }
}

function registerFailedLogin($usuario) {
    static $intentos = [];
    
    if (!isset($intentos[$usuario])) {
        $intentos[$usuario] = 0;
    }
    
    $intentos[$usuario]++;
    
    if ($intentos[$usuario] >= 5) {
        try {
            $db = Database::getInstance()->getConnection();
            
            $stmt = $db->prepare("UPDATE usuarios SET blocked = 1 WHERE usuario = :usuario");
            $stmt->execute(['usuario' => $usuario]);
            
            $stmt = $db->prepare("
                INSERT INTO usuarios_bloqueados (usuario, bloqueado, fecha_bloqueo, razon) 
                VALUES (:usuario, 1, NOW(), '5 intentos fallidos de login')
                ON DUPLICATE KEY UPDATE bloqueado = 1, fecha_bloqueo = NOW()
            ");
            $stmt->execute(['usuario' => $usuario]);
            
            logAudit(null, '?', $usuario, '?', 'Cuenta bloqueada tras 5 intentos fallidos', '');
            
            return true;
        } catch (PDOException $e) {
            error_log("Error en registerFailedLogin: " . $e->getMessage());
        }
    }
    
    return false;
}

function createUserSession($user) {
    $_SESSION['user_id'] = $user['id'];
    $_SESSION['user_name'] = $user['nombre'];
    $_SESSION['user_role'] = $user['role'];
    $_SESSION['user_usuario'] = $user['usuario'];
    $_SESSION['login_time'] = time();
    $_SESSION['last_activity'] = time();
    
    session_regenerate_id(true);
}

function destroyUserSession() {
    $_SESSION = [];
    
    if (isset($_COOKIE[session_name()])) {
        setcookie(session_name(), '', time() - 3600, '/');
    }
    
    session_destroy();
}

function checkSession() {
    if (isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity']) > SESSION_TIMEOUT) {
        destroyUserSession();
        return false;
    }
    
    $_SESSION['last_activity'] = time();
    return isset($_SESSION['user_id']);
}

function getCurrentUser() {
    if (!isset($_SESSION['user_id'])) {
        return null;
    }
    
    return getUserById($_SESSION['user_id']);
}

function hasRole($requiredRole) {
    if (!isset($_SESSION['user_role'])) {
        return false;
    }
    
    if (is_array($requiredRole)) {
        return in_array($_SESSION['user_role'], $requiredRole);
    }
    
    return $_SESSION['user_role'] === $requiredRole;
}

function canAccessPanel($panelId) {
    if (!isset($_SESSION['user_role'])) {
        return false;
    }
    
    $permissions = [
        'admin' => ['dash', 'asal', 'apri', 'abac', 'aprf', 'amat', 'anot', 'areh', 'afec', 'ablk', 'aaud', 'aexp', 'aexc', 'avcl', 'ahist'],
        'profe' => ['ph', 'pnot', 'past', 'pvir', 'ptar', 'prec', 'phist'],
        'est' => ['eb', 'east', 'etare', 'eexc', 'eprof', 'evir', 'ereh', 'ehist']
    ];
    
    $role = $_SESSION['user_role'];
    return isset($permissions[$role]) && in_array($panelId, $permissions[$role]);
}
?>
