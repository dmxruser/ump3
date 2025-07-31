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
echo "Checking for required tools..."

# --- Distribution-specific dependency installation ---
if ! command -v git &> /dev/null || ! command -v qmake6 &> /dev/null || ! command -v make &> /dev/null; then
    echo "One or more required tools are not installed."
    if [ -f /etc/debian_version ]; then
        echo "On Debian/Ubuntu, you can install them with:"
        echo "sudo apt-get update && sudo apt-get install -y git qt6-base-dev build-essential"
    elif [ -f /etc/fedora-release ]; then
        echo "On Fedora, you can install them with:"
        echo 'sudo dnf groupinstall -y "C Development Tools and Libraries" "Development Tools"'
        echo 'sudo dnf install -y qt6-qtbase-devel'
    elif [ -f /etc/arch-release ]; then
        echo "On Arch Linux, you can install them with:"
        echo "sudo pacman -Syu --needed base-devel git qt6-base"
    elif [ -f /etc/alpine-release ]; then
        echo "On Alpine Linux, you can install them with:"
        echo "apk add git build-base qt6-qtbase-dev"
    elif grep -q 'ID=opensuse' /etc/os-release; then
        echo "On openSUSE, you can install them with:"
        echo "sudo zypper install -t pattern devel_basis"
        echo "sudo zypper install -t pattern devel_qt6"
    else
        echo "Please install git, Qt 6 development tools (providing qmake6), and make."
    fi
    exit 1
fi

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
