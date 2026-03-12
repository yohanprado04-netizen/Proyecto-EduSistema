<?php
/**
 * EduSistema Pro v5 - Funciones de Seguridad
 * Archivo: includes/security.php
 * 
 * Contiene funciones para:
 * - Hash de contraseñas (SHA-256)
 * - Sanitización de inputs
 * - Protección XSS
 */

// Salt para hash de contraseñas
define('PASSWORD_SALT', 'EduSistema_v5_2026');

/**
 * Hashear contraseña con SHA-256 + Salt
 * @param string $password Contraseña en texto plano
 * @return string Hash SHA-256
 */
function hashPassword($password) {
    if (empty($password)) {
        return '';
    }
    
    // Si ya está hasheado (64 caracteres hex), retornar sin cambio
    if (preg_match('/^[0-9a-f]{64}$/', $password)) {
        return $password;
    }
    
    return hash('sha256', PASSWORD_SALT . $password);
}

/**
 * Verificar contraseña contra hash almacenado
 * Soporta migración desde plaintext
 * 
 * @param string $inputPassword Contraseña ingresada
 * @param string $storedHash Hash almacenado en BD
 * @return bool
 */
function verifyPassword($inputPassword, $storedHash) {
    $hash = hashPassword($inputPassword);
    
    // Verificar hash SHA-256
    if ($hash === $storedHash) {
        return true;
    }
    
    // Migración: aceptar plaintext temporal
    if ($inputPassword === $storedHash) {
        return true;
    }
    
    return false;
}

/**
 * Sanitizar string - protección XSS
 * Convierte caracteres especiales a entidades HTML
 * 
 * @param mixed $data String o array a sanitizar
 * @return mixed Datos sanitizados
 */
function sanitize($data) {
    // Si es array, aplicar recursivamente
    if (is_array($data)) {
        return array_map('sanitize', $data);
    }
    
    // Limpiar string
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
    
    return $data;
}

/**
 * Escapar string para output HTML seguro
 * @param string $str String a escapar
 * @return string String escapado
 */
function escapeHtml($str) {
    if ($str === null) {
        return '';
    }
    
    return htmlspecialchars((string)$str, ENT_QUOTES, 'UTF-8');
}

/**
 * Validar formato de fecha
 * @param string $date Fecha a validar
 * @param string $format Formato esperado (default: Y-m-d)
 * @return bool
 */
function isValidDate($date, $format = 'Y-m-d') {
    $d = DateTime::createFromFormat($format, $date);
    return $d && $d->format($format) === $date;
}

/**
 * Validar email
 * @param string $email Email a validar
 * @return bool
 */
function isValidEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

/**
 * Generar token CSRF
 * @return string Token generado
 */
function generateCsrfToken() {
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

/**
 * Verificar token CSRF
 * @param string $token Token a verificar
 * @return bool
 */
function verifyCsrfToken($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

/**
 * Limpiar nombre de archivo
 * Remueve caracteres peligrosos
 * @param string $filename Nombre de archivo
 * @return string Nombre limpio
 */
function sanitizeFilename($filename) {
    // Remover caracteres especiales
    $filename = preg_replace('/[^a-zA-Z0-9._-]/', '_', $filename);
    
    // Evitar doble extensión (.php.txt)
    $filename = preg_replace('/\.+/', '.', $filename);
    
    return $filename;
}
?>
