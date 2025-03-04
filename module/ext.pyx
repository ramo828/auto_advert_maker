import sys
import os


def get_resource_path(relative_path):
    """PyInstaller ile çalışırken doğru dosya yolunu bulur."""
    try:
        base_path = sys._MEIPASS  # PyInstaller ile paketlenmiş dizin
        print(base_path)
    except Exception:
        base_path = os.path.abspath(".")  # Normal çalışma dizini
        print("Xeta oldu, pyinstaller icine baxa bilmedim")
    return os.path.join(base_path, relative_path)