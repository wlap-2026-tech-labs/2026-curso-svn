# Laboratorios prácticos — Apache Subversion (SVN)

Repositorio de prácticas del curso de **Apache Subversion (SVN)** sobre el caso conductor **«Monitor de servicios»**.

> **Alcance actual (Sesión 1):** incluye la guía de preparación y los laboratorios **L1, L2 y L3** (operativa diaria sobre `trunk`). En la **Sesión 2** se actualizará este repositorio con los laboratorios **L4, L5 y L6** (ramas, integración/conflictos y *tags*).

---

## Arranque rápido en GitHub Codespaces

Para replicar el entorno de prácticas en tu navegador sin instalar nada en local (no necesitas hacer *fork*):

1. **Inicia sesión** en tu cuenta personal gratuita de GitHub.
2. En la página principal de este repositorio, pulsa el botón verde **`<> Code`**.
3. Selecciona la pestaña **`Codespaces`** y pulsa **`Create codespace on main`**.
4. Espera a que cargue VS Code en el navegador y abre la terminal integrada (`Ctrl + Ñ` o menú *Terminal → New Terminal*).
5. Comprueba que las herramientas están listas ejecutando:

```bash
svn --version --quiet
python3 --version
```

---

## Regla importante antes de empezar

No mezcles estas dos carpetas durante las prácticas:

- **Raíz del curso** (`/workspaces/2026-curso-svn`): repositorio Git con las guías y scripts. Desde aquí lanzas `bash scripts/reset-lab.sh <L>`. **No es una copia de trabajo SVN.**
- **Copia de trabajo SVN** (`/workspaces/2026-curso-svn/practicas-svn/<L>/monitor-servicios`): carpeta donde editas archivos y ejecutas todos los comandos `svn`.

> **Aviso:** no borres ni edites manualmente la carpeta oculta `.svn` dentro de tu copia de trabajo.

---

## Guías y laboratorios — Sesión 1

Sigue los documentos en este orden:

| Orden | Documento | Qué practicarás |
| :---: | --- | --- |
| 0 | [`PREPARACION.md`](PREPARACION.md) | Verificación del entorno, estructura del sandbox y cómo reiniciar laboratorios. |
| 1 | [`L1-preparar-copia.md`](L1-preparar-copia.md) | Explorar el repositorio (`list`), crear copia de `trunk` (`checkout`), verificar identidad (`info`, `status`, `update`) e investigar historial (`log`). |
| 2 | [`L2-mejora-y-commit.md`](L2-mejora-y-commit.md) | Aplicar cambios estructurales (`add`, `move`, `delete`), revisar `diff`, descartar ruido dirigido (`revert`), validar con `evaluador.py` y publicar un `commit` limpio. |
| 3 | [`L3-diagnostico-y-recuperacion.md`](L3-diagnostico-y-recuperacion.md) | Reproducir un fallo, aislar la revisión culpable (`log`, `diff -c`), recuperar el estado válido sin perder cambios posteriores (`merge -c -REV`) y documentar la reparación. |

---

## Cómo iniciar o reiniciar cualquier laboratorio

Cada laboratorio parte de un sandbox local independiente (`/tmp/svn-sandboxes/<L>/repo`). Desde la **raíz del curso**, ejecuta:

```bash
bash scripts/reset-lab.sh L1        # Sustituye L1 por L2 o L3 según el laboratorio
source /tmp/svn-sandboxes/L1/lab.env
```

Esto crea un repositorio limpio, carga la variable `$URL_SANDBOX_ALUMNO` en tu terminal y prepara la carpeta de trabajo en `practicas-svn/<L>/`.

---

## Actualización para la Sesión 2

Mañana se incorporarán en este mismo repositorio los laboratorios de trabajo en paralelo y entrega (**L4** ramas, **L5** *merge* y conflictos, **L6** *tags* y buenas prácticas). Para recibirlos en tu mismo Codespace solo tendrás que ejecutar `git pull` desde la raíz del curso.