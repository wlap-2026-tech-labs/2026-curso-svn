#!/usr/bin/env python3
"""Comprobación mínima del caso «Monitor de servicios».

Uso:
    python3 src/evaluador.py CONFIG CASO.json [CASO.json ...]

Códigos de salida:
    0 -> todos los casos coinciden con su ``estado_esperado``
    1 -> algún caso no coincide o no se pudo evaluar
    2 -> la configuración es inválida (por ejemplo, aviso >= crítico)
"""

import configparser
import json
import sys
from pathlib import Path


def leer_configuracion(ruta):
    archivo = Path(ruta)
    try:
        contenido = archivo.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        print(f"ERROR: no se pudo leer la configuración {archivo}: {exc}", file=sys.stderr)
        sys.exit(2)

    configuracion = configparser.ConfigParser()
    try:
        configuracion.read_string(contenido)
    except configparser.Error as exc:
        print(f"ERROR: configuración inválida en {archivo}: {exc}", file=sys.stderr)
        sys.exit(2)
    return configuracion


def validar_umbrales(configuracion):
    for servicio in configuracion.sections():
        if not (
            configuracion.has_option(servicio, "umbral_aviso_ms")
            and configuracion.has_option(servicio, "umbral_critico_ms")
        ):
            continue
        try:
            aviso = configuracion.getint(servicio, "umbral_aviso_ms")
            critico = configuracion.getint(servicio, "umbral_critico_ms")
        except (ValueError, configparser.Error) as exc:
            print(f"ERROR: umbrales no válidos en [{servicio}]: {exc}", file=sys.stderr)
            sys.exit(2)
        if aviso >= critico:
            print(
                f"ERROR: [{servicio}] umbral_aviso_ms={aviso} debe ser estrictamente "
                f"menor que umbral_critico_ms={critico}",
                file=sys.stderr,
            )
            sys.exit(2)


def clasificar(latencia_ms, aviso_ms, critico_ms):
    if latencia_ms < aviso_ms:
        return "OK"
    if latencia_ms < critico_ms:
        return "AVISO"
    return "CRÍTICO"


def evaluar_caso(ruta, configuracion):
    archivo = Path(ruta)
    try:
        caso = json.loads(archivo.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        print(f"ERROR: no se pudo leer el caso {archivo}: {exc}", file=sys.stderr)
        return False

    if not isinstance(caso, dict):
        print(f"ERROR: el caso {archivo} debe ser un objeto JSON", file=sys.stderr)
        return False

    servicio = caso.get("servicio")
    esperado = caso.get("estado_esperado")
    if not isinstance(servicio, str) or not configuracion.has_section(servicio):
        print(f"ERROR: servicio desconocido {servicio!r} en {archivo}", file=sys.stderr)
        return False

    try:
        latencia_ms = int(caso["latencia_ms"])
        aviso_ms = configuracion.getint(servicio, "umbral_aviso_ms")
        critico_ms = configuracion.getint(servicio, "umbral_critico_ms")
    except (KeyError, TypeError, ValueError, configparser.Error) as exc:
        print(f"ERROR: datos inválidos en {archivo}: {exc}", file=sys.stderr)
        return False

    estado = clasificar(latencia_ms, aviso_ms, critico_ms)
    if estado == esperado:
        print(f"{archivo.name}: {estado} (esperado: {esperado}) -> OK")
        return True

    print(f"{archivo.name}: {estado} (esperado: {esperado}) -> FALLO", file=sys.stderr)
    return False


def main(argv):
    if len(argv) < 3:
        print(
            "Uso: python3 src/evaluador.py <configuracion.conf> <caso.json> [caso.json ...]",
            file=sys.stderr,
        )
        return 1

    configuracion = leer_configuracion(argv[1])
    validar_umbrales(configuracion)

    resultados = [evaluar_caso(ruta, configuracion) for ruta in argv[2:]]
    if not all(resultados):
        fallos = resultados.count(False)
        print(
            f"{fallos} de {len(resultados)} caso(s) no coinciden con el estado esperado.",
            file=sys.stderr,
        )
        return 1

    print(f"{len(resultados)} caso(s) coinciden con el estado esperado.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
