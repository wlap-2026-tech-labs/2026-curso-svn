# Laboratorio 1: Explorar el repositorio y preparar la copia de trabajo

Antes de modificar cualquier archivo de un proyecto versionado, necesitas saber exactamente de qué repositorio y línea procede tu copia local y qué historial tiene. En este laboratorio prepararás tu copia de trabajo de «Monitor de servicios» y comprobarás su punto de partida.

### Objetivo

Disponer de una copia de trabajo operativa de `trunk`, verificar su URL, revisión y estado local, y explicar un cambio real registrado en el historial de un artefacto.

### Punto de partida

- Entorno verificado según `PREPARACION.md`.
- Ejecuta `bash scripts/reset-lab.sh L1` y carga las variables del entorno con `source /tmp/svn-sandboxes/L1/lab.env`.
- URL de tu repositorio sandbox: `$URL_SANDBOX_ALUMNO` (`file:///tmp/svn-sandboxes/L1/repo`).
- Carpeta local de prácticas: `/workspaces/2026-svn-test/practicas-svn/L1/`.

### En qué consiste

Localizarás la línea principal (`trunk`), obtendrás tu copia de trabajo, inspeccionarás sus metadatos y elegirás uno de dos artefactos para investigar su historial.

### 1 — Explora la estructura del repositorio

**Acción:** Consulta el contenido de `<URL_SANDBOX_ALUMNO>` sin descargar todavía los archivos:
```bash
svn list "$URL_SANDBOX_ALUMNO"
```

**Por qué:** Confirmar la estructura (`trunk`, `branches`, `tags`) antes de descargar evita obtener por error todo el repositorio o una rama equivocada.

**Resultado esperado:** Ves las tres carpetas principales (`branches/`, `tags/`, `trunk/`).

### 2 — Obtén tu copia de trabajo de `trunk`

**Acción:** Sitúate en `cd /workspaces/2026-svn-test/practicas-svn/L1` y descarga (`checkout`) la URL `<URL_SANDBOX_ALUMNO>/trunk` en un directorio local llamado `monitor-servicios`:
```bash
rm -rf monitor-servicios
svn checkout "$URL_SANDBOX_ALUMNO/trunk" monitor-servicios
```

**Por qué:** El `checkout` se realiza para crear cada copia de trabajo junto con los metadatos de SVN; no se repite para actualizarla.

**Resultado esperado:** Se crea la carpeta `monitor-servicios/` con `README.md`, `config/`, `docs/`, `examples/` y `src/` (`Checked out revision 3.`).

### 3 — Comprueba el origen, la revisión y el estado local

**Acción:** Sitúate dentro de `monitor-servicios/` (`cd monitor-servicios`) y consulta:
1. La información de la copia (`info`):
   ```bash
   svn info
   ```
2. El estado de los archivos locales (`status`):
   ```bash
   svn status
   ```

**Por qué:** El nombre de tu carpeta local (`monitor-servicios`) no demuestra a qué línea apunta. `info` confirma la URL real y la revisión de partida; `status` confirma si hay cambios locales.

**Resultado esperado:**
- `info` muestra `URL: file:///tmp/svn-sandboxes/L1/repo/trunk` y `Revision: 3`.
- `status` no muestra archivos modificados ni sin versionar (salida vacía).

### 4 — Actualiza la copia de trabajo

**Acción:** Ejecuta una actualización (`update`) sobre tu copia de trabajo:
```bash
svn update
```

**Por qué:** `update` es la operación habitual para recibir cambios publicados por otros sin volver a hacer `checkout`.

**Resultado esperado:** El cliente confirma que tu copia está actualizada e indica la revisión vigente (`At revision 3.`).

### 5 — Investiga el historial de un artefacto

**Acción:** Elige **uno** de estos dos archivos (distintos del visto en la demostración):
- `config/servicios.conf`
- `examples/caso_normal.json`

Consulta su historial (`log`) y localiza una revisión en la que haya sido modificado:
```bash
svn log config/servicios.conf
# o bien:
svn log examples/caso_normal.json
```

**Por qué:** El historial te permite pasar de ver un archivo aislado a entender quién lo cambió, cuándo y con qué propósito.

**Resultado esperado:** Obtienes al menos una entrada con número de revisión (`r2` para `config/servicios.conf` o `r3` para `examples/caso_normal.json`), autor (`vscode`), fecha y mensaje descriptivo.

### Criterio de finalización

Tu laboratorio está completo cuando puedes responder brevemente (en el medio común de la sesión, sin crear fichas adicionales) con la evidencia directa de tu cliente SVN:
1. Qué URL exacta y qué revisión identifican tu punto de partida.
2. Qué te confirma que no hay cambios locales pendientes.
3. Qué archivo elegiste y qué cambio explica su última revisión registrada.

## Comprueba tu entendimiento

- Si renombraras tu carpeta local de `monitor-servicios` a `trunk-viejo`, ¿cambiaría la línea del repositorio a la que apunta tu copia de trabajo? ¿Con qué operación lo comprobarías?
- Si `status` no devuelve ninguna salida, ¿demuestra eso automáticamente que tienes la última revisión del repositorio?

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
| --- | --- | --- |
| Error de acceso o repositorio no encontrado | URL mal escrita o variables no cargadas | Ejecuta `source /tmp/svn-sandboxes/L1/lab.env` y comprueba `$URL_SANDBOX_ALUMNO` |
| La carpeta local contiene `trunk/`, `branches/` y `tags/` | Hiciste `checkout` de la raíz del repositorio en lugar de `/trunk` | Crea una nueva carpeta limpia y repite el paso 2 apuntando a `$URL_SANDBOX_ALUMNO/trunk` |
| El cliente indica que el directorio no es una copia de trabajo | Ejecutaste `info` o `status` fuera de `monitor-servicios/` | Accede al directorio `monitor-servicios/` y repite la consulta |

## Resolución de referencia (autoevaluación)

<details>
<summary>Desplegar para comprobar tu resultado y entender cada evidencia</summary>

### 1. Evidencias esperadas (`HEAD=3`) y qué demuestra cada una
- **Origen y revisión (`svn info`):**
  - **Salida esperada:** `URL: file:///tmp/svn-sandboxes/L1/repo/trunk` y `Revision: 3`.
  - **Qué te confirma:** que tu carpeta local `monitor-servicios/` apunta realmente a la línea principal (`/trunk`) y parte de la revisión global `3` del repositorio, con independencia de cómo se llame la carpeta en tu disco.
- **Estado local (`svn status`):**
  - **Salida esperada:** salida vacía (sin líneas).
  - **Qué te confirma:** que no hay archivos modificados, añadidos, borrados ni sin versionar en tu copia de trabajo. Es una comprobación puramente local.
- **Sincronización (`svn update`):**
  - **Salida esperada:** `At revision 3.`
  - **Qué te confirma:** que has consultado el repositorio y tu copia está alineada con la última revisión disponible (`HEAD`), sin necesidad de repetir `checkout`.
- **Historial del artefacto elegido (`svn log <archivo>`):**
  - Si elegiste `config/servicios.conf`: identifica `r2` (`Ajusta timeout_ms de pagos a 2000`), autor `vscode`. Aunque la copia esté en `r3`, este archivo no se tocó en `r3` y conserva su último cambio en `r2`.
  - Si elegiste `examples/caso_normal.json`: identifica `r3` (incorporación del ejemplo), autor `vscode`.

### 2. Respuestas a «Comprueba tu entendimiento»
1. **¿Cambiaría la línea del repositorio al renombrar la carpeta local a `trunk-viejo`?**
   No. El nombre del directorio local no altera la relación con el servidor, que queda registrada en los metadatos internos (`.svn`). Se comprueba ejecutando `svn info`: el campo `URL` seguirá apuntando a `.../trunk`.
2. **¿Demuestra un `svn status` vacío que tienes la última revisión del repositorio?**
   No. Por defecto, `svn status` solo inspecciona tu copia de trabajo local para detectar cambios pendientes; no consulta al servidor si otros compañeros han publicado revisiones nuevas. Para sincronizar con el repositorio se utiliza `svn update`.

### 3. Si tu resultado no coincidió
- **Variable `$URL_SANDBOX_ALUMNO` vacía:** asegúrate de haber ejecutado `source /tmp/svn-sandboxes/L1/lab.env` en la misma terminal.
- **Ves `trunk/`, `branches/` y `tags/` dentro de tu carpeta:** hiciste `checkout` de la raíz del repositorio en lugar de `/trunk`. Repite el paso 2 apuntando a `$URL_SANDBOX_ALUMNO/trunk` o reinicia el escenario con `bash scripts/reset-lab.sh L1`.

</details>
