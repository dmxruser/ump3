#!/bin/bash

# This script will download, build, and install the HEllo application.

# Exit on any error
set -e

# --- Configuration ---
REPO_URL="https://github.com/dmxruser/ump3.git"
PROJECT_NAME="HEllo"
APP_NAME="ump3"
INSTALL_DIR="/opt/$APP_NAME"

# --- Dependency Checking ---
echo "Checking for required tools (git, qmake, make)..."
for tool in git qmake make; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool is not installed. Please install it and try again."
        exit 1
    fi
done
echo "Dependencies are satisfied."

# --- Create Temporary Build Directory ---
BUILD_DIR=$(mktemp -d)
echo "Created temporary build directory at $BUILD_DIR"

# --- Clone & Build ---
echo "Cloning the repository from $REPO_URL..."
git clone "$REPO_URL" "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Building the application..."
qmake6
make

# --- Installation ---
echo "Installing application to $INSTALL_DIR..."
echo "This step requires superuser privileges."

sudo mkdir -p "$INSTALL_DIR/bin"
sudo cp "$PROJECT_NAME" "$INSTALL_DIR/bin/$APP_NAME"

echo "Installing desktop entry and icon..."
sudo mkdir -p "/usr/share/applications/"
sudo mkdir -p "/usr/share/icons/hicolor/256x256/apps/"

# Create a desktop file with the correct paths
sudo tee "/usr/share/applications/$APP_NAME.desktop" > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=Music Player
Exec=$INSTALL_DIR/bin/$APP_NAME
Icon=/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png
Terminal=false
Type=Application
Categories=AudioVideo;Audio;
EOL

sudo cp "sure.png" "/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"

# --- Cleanup ---
echo "Cleaning up build files..."
cd /
rm -rf "$BUILD_DIR"

echo ""
echo "Installation complete!"
echo "You can now find '$APP_NAME' in your application menu."