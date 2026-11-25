# Laboratorio 3: Diagnosticar y recuperar una modificación

Publicar una recuperación indiscriminada basada en archivos antiguos puede retirar cambios válidos posteriores. En este laboratorio investigarás el historial para localizar el origen de una incidencia y elegirás una recuperación controlada.

### Objetivo

Identificar la revisión que introdujo una configuración inválida, reparar el comportamiento conservando los cambios posteriores válidos y registrar la recuperación con una justificación trazable.

### Punto de partida

- Punto de partida independiente de L3 (no depende de tu resultado en L2).
- Prepara o reinicia el escenario de L3 ejecutando:
  ```bash
  bash scripts/reset-lab.sh L3
  source /tmp/svn-sandboxes/L3/lab.env
  cd /workspaces/2026-curso-svn/practicas-svn/L3/monitor-servicios
  ```

### En qué consiste

Comprobarás el síntoma, investigarás el historial y las diferencias entre revisiones, decidirás la acción de recuperación más adecuada, verificarás el resultado completo y registrarás la reparación.

### 1 — Inspecciona el síntoma

**Acción:** Ejecuta la comprobación mínima de «Monitor de servicios» sobre tu copia de trabajo:
```bash
python3 src/evaluador.py config/servicios.conf examples/caso_normal.json examples/caso_aviso_pagos.json
```

**Por qué:** Antes de buscar en el historial necesitas confirmar el síntoma concreto que debes resolver.

**Resultado esperado:** La comprobación falla (código de salida `2`) indicando una incoherencia en los umbrales del servicio `pagos`: `umbral_aviso_ms=400 debe ser estrictamente menor que umbral_critico_ms=200`.

### 2 — Localiza las revisiones candidatas en el historial

**Acción:** Consulta el historial reciente (`log`) del proyecto para revisar los últimos commits (autor, fecha y mensaje):
```bash
svn log -l 5 "$URL_SANDBOX_ALUMNO/trunk"
```

**Por qué:** El historial te orienta hacia las revisiones sospechosas, pero el mensaje por sí solo no demuestra cuál introdujo el defecto ni qué otros cambios llegaron después.

**Resultado esperado:** Identificas la revisión candidata relacionada con la configuración (`r2` / `$REV_DEFECTO`) y otra revisión posterior con un cambio diferente en la documentación (`r3` / `$REV_CAMBIO_VALIDO`).

### 3 — Compara las diferencias de las revisiones candidatas

**Acción:** Inspecciona los cambios exactos (`diff`) introducidos por las dos últimas revisiones relevantes:
```bash
svn diff -c "$REV_DEFECTO" "$URL_SANDBOX_ALUMNO/trunk"
svn diff -c "$REV_CAMBIO_VALIDO" "$URL_SANDBOX_ALUMNO/trunk"
```

**Por qué:** Comparar las diferencias te permite confirmar con evidencia qué revisión rompió la regla y qué trabajo posterior sigue siendo válido y debe conservarse.

**Resultado esperado:** Confirmas exactamente que en `r2` se alteró `umbral_critico_ms` de `1200` a `200` en `config/servicios.conf` y que en `r3` se añadió el bloque `## Escalado ante estado CRÍTICO` en `docs/reglas_umbrales.md`.

### 4 — Decide y aplica la recuperación

**Acción:** Con la evidencia del paso 3, elige la acción de recuperación más adecuada entre:
- **Reversión controlada (integración inversa)** de la revisión problemática (`r2`), o
- **Corrección dirigida hacia adelante** sobre el parámetro incorrecto.

Aplica la reversión controlada sobre tu copia de trabajo:
```bash
svn merge -c "-$REV_DEFECTO" "$URL_SANDBOX_ALUMNO/trunk" .
```

> **Atención:** Actualizar a una revisión anterior permite inspeccionar ese estado, pero no repara la línea vigente. Sobrescribir después el proyecto completo con archivos antiguos sí podría retirar cambios válidos si se publica ese resultado.

**Por qué:** La acción de recuperación debe eliminar el defecto sin deshacer trabajo correcto de otras revisiones.

**Resultado esperado:** El cambio de reparación queda aplicado en tu copia de trabajo (`U    config/servicios.conf`, aún sin publicar).

### 5 — Verifica la reparación y el cambio conservado

**Acción:**
1. Revisa `status` y `diff` para confirmar qué vas a publicar:
   ```bash
   svn status
   svn diff
   ```
2. Vuelve a ejecutar la comprobación mínima de «Monitor de servicios»:
   ```bash
   python3 src/evaluador.py config/servicios.conf examples/caso_normal.json examples/caso_aviso_pagos.json
   ```
3. Comprueba que la sección de escalado en `docs/reglas_umbrales.md` sigue intacta:
   ```bash
   grep -n -A2 "## Escalado ante estado CRÍTICO" docs/reglas_umbrales.md
   ```

**Por qué:** Que un comando termine sin errores no demuestra que el problema esté resuelto ni que el resto del proyecto siga intacto.

**Resultado esperado:**
- La comprobación mínima pasa sin errores (`OK` y `AVISO`, código de salida `0`).
- El cambio posterior válido en `docs/reglas_umbrales.md` permanece sin alteraciones.
- Las diferencias muestran la restauración `umbral_critico_ms=1200` en `config/servicios.conf` y, cuando corresponda, los metadatos de integración generados por SVN (`svn:mergeinfo`). No aparecen modificaciones ajenas al ejercicio.

### 6 — Registra la recuperación con justificación trazable

**Acción:** Publica el `commit` incluyendo en el mensaje qué revisión causó la incidencia, qué evidencia lo confirmó y por qué elegiste esa acción de recuperación:
```bash
svn commit -m "Revierte r2: umbral_critico_ms=200 en pagos rompia la regla; conserva r3 de documentacion"
```

**Por qué:** El propio mensaje del commit deja la trazabilidad en el historial del repositorio sin necesidad de rellenar fichas paralelas.

**Resultado esperado:** Nueva revisión publicada en el repositorio (`r4`); la revisión defectuosa original (`r2`) sigue visible en el historial, pero el estado vigente queda reparado.

### Criterio de finalización

La comprobación mínima pasa, el cambio posterior válido sigue intacto y el historial muestra tu nueva revisión de reparación (`r4`) con su justificación breve.

## Comprueba tu entendimiento

- ¿Por qué `revert` local no sirve para deshacer un cambio que ya fue publicado en el repositorio?
- Después de tu reparación, ¿desaparece del historial la revisión que introdujo el error? ¿Por qué?

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
| --- | --- | --- |
| La copia quedó situada en una revisión antigua y no ves el cambio posterior válido | Ejecutaste `update` hacia una revisión anterior para consultar el pasado | Inspecciona primero si tienes cambios locales que conservar; si la copia está limpia, ejecuta `svn update` a `HEAD`. Recuerda que `revert` no cambia la revisión base de la copia |
| Al preparar la reparación desapareció el bloque de escalado de `docs/reglas_umbrales.md` | Sobrescribiste manualmente el proyecto completo con archivos de una revisión antigua | Inspecciona qué cambios locales tienes antes de descartar, restaura `docs/reglas_umbrales.md` o reinicia con `bash scripts/reset-lab.sh L3` y repite el paso 4 actuando solo sobre `r2` |
| La comprobación sigue fallando tras el comando de recuperación | Aplicaste el cambio sobre un archivo o revisión equivocados | Revisa `svn diff` contra la regla de `docs/reglas_umbrales.md` antes de hacer commit |
| El cliente indica que no hay cambios que publicar | Consultaste una revisión antigua en modo lectura sin modificar la copia de trabajo | Asegúrate de estar en la referencia vigente, aplica `svn merge -c "-$REV_DEFECTO" "$URL_SANDBOX_ALUMNO/trunk" .` y verifica con `svn status` |

## Resolución de referencia (autoevaluación)

<details>
<summary>Desplegar para comprobar tu resultado y entender cada evidencia</summary>

### 1. Diagnóstico esperado (`HEAD=3`) y qué demuestra cada evidencia
- **Síntoma inicial (`evaluador.py`):**
  - `python3 src/evaluador.py config/servicios.conf examples/caso_normal.json examples/caso_aviso_pagos.json` falla con código de salida `2` indicando que `umbral_aviso_ms=400 debe ser estrictamente menor que umbral_critico_ms=200`.
  - **Qué te confirma:** el fallo concreto que debes resolver antes de abrir el historial.
- **Revisión problemática (`r2` / `$REV_DEFECTO`):**
  - `svn diff -c "$REV_DEFECTO" "$URL_SANDBOX_ALUMNO/trunk"` demuestra que en `r2` se cambió `umbral_critico_ms` de `1200` a `200` en `config/servicios.conf`, rompiendo la regla de umbrales.
- **Revisión válida posterior (`r3` / `$REV_CAMBIO_VALIDO`):**
  - `svn diff -c "$REV_CAMBIO_VALIDO" "$URL_SANDBOX_ALUMNO/trunk"` demuestra que en `r3` se añadió el bloque `## Escalado ante estado CRÍTICO` en `docs/reglas_umbrales.md`. Es trabajo correcto que debe conservarse intacto.

### 2. Opciones válidas de recuperación y verificación (Pasos 4, 5 y 6)
- **Opción A (preferente para practicar M3) — Integración inversa:**
  - `svn merge -c "-$REV_DEFECTO" "$URL_SANDBOX_ALUMNO/trunk" .` aplica el inverso exacto de `r2` en tu copia local (`U    config/servicios.conf`), restaurando `umbral_critico_ms=1200` sin tocar `r3`.
  - *Nota sobre `svn:mergeinfo`:* durante el `merge`, SVN puede registrar o elidir propiedades `svn:mergeinfo`. Son metadatos normales de seguimiento de integración y no deben eliminarse manualmente (se verán en detalle en la Sesión 2, Módulo 5).
- **Opción B (igualmente válida si se justifica) — Corrección hacia adelante:**
  - Editar manualmente `config/servicios.conf` para restaurar `umbral_critico_ms=1200`.
- **Verificación y publicación (`r4`):**
  - `evaluador.py` vuelve a pasar con `OK` y `AVISO` (código de salida `0`).
  - `grep -n -A2 "## Escalado ante estado CRÍTICO" docs/reglas_umbrales.md` confirma que el bloque añadido en `r3` sigue intacto.
  - `svn commit` publica la revisión `r4` con un mensaje que justifica la reparación citando `r2` y la conservación de `r3`.

### 3. Respuestas a «Comprueba tu entendimiento»
1. **¿Por qué `svn revert` local no sirve para deshacer un cambio que ya fue publicado en el repositorio?**
   Porque `svn revert` solo descarta modificaciones locales no publicadas; un commit ya registrado forma parte del historial compartido y requiere una nueva revisión que corrija el estado vigente.
2. **Después de tu reparación, ¿desaparece del historial la revisión que introdujo el error? ¿Por qué?**
   No desaparece: SVN es inmutable hacia atrás en el uso normal. La recuperación añade una nueva revisión (`r4`) que corrige el proyecto conservando la trazabilidad completa de lo ocurrido.

### 4. Si tu resultado no coincidió
- **Quedaste en `r1` tras ejecutar `svn update -r 1`:** esa operación solo sirve para consulta histórica en local. Si tu copia está limpia, ejecuta `svn update` para volver a `HEAD` (recuerda que `svn revert` no cambia la revisión base de la copia).
- **Desapareció el bloque de escalado de `docs/reglas_umbrales.md`:** reinicia limpiamente el escenario con `bash scripts/reset-lab.sh L3` y repite el paso 4 actuando únicamente sobre `r2`.

</details>
