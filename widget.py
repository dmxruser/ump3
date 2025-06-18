import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

if __name__ == "__main__":
    app = QApplication([])
    engine = QQmlApplicationEngine()

    # Load your QML file here
    engine.load(QUrl("main.qml"))

    # Check if QML root object loaded successfully
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
