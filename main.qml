import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtMultimedia
import "." // Import current directory to find MetadataPopup

Rectangle {
    id: mainWindow
    color: "#262626"
    property bool isPlaying: false
    property url initialMedia: "" // Property to hold media from command line
    property var playlist: []
    property int currentPlaylistIndex: -1

    signal menuBarVisibilityRequest(bool show)

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
            menuBarVisibilityRequest(!isImageFile); // Show for video/audio, hide for single image
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
        audioOutput: AudioOutput {}

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
                    updateButtonStates(); // Final update for the last track
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

        // This MouseArea handles panning, zooming, and context menus.
        MouseArea {
            id: imageMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            cursorShape: Qt.OpenHandCursor

            property point lastMousePos: Qt.point(0, 0)

            onPressed: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    lastMousePos = Qt.point(mouse.x, mouse.y)
                    cursorShape = Qt.ClosedHandCursor
                }
            }

            onReleased: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    cursorShape = Qt.OpenHandCursor
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
                var oldScale = imageDisplay.scale
                var newScale = oldScale * (wheel.angleDelta.y > 0 ? 1.2 : 1 / 1.2)
                newScale = Math.max(0.1, Math.min(newScale, 10)) // Clamp scale

                if (Math.abs(newScale - oldScale) < 0.001) return;

                imageDisplay.scale = newScale

                // Adjust content position to zoom towards the mouse cursor
                var mouseX = imageMouseArea.mouseX
                var mouseY = imageMouseArea.mouseY
                imageViewer.contentX = (imageViewer.contentX + mouseX) * (newScale / oldScale) - mouseX
                imageViewer.contentY = (imageViewer.contentY + mouseY) * (newScale / oldScale) - mouseY
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

            Slider {
                id: mediaPositionSlider
                from: 0
                to: mediaPlayer.duration
                value: mediaPlayer.position
                enabled: mediaPlayer.seekable
                width: mainWindow.width * 0.5
                visible: !isImage
                onPressedChanged: {
                    if (!pressed) {
                        mediaPlayer.position = value
                    }
                }
            }
        }
    }
}
