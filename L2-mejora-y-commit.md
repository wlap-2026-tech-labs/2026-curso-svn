# Laboratorio 2: Incorporar una mejora con un commit controlado

En el día a día no basta con editar archivos en disco: hay que indicar a SVN las operaciones estructurales, revisar las diferencias antes de publicar, comprobar que el cambio es coherente y evitar subir ediciones accidentales o archivos generados.

### Objetivo

Registrar un commit acotado, coherente y verificable con una mejora de mantenimiento, dejando fuera una edición accidental y un archivo generado sin versionar.

### Punto de partida

- Copia de trabajo de `trunk` preparada para L2 en `cd /workspaces/2026-curso-svn/practicas-svn/L2/monitor-servicios`.
- Una copia limpia no contiene cambios ajenos por sí sola: el mecanismo de preparación del escenario de L2 cargará en tu copia de trabajo la edición accidental en `README.md` y el archivo sin versionar `debug_local.log`.
- Carga el escenario de L2 ejecutando:
  ```bash
  bash scripts/reset-lab.sh L2
  source /tmp/svn-sandboxes/L2/lab.env
  cd /workspaces/2026-curso-svn/practicas-svn/L2/monitor-servicios
  ```

### En qué consiste

Actualizarás tu copia, aplicarás cuatro cambios pequeños de mantenimiento, clasificarás todo lo que aparezca en el estado local, descartarás lo que no corresponde, comprobarás que la configuración y los ejemplos son coherentes y publicarás un commit verificable.

### 1 — Comprueba el estado inicial y actualiza

**Acción:**
1. Consulta `status` antes de tocar nada:
   ```bash
   svn status
   ```
2. Observa que ya aparecen los dos elementos cargados por el escenario (`M       README.md` modificado y `?       debug_local.log` sin versionar). No los toques todavía.
3. Ejecuta `update` para asegurarte de partir de la última revisión compartida:
   ```bash
   svn update
   ```

**Por qué:** Revisar el estado antes de empezar evita confundir trabajo previo o ruido local con los cambios de tu nueva tarea.

**Resultado esperado:** Copia actualizada (`At revision 3.`) con los dos elementos previos identificados.

### 2 — Aplica la solicitud de mantenimiento

Realiza exactamente estos cuatro cambios sobre la copia de trabajo:

1. **Modificar:** Abre `config/servicios.conf` y cambia `umbral_aviso_ms` del servicio `[pagos]` de `500` a `400`.
2. **Añadir:** Crea el archivo `examples/caso_aviso_pagos.json` con el siguiente contenido y regístralo en SVN (`add`):
   ```json
   {
     "servicio": "pagos",
     "latencia_ms": 450,
     "estado_esperado": "AVISO"
   }
   ```
   ```bash
   svn add examples/caso_aviso_pagos.json
   ```
3. **Mover / renombrar:** Renombra `docs/notas_umbrales.md` a `docs/reglas_umbrales.md` usando la operación de SVN (`move`):
   ```bash
   svn move docs/notas_umbrales.md docs/reglas_umbrales.md
   ```
4. **Eliminar:** Retira el ejemplo obsoleto `examples/caso_legacy.json` usando la operación de SVN (`delete`):
   ```bash
   svn delete examples/caso_legacy.json
   ```

**Por qué:** Usar las operaciones del cliente SVN (`add`, `move`, `delete`) en lugar de solo el explorador de archivos permite que SVN conserve la historia del renombrado y registre correctamente altas y bajas.

**Resultado esperado:** Los cuatro cambios están aplicados en tu copia de trabajo.

### 3 — Inspecciona el estado completo y las diferencias

**Acción:**
1. Ejecuta `status` para listar todos los elementos alterados:
   ```bash
   svn status
   ```
2. Ejecuta `diff` para revisar línea a línea qué ha cambiado en los archivos modificados:
   ```bash
   svn diff
   ```

**Por qué:** `status` te dice *qué archivos* han cambiado; `diff` te confirma *qué líneas* contienen realmente esos cambios.

**Resultado esperado:** Ves tus cuatro cambios de la mejora, además de la modificación en `README.md` y el archivo sin versionar `debug_local.log`.

### 4 — Clasifica los cambios y limpia el alcance

**Acción:** Clasifica cada elemento de `status` en una de estas tres categorías:
- **Pertenece a la mejora:** debe entrar en el commit.
- **Edición accidental en archivo versionado:** comprueba la línea afectada y descártala de forma dirigida (`revert` únicamente sobre ese archivo):
  ```bash
  svn diff README.md
  svn revert README.md
  ```
- **Archivo generado sin versionar:** no debe añadirse al control de versiones (`debug_local.log`).

> **Atención:** Antes de descartar, comprueba con `diff` exactamente qué línea se va a perder. No apliques un `revert` global sobre toda la carpeta.

**Por qué:** Decidir qué entra y qué queda fuera antes del commit garantiza que el historial sea limpio y revisable por el resto del equipo.

**Resultado esperado:** Al volver a ejecutar `svn status`, `README.md` ya no aparece modificado, `debug_local.log` sigue sin versionar (`?`) y solo quedan preparados los cuatro cambios de la mejora.

### 5 — Comprueba la coherencia antes de publicar

**Acción:** Ejecuta la comprobación mínima de «Monitor de servicios» sobre `examples/caso_normal.json` y `examples/caso_aviso_pagos.json`:
```bash
python3 src/evaluador.py config/servicios.conf examples/caso_normal.json examples/caso_aviso_pagos.json
```

**Por qué:** Revisar el `diff` confirma qué cambiaste, pero ejecutar la comprobación demuestra que el nuevo ejemplo y el umbral ajustado producen el resultado esperado.

**Resultado esperado:** Ambos ejemplos coinciden con su estado declarado (`OK` y `AVISO`, código de salida `0`) y la configuración mantiene `umbral_aviso_ms < umbral_critico_ms`.

### 6 — Registra y verifica el commit

**Acción:**
1. Ejecuta `commit` con un mensaje claro que explique el propósito de la mejora y anota el número de revisión creado (`r4`):
   ```bash
   svn commit -m "Ajusta umbral de pagos y actualiza documentacion y ejemplos"
   ```
2. Consulta explícitamente la revisión que acaba de crear el commit (`r4`), muestra sus rutas afectadas y revisa sus diferencias:
   ```bash
   svn log -v -r 4 "$URL_SANDBOX_ALUMNO/trunk"
   svn diff -c 4 "$URL_SANDBOX_ALUMNO/trunk"
   ```
3. Consulta el estado local (`status`):
   ```bash
   svn status
   ```

**Por qué:** Un commit solo está terminado cuando verificas directamente la revisión publicada en el repositorio; consultar el historial local sin especificar revisión u opciones de rutas puede no mostrar la nueva revisión ni el detalle de archivos afectados.

**Resultado esperado:**
- La consulta explícita de la revisión `r4` incluye las cuatro operaciones solicitadas (`M /trunk/config/servicios.conf`, `D /trunk/docs/notas_umbrales.md`, `A /trunk/docs/reglas_umbrales.md (from /trunk/docs/notas_umbrales.md:3)`, `A /trunk/examples/caso_aviso_pagos.json`, `D /trunk/examples/caso_legacy.json`) y no modifica `README.md` ni incorpora `debug_local.log`.
- `svn status` solo muestra `?       debug_local.log` como archivo sin versionar (estado local comprendido).

### Criterio de finalización

La comprobación mínima pasó con ambos ejemplos antes de publicar, la revisión está registrada en el repositorio con las cuatro operaciones solicitadas y un mensaje comprensible, y excluye tanto la edición accidental como el archivo generado.

## Comprueba tu entendimiento

- ¿Qué habría ocurrido si hubieras renombrado `docs/notas_umbrales.md` desde el explorador de archivos sin usar la operación de SVN?
- ¿Por qué el archivo `debug_local.log` sigue apareciendo en `status` después del commit, y por qué eso no indica un error en tu publicación?

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
| --- | --- | --- |
| `examples/caso_aviso_pagos.json` no se incluyó en el commit | Creaste el archivo en disco pero olvidaste ejecutar `add` | Ejecuta `svn add examples/caso_aviso_pagos.json` y registra un commit adicional explicándolo |
| Descartaste tus cambios de `config/servicios.conf` por error | Ejecutaste `revert` sobre toda la carpeta o sobre el archivo equivocado | Vuelve a aplicar el cambio de `500` a `400` en `config/servicios.conf` |
| `docs/notas_umbrales.md` aparece como desaparecido (`!`) y el nuevo como sin versionar (`?`) | Renombraste el archivo fuera de SVN | Devuelve el nombre original en disco y realiza el renombrado con `svn move docs/notas_umbrales.md docs/reglas_umbrales.md` |

## Resolución de referencia (autoevaluación)

<details>
<summary>Desplegar para comprobar tu resultado y entender cada evidencia</summary>

### 1. Clasificación esperada antes del commit (Paso 4)
- **Pertenecen a la mejora (entran en el commit):**
  - `M       config/servicios.conf`: umbral de aviso de `[pagos]` ajustado de `500` a `400`.
  - `A       examples/caso_aviso_pagos.json`: archivo nuevo registrado con `svn add`.
  - `D       docs/notas_umbrales.md` y `A  +    docs/reglas_umbrales.md`: renombrado mediante `svn move`. El símbolo `A +` indica *añadido con historial*, conservando la trazabilidad previa del documento.
  - `D       examples/caso_legacy.json`: baja registrada con `svn delete`.
- **Edición accidental a descartar (`README.md`):**
  - `svn diff README.md` muestra la línea accidental `NOTA_BORRAR_PRUEBA_LOCAL`.
  - Se descarta de forma dirigida con `svn revert README.md` (evitando siempre un `svn revert -R .` global que borraría tu trabajo válido).
- **Archivo generado a no añadir (`?       debug_local.log`):**
  - Al no estar versionado (`?`), SVN lo excluye automáticamente del commit; basta con no ejecutar `svn add` sobre él.

### 2. Comprobación técnica y verificación del commit (Pasos 5 y 6)
- **Validación con `evaluador.py`:**
  - `python3 src/evaluador.py config/servicios.conf examples/caso_normal.json examples/caso_aviso_pagos.json` finaliza con código de salida `0`:
    - `caso_normal.json` (latencia `220 < 400`) → `OK`.
    - `caso_aviso_pagos.json` (latencia `400 <= 450 < 1200`) → `AVISO`.
- **Revisión publicada (`r4`):**
  - `svn log -v -r 4 "$URL_SANDBOX_ALUMNO/trunk"` muestra exactamente las cuatro operaciones solicitadas (`M /trunk/config/servicios.conf`, `D /trunk/docs/notas_umbrales.md`, `A /trunk/docs/reglas_umbrales.md (from /trunk/docs/notas_umbrales.md:3)`, `A /trunk/examples/caso_aviso_pagos.json` y `D /trunk/examples/caso_legacy.json`), sin incluir `README.md` ni `debug_local.log`.
  - **Estado local final (`svn status`):** muestra únicamente `?       debug_local.log`.
  - **Variantes aceptables:** cualquier mensaje de commit claro que resuma el ajuste de umbral de `pagos` y la actualización de documentación/ejemplos es válido. Si olvidaste hacer `svn add` y publicaste un commit incompleto, también es aceptable registrar un segundo commit correctivo explicándolo.

### 3. Respuestas a «Comprueba tu entendimiento»
1. **¿Qué habría ocurrido si hubieras renombrado `docs/notas_umbrales.md` desde el explorador o con `mv` sin usar `svn move`?**
   SVN habría marcado `docs/notas_umbrales.md` como desaparecido (`!`) y `docs/reglas_umbrales.md` como archivo nuevo sin versionar (`?`). Si posteriormente lo hubieras añadido con `svn add`, se habría perdido la continuidad del historial del archivo.
2. **¿Por qué `debug_local.log` sigue apareciendo en `svn status` después del commit y por qué no es un error?**
   Porque nunca se añadió al control de versiones (`?`), así que `svn commit` lo ignora y lo conserva intacto en tu disco local. Verlo como `?` tras el commit confirma precisamente que quedó fuera del repositorio.

### 4. Si tu resultado no coincidió
- **Ejecutaste `svn revert -R .` por error:** vuelve a aplicar el cambio de `500` a `400` en `config/servicios.conf` o reinicia el escenario limpio con `bash scripts/reset-lab.sh L2`.
- **`svn log` a secas no muestra `r4` tras el commit:** es un comportamiento normal de SVN hasta actualizar la copia; consulta directamente la URL (`svn log -v -r 4 "$URL_SANDBOX_ALUMNO/trunk"`) o ejecuta `svn update`.

</details>
