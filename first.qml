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

    // Property to hold the loaded main.qml item
    property var mainQml: null
    // Property to hold a pending file URL if main.qml is not ready
    property url pendingFileUrl: ""

    Loader {
        id: pageLoader
        anchors.fill: parent
        onLoaded: {
            // Store the loaded item and process any pending URL
            mainQml = item;
            if (pendingFileUrl) {
                mainQml.loadMedia(pendingFileUrl);
                pendingFileUrl = ""; // Clear it after use
            }
        }
    }

    Component.onCompleted: {
        // Check for media passed from command line
        if (typeof initialMedia !== 'undefined' && initialMedia.toString() !== "") {
            initialButtons.visible = false;
            images.visible = false;
            menuBar.visible = true;
            pendingFileUrl = initialMedia; // Set pending URL
            pageLoader.source = "main.qml"; // Load main.qml
        }
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
        function onFileSelected(fileUrl) {
            if (mainQml) {
                // If main.qml is already loaded, call it directly
                mainQml.loadMedia(fileUrl);
            } else {
                // If not loaded, hide buttons, set pending URL, and load main.qml
                initialButtons.visible = false;
                images.visible = false;
                menuBar.visible = true;
                pendingFileUrl = fileUrl;
                pageLoader.source = "main.qml";
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
