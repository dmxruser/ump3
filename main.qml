import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtMultimedia

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 640
    height: 480
    title: "ump3"

    property bool isPlaying: false
    property url initialMedia: "" // Property to hold media from command line

    Component.onCompleted: {
        if (initialMedia) {
            mediaPlayer.source = initialMedia
            mediaPlayer.play()
        }
    }

    MediaPlayer {
        id: mediaPlayer
        videoOutput: videoOutput
        audioOutput: AudioOutput {}

        onPlaybackStateChanged: function(state) {
            isPlaying = state === MediaPlayer.PlayingState
            console.log("Playback state changed: " + state)
        }

        onErrorOccurred: {
            console.error("MediaPlayer Error:", error, "String:", errorString)
        }

        onMediaStatusChanged: function(status) {
            console.log("MediaPlayer status changed: " + status)
            if (status === MediaPlayer.InvalidMedia) {
                console.error("Media source is invalid:", mediaPlayer.source)
            }
        }
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        visible: mediaPlayer.hasVideo
    }

    // Connect to the fileSelected signal from the Python backend
    Connections {
        target: backend
        function onFileSelected(fileUrl) {
            mediaPlayer.source = fileUrl
            mediaPlayer.play()
        }
    }

    menuBar: MenuBar {
        Menu {
            title: "File"
            MenuItem {
                text: "Open"
                // Call the Python method to open the dialog
                onTriggered: backend.openFileDialog()
            }
            MenuSeparator {}
            MenuItem {
                text: "Exit"
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: "Edit"
            Menu {
                title: "Speed"
                MenuItem {
                    text: "0.25x"
                    onTriggered: mediaPlayer.playbackRate = 0.25

                }
                MenuItem {
                    text: "0.5x"
                    onTriggered: mediaPlayer.playbackRate = 0.5

                }
                MenuItem {
                    text: "1.0x"
                    onTriggered: mediaPlayer.playbackRate = 1.0

                }
                MenuItem {
                    text: "1.25x"
                    onTriggered: mediaPlayer.playbackRate = 1.25

                }
                MenuItem {
                    text: "1.5x"
                    onTriggered: mediaPlayer.playbackRate = 1.5

                }
                MenuItem {
                    text: "1.75x"
                    onTriggered: mediaPlayer.playbackRate = 1.75

                }
                MenuItem {
                    text: "2.0x"
                    onTriggered: mediaPlayer.playbackRate = 2.0
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 60
        color: "#40000000"

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Button {
                text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "⏸" : "▶️"
                onClicked: {
                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                        mediaPlayer.pause()
                    } else {
                        mediaPlayer.play()
                    }
                }
            }

            Slider {
                id: mediaPositionSlider
                from: 0
                to: mediaPlayer.duration
                value: mediaPlayer.position
                enabled: mediaPlayer.seekable

                onPressedChanged: {
                    if (!pressed) {
                        mediaPlayer.position = value
                    }
                }
            }
        }
    }
}
