import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Dialogs 6.5
import QtMultimedia 6.5

ApplicationWindow {
    visible: true
    width: 350
    height: 250
    title: "ump3"

    // state variable for play/pause
    property bool isPlaying: false

    MediaPlayer {
        id: audioPlayer
        audioOutput: AudioOutput {}
    }

    FileDialog {
        id: fileDialog
        title: "Select an MP3 file"
        nameFilters: ["Audio Files (*.mp3 *.ogg *.wav)"]
        onAccepted: {
            if (selectedFile !== "") {
                console.log("Loaded MP3:", selectedFile)
                audioPlayer.source = selectedFile
                isPlaying = false  // reset state
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 16

        Button {
            text: "Choose MP3 File"
            onClicked: fileDialog.open()
        }

        Button {
            text: isPlaying ? "⏸ Pause" : "▶️ Play"
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
            source: isPlaying ? "playing.png" : "paused.png"
            width: 48
            height: 48
            fillMode: Image.PreserveAspectFit
        }
    }
}

