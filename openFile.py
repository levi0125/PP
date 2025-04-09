import os
import sys

# Función para obtener ruta correcta en ejecutable
def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS  # PyInstaller crea esta carpeta temporal
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)

def openFile(relative_path):
    return open(resource_path(relative_path))
