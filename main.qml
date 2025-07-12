import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Dialogs 6.5
import QtMultimedia 6.5

ApplicationWindow {
    visible: true
    width: 350
    height: 250
    title: "ump3"

    property bool isPlaying: false

    MediaPlayer {
        id: audioPlayer
        audioOutput: AudioOutput {}
        onPositionChanged: {
            if (!audioPositionSlider.pressed) {
                audioPositionSlider.value = position;
            }
        }
        onDurationChanged: {
            audioPositionSlider.to = duration;
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select an MP3 file"
        nameFilters: ["Audio Files (*.mp3 *.ogg *.wav)"]
        onAccepted: {
            if (selectedFile !== "") {
                console.log("Loaded MP3:", selectedFile)
                audioPlayer.source = selectedFile
                isPlaying = false
            }
        }
    }
    menuBar: MenuBar {
        Menu {
            title: "File"
            MenuItem {
                text: "Open"
                onTriggered: fileDialog.open()

            }
            MenuSeparator {}
            MenuItem {
                text: "Exit"
                onTriggered: Qt.quit()
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 16

        Slider {
            id: audioPositionSlider
            from: 0
            to: audioPlayer.duration

            onMoved: {
                audioPlayer.position = value;
            }
        }
        Button {
            text: isPlaying ? "⏸" : "▶️"
            enabled: audioPlayer.source !== ""
            onClicked: {
                isPlaying = !isPlaying
                if (isPlaying) {
                    audioPlayer.play()
                } else {
                    audioPlayer.pause()
                }
            }
        }


        Image {
            source: isPlaying ? "sure.png" : "sure.png"
            width: 48
            height: 48
            fillMode: Image.PreserveAspectFit
        }
    }
}
