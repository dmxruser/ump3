import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Popup {
    id: metadataPopup
    width: 400
    height: 300
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                console.log("MetadataPopup right clicked")
                contextMenu.popup()
            }
        }
    }

    Menu {
        id: contextMenu
        MenuItem {
            text: "Close"
            onTriggered: metadataPopup.close()
        }
    }

    property var mediaMetadata: null // To hold the MediaMetadata object

    ListModel {
        id: metadataModel
    }

    function updateMetadata(metadata) {
        console.log("updateMetadata called with metadata:", metadata);
        metadataModel.clear();
        if (metadata) {
            mediaMetadata = metadata; // Store the metadata object
            for (var key of metadata.keys()) {
                var value = metadata.stringValue(key);
                console.log("Metadata key:", metadata.metaDataKeyToString(key), "value:", value);
                if (value) {
                    metadataModel.append({
                        name: metadata.metaDataKeyToString(key), // Converts enum key to string
                        value: value
                    });
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Text {
            text: "Media Metadata"
            font.bold: true
            font.pointSize: 16
            Layout.alignment: Qt.AlignHCenter
            color: mainWindow.palette.text
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "lightgray"
            radius: 1
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: metadataModel
            clip: true

            delegate: RowLayout {
                width: parent.width
                spacing: 10

                Text {
                    text: model.name + ":"
                    font.bold: true
                    Layout.preferredWidth: parent.width * 0.3
                    elide: Text.ElideRight
                    color: mainWindow.palette.text
                }
                Text {
                    text: model.value
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAnywhere
                    color: mainWindow.palette.text
                }
            }
        }

        Button {
            text: "Close"
            Layout.alignment: Qt.AlignHCenter
            onClicked: metadataPopup.close()
        }
    }

    // Optional: Display cover art if available
    Image {
        id: coverArtImage
        source: mediaMetadata && mediaMetadata.coverArtUrlSmall ? mediaMetadata.coverArtUrlSmall : ""
        anchors.top: parent.top
        anchors.right: parent.right
        width: 80
        height: 80
        fillMode: Image.PreserveAspectFit
        visible: source !== ""
        x: parent.width - width - 10
        y: 10
    }
    MouseArea{
        anchors.fill: parent
        onClicked: {
            console.log("MetadataPopup clicked")
        }
    }
}
