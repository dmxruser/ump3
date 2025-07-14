import sys
import os
from PySide6.QtCore import QObject, QUrl, Slot, Signal
from PySide6.QtWidgets import QApplication, QFileDialog
from PySide6.QtGui import QIcon
from PySide6.QtQml import QQmlApplicationEngine

class Backend(QObject):
    fileSelected = Signal(str)

    @Slot(str)
    def openFileDialog(self, mediaType):
        dialog = QFileDialog()
        dialog.setFileMode(QFileDialog.FileMode.ExistingFile)

        if mediaType == "audio":
            dialog.setNameFilter("Audio Files (*.mp3 *.ogg *.wav)")
        elif mediaType == "video":
            dialog.setNameFilter("Video Files (*.mp4 *.mov *.avi)")
        elif mediaType == "image":
            dialog.setNameFilter("Image Files (*.gif *.jpeg *.png *.webp)")
        else:
            dialog.setNameFilter("All Files (*.*)")

        if dialog.exec():
            file_path = dialog.selectedFiles()[0]
            url = QUrl.fromLocalFile(file_path)
            self.fileSelected.emit(url.toString())

if __name__ == "__main__":
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)

    if hasattr(sys, '_MEIPASS'):
        # Running in a PyInstaller bundle
        qml_file = os.path.join(sys._MEIPASS, "main.qml")
    else:
        # Running in a normal Python environment
        qml_file = "main.qml"
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)

    if hasattr(sys, '_MEIPASS'):
        # Running in a PyInstaller bundle
        app.setWindowIcon(QIcon(os.path.join(sys._MEIPASS, "sure.png")))
    else:
        # Running in a normal Python environment
        app.setWindowIcon(QIcon("sure.png"))
    sys.exit(app.exec())
