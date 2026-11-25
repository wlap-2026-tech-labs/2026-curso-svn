# Monitor de servicios

Utilidad interna para evaluar el estado de respuesta de los servicios críticos
según los umbrales definidos en `config/servicios.conf`.

## Comprobación rápida
python3 src/evaluador.py config/servicios.conf examples/caso_normal.json
