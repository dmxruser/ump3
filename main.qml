import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Dialogs 6.8
import QtMultimedia 6.8
import "." // Import current directory to find MetadataPopup

Rectangle {
    id: mainWindow
    color: "#262626"
    property bool isPlaying: false
    property url initialMedia: "" // Property to hold media from command line
    property var playlist: []
    property int currentPlaylistIndex: -1

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

        // If the requested index is out of bounds, just stop and update buttons.
        if (newIndex < 0 || newIndex >= playlist.length) {
            console.log("Invalid index. Stopping playback.");
            mediaPlayer.stop();
            updateButtonStates(); // Call the central update function
            return;
        }

        // Set the new index and play the track
        currentPlaylistIndex = newIndex;
        mediaPlayer.source = playlist[currentPlaylistIndex];
        mediaPlayer.play();

        // Update button states every time a track is successfully changed.
        updateButtonStates();
    }

    Component.onCompleted: {
        if (initialMedia) {
            mediaPlayer.source = initialMedia
            mediaPlayer.play()
        }
        // Set initial button state
        updateButtonStates();
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

    Connections {
        target: backend
        function onFileSelected(fileUrl) {
            var isFolder = backend.isDir(fileUrl)
            if (isFolder) {
                playlist = backend.getFilesInDir(fileUrl);
                console.log("Playlist created with", playlist.length, "files.");
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
                var fileExtension = fileUrl.split(".").pop().toLowerCase();
                var isVideoFile = (fileExtension === "mp4" || fileExtension === "mov" || fileExtension === "avi");
                var isImageFile = (fileExtension === "gif" || fileExtension === "jpeg" || fileExtension === "jpg" || fileExtension === "png" || fileExtension === "webp");
                if (isImageFile) {
                    isImage = true;
                    videoOutput.visible = false;
                    imageDisplay.source = fileUrl;
                    mediaPlayer.stop();
                } else {
                    isImage = false;
                    imageDisplay.source = "";
                    mediaPlayer.source = fileUrl;
                    mediaPlayer.play();
                    videoOutput.visible = isVideoFile;
                }
                updateButtonStates(); // Update for single file
            }
        }
    }

    Item {
        id: imageViewer
        anchors.fill: parent
        visible: isImage
        clip: true

        Image {
            id: imageDisplay
            source: ""
            // x and y are now set imperatively, not with bindings.

            onStatusChanged: {
                if (status === Image.Ready) {
                    // Reset scale
                    scale = 1.0;

                    // Fit to window
                    var scaleX = parent.width / sourceSize.width;
                    var scaleY = parent.height / sourceSize.height;
                    scale = Math.min(scaleX, scaleY);

                    // Manually center the image now that scale is set
                    x = (parent.width - width) / 2;
                    y = (parent.height - height) / 2;
                }
            }
        }

        PinchHandler {
            id: pinchHandler
            target: imageDisplay
        }

        MouseArea {
            anchors.fill: parent
            drag.target: imageDisplay
            drag.filterChildren: true
            acceptedButtons: Qt.LeftButton

            onWheel: (wheel) => {
                var factor = wheel.angleDelta.y > 0 ? 1.2 : 1 / 1.2;
                var newScale = imageDisplay.scale * factor;

                // Clamp scale
                newScale = Math.max(0.1, Math.min(newScale, 10));

                if (Math.abs(newScale - imageDisplay.scale) < 0.001) return;

                // Get mouse position relative to the image
                var mouseOnImage = mapToItem(imageDisplay, wheel.x, wheel.y);

                imageDisplay.scale = newScale;

                // Reposition the image to keep the point under the mouse stationary
                imageDisplay.x -= (mouseOnImage.x * factor - mouseOnImage.x);
                imageDisplay.y -= (mouseOnImage.y * factor - mouseOnImage.y);
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
        visible: !isImage

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
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
                onPressedChanged: {
                    if (!pressed) {
                        mediaPlayer.position = value
                    }
                }
            }
        }
    }
}
