import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Dialogs 6.8
import QtMultimedia 6.8
import "." // Import current directory to find MetadataPopup

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

        onMetaDataChanged: {
            console.log("Metadata changed:", mediaPlayer.metaData.keys());
            metadataPopup.updateMetadata(mediaPlayer.metaData);
        }
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        visible: !isImage
    }

    property bool isImage: false // New property to track if current media is an image

    // Connect to the fileSelected signal from the Python backend
    Connections {
        target: backend
        function onFileSelected(fileUrl) {
            var fileExtension = fileUrl.split(".").pop().toLowerCase();
            var isVideoFile = (fileExtension === "mp4" || fileExtension === "mov" || fileExtension === "avi");
            var isImageFile = (fileExtension === "gif" || fileExtension === "jpeg" || fileExtension === "jpg" || fileExtension === "png" || fileExtension === "webp");

            if (isImageFile) {
                isImage = true;
                videoOutput.visible = false; // Hide video output for images
                imageDisplay.source = fileUrl;
                mediaPlayer.stop(); // Stop any playing audio/video
            } else {
                isImage = false;
                imageDisplay.source = ""; // Clear image source
                mediaPlayer.source = fileUrl;
                mediaPlayer.play();
                videoOutput.visible = isVideoFile; // Show video output only for video files
            }
        }
    }

    Image {
        id: imageDisplay
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        visible: isImage // Only visible if an image is loaded
        source: "" // Will be set by onFileSelected
    }

    menuBar: MenuBar {
        Menu {
            title: "File"
            Menu {
                title: "Open"
                MenuItem {
                    text: "Open Audio"
                    onTriggered: backend.openFileDialog("audio")
                }
                MenuItem {
                    text: "Open Video"
                    onTriggered: backend.openFileDialog("video")
                }
                MenuItem {
                    text: "Open Image"
                    onTriggered: backend.openFileDialog("image")
                }
            }
            MenuItem {
                text: "Metadata"
                onTriggered: metadataPopup.open()
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

    MetadataPopup {
        id: metadataPopup
        anchors.centerIn: parent
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 60
        color: "#40000000"
        visible: !isImage // Hide when an image is selected

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
