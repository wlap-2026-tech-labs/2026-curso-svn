# Reglas de umbrales

Clasificación de latencia (convención del proyecto):
- OK: `latencia_ms < umbral_aviso_ms`
- AVISO: `umbral_aviso_ms <= latencia_ms < umbral_critico_ms`
- CRÍTICO: `latencia_ms >= umbral_critico_ms`

Regla obligatoria de configuración:
- `umbral_aviso_ms` debe ser siempre estrictamente menor que `umbral_critico_ms`.
