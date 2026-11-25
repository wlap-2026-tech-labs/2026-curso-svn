# Preparación común — Laboratorios de Apache Subversion

Antes de comenzar el Laboratorio 1, asegúrate de disponer del entorno básico de prácticas. Esta configuración es común para toda la sesión y no requiere administrar ningún servidor.

## Requisitos previos

1. **Cliente SVN instalado:** Cliente oficial de línea de comandos `svn` (versión `1.14.2`, módulo `ra_local` habilitado para `file://`).
2. **Acceso al sandbox individual:**
   - URL base de tu repositorio: `<URL_SANDBOX_ALUMNO>` con formato `file:///tmp/svn-sandboxes/<L>/repo` (exportada en `/tmp/svn-sandboxes/<L>/lab.env`).
   - Credenciales asignadas: No requiere credenciales ni acceso de red (acceso local mediante `file://` con el usuario `vscode`).
3. **Carpeta local de trabajo:** Directorio de prácticas en Linux (GitHub Codespace): `/workspaces/2026-svn-test/practicas-svn/<L>/`.
4. **Entorno mínimo de comprobación:** `Python 3` (`python3`, versión `3.12.16`, biblioteca estándar) para ejecutar `src/evaluador.py`.

## Verificación rápida del entorno

Antes de iniciar L1, comprueba que tu cliente SVN y Python responden correctamente:

- **Acción:** Ejecuta en la terminal:
  ```bash
  svn --version
  python3 --version
  ```
- **Resultado esperado:** La terminal muestra `svn, version 1.14.2` (con módulo `ra_local`) y `Python 3.12.16` sin errores.

## Recuperación entre laboratorios

Cada laboratorio parte de un estado conocido. Si en algún momento un ejercicio queda bloqueado o incompleto, puedes iniciar el siguiente laboratorio desde su punto de partida limpio sin depender del resultado anterior:

- **Mecanismo de reinicio:** Ejecuta `bash scripts/reset-lab.sh <L1|L2|L3|L4|L5|L6>` (invocable desde cualquier directorio) para recrear limpiamente `/tmp/svn-sandboxes/<L>/repo`, su archivo `/tmp/svn-sandboxes/<L>/lab.env` y la copia de trabajo en `/workspaces/2026-svn-test/practicas-svn/<L>/`.

> **Aviso importante:** No manipules ni borres manualmente la carpeta oculta `.svn` dentro de tu copia de trabajo. Contiene los metadatos que SVN necesita para rastrear tus cambios.

## Requisitos adicionales para la Sesión 2 (L4–L6)

Estos puntos amplían la configuración base de la Sesión 1:

1. **Copias de trabajo separadas:** En la Sesión 2 trabajaremos con `trunk` y con ramas en directorios locales independientes dentro de tu carpeta de prácticas (por ejemplo, `monitor-servicios-trunk/` y `monitor-servicios-notificaciones/`), para que el destino de cada operación sea siempre visible.
2. **Permisos en `branches/` y `tags/`:** Tu usuario del sandbox individual (`vscode`) dispone de permisos completos de lectura y escritura bajo `file:///tmp/svn-sandboxes/<L>/repo/branches/` y `file:///tmp/svn-sandboxes/<L>/repo/tags/`.
3. **Puntos de recuperación de S2:** Cada laboratorio de la Sesión 2 (L4, L5 y L6) dispone de un punto de partida independiente ejecutando `bash scripts/reset-lab.sh L4`, `bash scripts/reset-lab.sh L5` o `bash scripts/reset-lab.sh L6`.
