import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1
import Qt.labs.folderlistmodel 2.1
import QtMultimedia 6.5

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "ump3"

    MediaPlayer {
        id: audioPlayer
        audioOutput: AudioOutput {}
    }

    FileDialog {
        id: fileDialog
        title: "Select an MP3 file"
        nameFilters: ["MP3 files (*.mp3)"]
        onAccepted: {
            if (fileDialog.files.length > 0) {
                console.log("Accepted file URL:", fileDialog.files[0])
                audioPlayer.source = fileDialog.files[0]
            } else {
                console.warn("No file selected 💀")
            }
        }
    }



    FolderListModel {
        id: folderModel
        folder: ""
        showDirs: true
        showFiles: false
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Button {
            text: "Choose MP3 File"
            onClicked: fileDialog.open()
        }

        Button {
            text: "Play MP3 File"
            onClicked: {
                audioPlayer.play()
            }
        }

        Image {
            source: "sure.png"
            width: 64
            height: 64
            fillMode: Image.PreserveAspectFit
        }
    }
}
