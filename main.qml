import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtMultimedia
import "." // Import cFurrent directory to find MetadataPopup

Rectangle {
    id: mainWindow
    color: "#262626"
    property bool isPlaying: false
    property url initialMedia: ""
    property var playlist: []
    property int currentPlaylistIndex: -1

    signal menuBarVisibilityRequest(bool show) // wrong name but whatever and it wroks

    MouseArea {
        id: mainMouseArea
        anchors.fill: parent
        enabled: !imageViewer.visible
        acceptedButtons: Qt.AllButtons
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                console.log("main.qml right clicked")
                contextMenu.popup()
            }
        }
    }

    Menu {
        id: contextMenu
        MenuItem {
            text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "Pause" : "Play"
            enabled: !isImage
            onTriggered: {
                if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                    mediaPlayer.pause()
                } else {
                    mediaPlayer.play()
                }
            }
        }
        MenuItem {
            text: "Next"
            enabled: nextButton.enabled
            onTriggered: playTrackAtIndex(currentPlaylistIndex + 1)
        }
        MenuItem {
            text: "Previous"
            enabled: prevButton.enabled
            onTriggered: playTrackAtIndex(currentPlaylistIndex - 1)
        }
        Menu {
            title: "Speed"
            enabled: !isImage
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

    // --- Central function to manage button enabled states ---
    function updateButtonStates() {
        console.log("Updating button states. Index:", currentPlaylistIndex, "Length:", playlist.length);
        prevButton.enabled = currentPlaylistIndex > 0;
        nextButton.enabled = currentPlaylistIndex < playlist.length - 1;
        console.log("prevButton.enabled:", prevButton.enabled, "nextButton.enabled:", nextButton.enabled);
    }

    // --- This is the single, central function for all track changes ---
    function playTrackAtIndex(newIndex) {
        console.log("--- ACTION: playTrackAtIndex called with index:", newIndex, "---");

        if (newIndex < 0 || newIndex >= playlist.length) {
            console.log("Invalid index. Stopping playback.");
            mediaPlayer.stop();
            updateButtonStates();
            return;
        }

        currentPlaylistIndex = newIndex;
        showMedia(playlist[currentPlaylistIndex], true); // It's from a playlist
        updateButtonStates();
    }

    // --- NEW: Central function to show media and control UI ---
    function showMedia(mediaUrlStr, isFromPlaylist) {
        var fileExtension = mediaUrlStr.split(".").pop().toLowerCase();
        var isVideoFile = (fileExtension === "mp4" || fileExtension === "mov" || fileExtension === "avi");
        var isImageFile = (fileExtension === "gif" || fileExtension === "jpeg" || fileExtension === "jpg" || fileExtension === "png" || fileExtension === "webp");

        if (isImageFile) {
            isImage = true;
            videoOutput.visible = false;
            imageDisplay.source = mediaUrlStr;
            mediaPlayer.stop();
        } else {
            isImage = false;
            imageDisplay.source = "";
            mediaPlayer.source = mediaUrlStr;
            mediaPlayer.play();
            videoOutput.visible = isVideoFile;
        }

        // Control the menu bar visibility
        if (isFromPlaylist) {
            menuBarVisibilityRequest(true); // Always show for playlists
        } else {
            menuBarVisibilityRequest(!isImageFile); // Wait WHY does it also remove the menu bar
        }
    }

    // --- NEW: Central function to load any media (file or folder) ---
    function loadMedia(mediaUrl) {
        if (!mediaUrl) return;

        var mediaUrlStr = mediaUrl.toString();
        var isFolder = backend.isDir(mediaUrlStr);

        if (isFolder) {
            playlist = backend.getFilesInDir(mediaUrlStr);
            console.log("Playlist created with", playlist.length, "files from folder.");
            if (playlist.length > 0) {
                playTrackAtIndex(0); // Start playlist
            } else {
                currentPlaylistIndex = -1;
                updateButtonStates(); // Update for empty playlist
            }
        } else {
            // Logic for single files
            playlist = [];
            currentPlaylistIndex = -1;
            showMedia(mediaUrlStr, false); // It's a single file
            updateButtonStates(); // Update for single file
        }
    }

    Component.onCompleted: {
        if (initialMedia) {
            loadMedia(initialMedia);
        }
        // Set initial button state
        updateButtonStates();
    }

    function resetImage() {
        imageDisplay.scale = 1.0;
        if (imageDisplay.sourceSize.width > 0) {
            var scaleX = imageViewer.width / imageDisplay.sourceSize.width;
            var scaleY = imageViewer.height / imageDisplay.sourceSize.height;
            imageDisplay.scale = Math.min(scaleX, scaleY);
        }
        // Center the content after resetting the scale
        imageViewer.contentX = (imageDisplay.width - imageViewer.width) / 2;
        imageViewer.contentY = (imageDisplay.height - imageViewer.height) / 2;
    }

    MediaPlayer {
        id: mediaPlayer
        videoOutput: videoOutput
        audioOutput: AudioOutput {
            volume: mediaVolumeSider.value
        }
        onPlaybackStateChanged: function(state) {
            isPlaying = state === MediaPlayer.PlayingState
            // If playback stops for any reason other than the media ending on its own
            // (e.g., an error, or because a new track is being loaded),
            // we just ensure the button states are correct for the *current* index.
            if (state === MediaPlayer.StoppedState && mediaPlayer.mediaStatus !== MediaPlayer.EndOfMedia) {
                console.log("Playback stopped (not at end). Updating buttons for index:", currentPlaylistIndex);
                updateButtonStates();
            }
        }

        onMediaStatusChanged: function(status) {
            if (status === MediaPlayer.EndOfMedia) {
                console.log("--- STATUS: EndOfMedia detected. Auto-advancing. ---");
                if (currentPlaylistIndex < playlist.length - 1) {
                    // This is the new, correct home for the auto-play logic
                    playTrackAtIndex(currentPlaylistIndex + 1);
                } else {
                    console.log("End of playlist reached. Finalizing state.");
                    updateButtonStates();
                }
            }
        }

        onErrorOccurred: { console.error("MediaPlayer Error:", error, "String:", errorString) }
        onMetaDataChanged: metadataPopup.updateMetadata(mediaPlayer.metaData)
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        visible: !isImage
    }

    property bool isImage: false
    property bool isVideo: false

    Connections {
        target: backend
        function onFileSelected(fileUrl) {
            loadMedia(fileUrl);
        }
    }

    Flickable {
        id: imageViewer
        anchors.fill: parent
        visible: isImage
        clip: true
        contentWidth: imageDisplay.width
        contentHeight: imageDisplay.height
        boundsBehavior: Flickable.StopAtBounds

        MouseArea {
            id: imageMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.OpenHandCursor

            property point lastMousePos: Qt.point(0, 0)

            onPressed: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    lastMousePos = Qt.point(mouse.x, mouse.y)
                }
            }

            onReleased: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                }
            }

            onPositionChanged: (mouse) => {
                if (mouse.buttons & Qt.LeftButton) {
                    var deltaX = mouse.x - lastMousePos.x
                    var deltaY = mouse.y - lastMousePos.y
                    imageViewer.contentX -= deltaX
                    imageViewer.contentY -= deltaY
                    lastMousePos = Qt.point(mouse.x, mouse.y)
                }
            }

            onWheel: (wheel) => {
                var newScale = imageDisplay.scale * (wheel.angleDelta.y > 0 ? 1.2 : 1 / 1.2)
                newScale = Math.max(0.1, Math.min(newScale, 10)) //

                imageDisplay.scale = newScale

                imageViewer.contentX = (imageViewer.contentX + imageMouseArea.mouseX) * (newScale / imageDisplay.scale) - mouseX
                imageViewer.contentY = (imageViewer.contentY + imageMouseArea.mouseY) * (newScale / imageDisplay.scale) - mouseY
            }

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    contextMenu.popup()
                } else if (mouse.button === Qt.MiddleButton) {
                    mainWindow.resetImage()
                }
            }
        }

        Image {
            id: imageDisplay
            source: ""
            // The image size is now its source size multiplied by the scale
            width: sourceSize.width * scale
            height: sourceSize.height * scale
            scale: 1.0 // Initial scale
            antialiasing: true
            smooth: true

            onStatusChanged: {
                if (status === Image.Ready) {
                    mainWindow.resetImage()
                }
            }
        }
    }

    MetadataPopup {
        id: metadataPopup
        anchors.centerIn: parent
    }

    Rectangle {
        id: a
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 60
        color: "#40000000"
        visible: !isImage || playlist.length > 0

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalLeft
            spacing: 20

            Button {
                id: prevButton
                text: "⏮"
                // No 'enabled' property here. It is controlled entirely by the central function.
                onClicked: {
                    console.log("--- BUTTON: Previous clicked ---");
                    console.log("Before action - Index:", currentPlaylistIndex, "Playlist length:", playlist.length);
                    playTrackAtIndex(currentPlaylistIndex - 1)
                    console.log("After action - Index:", currentPlaylistIndex);
                }
            }
            Button {
                text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "⏸" : "▶"
                onClicked: {
                    if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
                        mediaPlayer.pause()
                    } else {
                        mediaPlayer.play()
                    }
                }
            }

            Button {
                id: nextButton
                text: "⏭"
                // No 'enabled' property here. It is controlled entirely by the central function.
                onClicked: {
                    console.log("--- BUTTON: Next clicked ---");
                    console.log("Before action - Index:", currentPlaylistIndex, "Playlist length:", playlist.length);
                    playTrackAtIndex(currentPlaylistIndex + 1)
                    console.log("After action - Index:", currentPlaylistIndex);
                }
            }
            Button {
                id: sliderMenu
                text: "..."
                onClicked:  sliderMenuPopup.open()

            }

            Slider {
                id: mediaPositionSlider
                from: 0
                to: mediaPlayer.duration
                value: mediaPlayer.position
                enabled: mediaPlayer.seekable
                width: mainWindow.width * 0.3
                visible: !isImage
                onPressedChanged: {
                    if (!pressed) {
                        mediaPlayer.position = value
                    }
                }
            }

            Dialog {
                id: sliderMenuPopup
                parent: mainWindow
                width: mainWindow.width * 0.6
                height: mainWindow.height * 0.6
                title: "Video Playback"
                padding: 10
                x: (mainWindow.width - width) / 2
                y: mainWindow.height - height - a.height - 10

                palette { windowText: "white" }

                Column {
                    id: dialogColumn
                    spacing: 10
                    width: parent.width - (2 * sliderMenuPopup.padding)

                    Text {
                        text: "Volume"
                        color: sliderMenuPopup.palette.windowText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Slider {
                        id: mediaVolumeSider
                        from: 0
                        to: 3.0
                        value: mediaPlayer.playbackRate
                        enabled: !isImage
                        visible: !isImage
                        width: parent.width
                    }
                    Text {
                        text: "Speed"
                        color: sliderMenuPopup.palette.windowText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Slider {
                        id: mediaPlaybackSider
                        from: 0.1
                        to: 3.0
                        value: mediaPlayer.playbackRate
                        enabled: !isImage
                        visible: !isImage
                        width: parent.width
                        onMoved: {
                            mediaPlayer.playbackRate = value
                        }
                    }

                    Text {
                        text: "Rotation"
                        color: sliderMenuPopup.palette.windowText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Slider {
                        id: rotationSider
                        from: 0
                        to: 360
                        value: videoOutput.rotation
                        visible: !isImage
                        width: parent.width
                        onMoved: {
                            videoOutput.rotation = value
                            imageDisplay.rotation = value
                        }
                    }
                }
            }
        }
    }
}
