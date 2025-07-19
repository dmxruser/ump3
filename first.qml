import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Dialogs 6.8
import QtMultimedia 6.8
import "."

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 640
    height: 480
    title: "ump3"

    Loader {
        id: pageLoader
        anchors.fill: parent
    }
    Column {
        id: images
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        Image {
            source: "sure.png"
            width: 100
            height: 100
        }
    }
    Row {
        id: initialButtons
        anchors.top: images.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5
        Button {
            text: "Open Audio"
            onClicked: backend.openFileDialog("audio")
        }
        Button {
            text: "Open Video"
            onClicked: backend.openFileDialog("video")
        }
        Button {
            text: "Open Image"
            onClicked: backend.openFileDialog("image")
        }
        Button {
            text: "Open Folder"
            onClicked: backend.openFileDialog("folder")
        }
    }

    Connections {
        target: backend
        function onFileSelectionCompleted(success) {
            if (success) {
                pageLoader.source = "main.qml"
                menuBar.visible = true
                initialButtons.visible = false
            }
        }
    }

    menuBar: MenuBar {
        id: menuBar
        visible: false
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
                MenuItem {
                    text: "Open Folder/Playlist"
                    onTriggered: backend.openFileDialog("folder")

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
            Menu {
                title: "Rotate"
                MenuItem {
                    text: "Rotate Clockwise"
                    onTriggered: {
                        imageDisplay.rotation += 90
                        videoOutput.rotation += 90
                    }
                }
                MenuItem {
                    text: "Rotate Anti-Clockwise"
                    onTriggered: {
                        imageDisplay.rotation -= 90
                        videoOutput.rotation -= 90
                    }
                }
            }
        }
    }
}
