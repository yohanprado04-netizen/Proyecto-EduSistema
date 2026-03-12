<?php
/**
 * EduSistema Pro v5
 * Archivo: index.php (raíz del proyecto)
 * Punto de entrada principal
 */

// Iniciar sesión
session_start();

// Configuración de errores (desactivar en producción)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Cargar módulos PHP desde la carpeta app
require_once __DIR__ . '/app/config/database.php';
require_once __DIR__ . '/app/includes/security.php';
require_once __DIR__ . '/app/includes/auth.php';
require_once __DIR__ . '/app/includes/functions.php';
require_once __DIR__ . '/app/includes/notas.php';

// Verificar si hay sesión activa
$currentUser = null;
if (isset($_SESSION['user_id'])) {
    $currentUser = getUserById($_SESSION['user_id']);
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>EduSistema Pro v5</title>

<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">

<!-- CSS Externo -->
<link rel="stylesheet" href="app/assets/css/styles.css">

<!-- Librerías externas -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

</head>
<body>

<!-- ============================================================
     LOGIN SCREEN
     ============================================================ -->
<div id="ls">
  <div class="lgw">
    <div class="lgh">
      <div class="lgm">🏛️</div>
      <h1>EduSistema<br><em>Pro</em></h1>
      <p>Plataforma académica integral — notas tripartitas, clases virtuales, excusas dirigidas, reportes y más.</p>
      <div class="lgr">
        <span class="lgc p">PROFESOR</span>
        <span class="lgc e">ESTUDIANTE</span>
      </div>
    </div>
    <div class="lgc2">
      <h2>Bienvenido</h2>
      <p class="sub">Ingresa tus credenciales institucionales</p>
      <div class="fld">
        <label>Usuario</label>
        <input type="text" id="liu" placeholder="nombre.usuario" autocomplete="username">
      </div>
      <div class="fld">
        <label>Contraseña</label>
        <input type="password" id="lip" placeholder="••••••••" autocomplete="current-password">
      </div>
      <div id="lierr" style="font-size:13px;color:var(--red);margin-bottom:12px;display:none;
        padding:8px 12px;background:var(--rbg);border-radius:8px;border:1px solid #fed7d7"></div>
      <button class="bl" onclick="doLogin()">Ingresar →</button>
    </div>
  </div>
</div>

<!-- ============================================================
     APPLICATION INTERFACE
     ============================================================ -->
<div id="app" class="hidden">
  <nav class="sidebar" id="sidebar">
    <div class="sbh">
      <div class="sblo">
        <div class="sbli">🏛️</div>
        <div>
          <div class="sbln">EduSistema Pro</div>
          <div class="sbls">Plataforma Académica</div>
        </div>
      </div>
      <div class="sbu" id="sbUser"></div>
    </div>
    <div class="sbnav" id="sbNav"></div>
    <div class="sbft">
      <button class="sbi" onclick="doLogout()" style="width:100%">
        <span class="ic">🚪</span>Cerrar Sesión
      </button>
    </div>
  </nav>
  
  <div class="main">
    <div class="topbar">
      <span class="tbti" id="tbTitle">Panel</span>
      <div class="tbr">
        <span class="tbdt" id="tbDate"></span>
        <span id="tbStatus"></span>
      </div>
    </div>
    <div class="cnt" id="contentArea"></div>
  </div>
</div>

<!-- PDF Container -->
<div id="pdfBox" class="hidden"></div>

<!-- ============================================================
     JAVASCRIPT - Cargado desde archivo externo
     ============================================================ -->
<script src="app/assets/js/app.js"></script>

<!-- ⚠️ IMPORTANTE:
     El archivo app/assets/js/app.js debe contener TODO el JavaScript del Index.html original
     Si el sistema no funciona, verifica que hayas copiado el código JavaScript completo
-->

</body>
</html>
