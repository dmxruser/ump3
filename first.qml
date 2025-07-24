import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtMultimedia
import "."

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 640
    height: 480
    title: "ump3"

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                console.log("first.qml right clicked")
                contextMenu.popup()
            }
        }
    }

    Menu {
        id: contextMenu
        MenuItem {
            text: "Open Media"
            onTriggered: backend.openFileDialog("all_media")
        }
        MenuItem {
            text: "Exit"
            onTriggered: Qt.quit()
        }
    }

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
            // Connect to the signal from main.qml to control the menu bar
            mainQml.menuBarVisibilityRequest.connect(function(show) {
                menuBar.visible = show;
            });

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
            text: "Open Media"
            onClicked: backend.openFileDialog("all_media")
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
                    text: "Open Media"
                    onTriggered: backend.openFileDialog("all_media")
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
            MenuItem {
                text: "Back"
                onTriggered: {
                    pageLoader.source = ""
                    initialButtons.visible = true
                    images.visible = true
                    menuBar.visible = false
                }
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