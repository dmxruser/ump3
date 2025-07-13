import sys
import os
from PySide6.QtCore import QObject, QUrl, Slot, Signal
from PySide6.QtWidgets import QApplication, QFileDialog
from PySide6.QtQml import QQmlApplicationEngine

class Backend(QObject):
    # Signal to notify QML when a file has been selected
    fileSelected = Signal(str)

    @Slot()
    def openFileDialog(self):
        """
        Opens a native file dialog and emits the path of the selected file.
        """
        dialog = QFileDialog()
        dialog.setFileMode(QFileDialog.FileMode.ExistingFile)
        dialog.setNameFilter("Media Files (*.mp3 *.ogg *.wav *.mp4 *.mov *.avi)")
        if dialog.exec():
            file_path = dialog.selectedFiles()[0]
            # Emit the file path as a URL string for QML
            self.fileSelected.emit(QUrl.fromLocalFile(file_path).toString())

if __name__ == "__main__":
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Create an instance of our backend and expose it to QML
    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)

    # Load the QML file
    engine.load("main.qml")

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
