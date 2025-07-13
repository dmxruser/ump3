import sys
from PySide6.QtCore import QObject, QUrl, Slot, Signal
from PySide6.QtWidgets import QApplication, QFileDialog
from PySide6.QtGui import QIcon
from PySide6.QtQml import QQmlApplicationEngine

class Backend(QObject):
    # Signal to notify QML when a file has been selected
    fileSelected = Signal(str)

    @Slot(str)
    def openFileDialog(self, mediaType):
        """
        Opens a native file dialog and emits the path of the selected file based on mediaType.
        """
        dialog = QFileDialog()
        dialog.setFileMode(QFileDialog.FileMode.ExistingFile)

        if mediaType == "audio":
            dialog.setNameFilter("Audio Files (*.mp3 *.ogg *.wav)")
        elif mediaType == "video":
            dialog.setNameFilter("Video Files (*.mp4 *.mov *.avi)")
        elif mediaType == "image":
            dialog.setNameFilter("Image Files (*.gif *.jpeg *.png *.webp)")
        else:
            dialog.setNameFilter("All Files (*.*)") # Fallback

        if dialog.exec():
            file_path = dialog.selectedFiles()[0]
            # Emit the file path as a URL string for QML
            self.fileSelected.emit(QUrl.fromLocalFile(file_path).toString())

if __name__ == "__main__":
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)

    engine.load("main.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    app_icon = QIcon("sure.png")
    app.setWindowIcon(app_icon)

    sys.exit(app.exec())
