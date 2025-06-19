import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1
import Qt.labs.folderlistmodel 2.1

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Folder Picker with Validation"

    property var targets: ["local", "config", "chroot", "cache", "binary", "auto"]
    property string savedFolder: ""

    FolderDialog {
        id: folderDialog
        title: "Select a folder"
        onAccepted: {
            var selectedFolder = folderDialog.folder
            folderModel.folder = selectedFolder
        }
    }

    FolderListModel {
        id: folderModel
        folder: ""
        showDirs: true
        showFiles: false

        onCountChanged: {
            if (folderModel.folder === "") return;

            var foundMatch = false
            for (var i = 0; i < folderModel.count; ++i) {
                var entry = folderModel.get(i).fileName
                if (targets.indexOf(entry) !== -1) {
                    foundMatch = true
                    break
                }
            }

            if (foundMatch) {
                savedFolder = folderModel.folder
                console.log("✅ Folder saved:", savedFolder)
                folderDialog.close()
            } else {
                console.log("❌ Folder missing targets, closing dialog")
                folderDialog.close()
            }
        }
    }

    Button {
        text: "Choose Folder"
        onClicked: folderDialog.open()
    }
}



