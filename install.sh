#!/bin/bash

# This script will build and install the HEllo application.

# Exit on error
set -e

# --- Dependency Checking ---
echo "Checking for required tools..."
for tool in wget chmod qmake make; do
    if ! command -v $tool &> /dev/null; then
        echo "$tool could not be found. Please install it and try again."
        exit 1
    fi
done
echo "All required tools are available."

# --- linuxdeployqt Setup ---
if ! command -v linuxdeployqt &> /dev/null; then
    echo "linuxdeployqt not found. Downloading it..."
    wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage" -O linuxdeployqt
    chmod a+x linuxdeployqt
    sudo mv linuxdeployqt /usr/local/bin/linuxdeployqt
fi

# --- Build the Application ---
echo "Building the HEllo application..."
qmake HEllo.pro
make

# --- Prepare for AppImage ---
echo "Creating AppDir structure..."
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps

# --- Copy Application Files ---
echo "Copying application files..."
cp HEllo AppDir/usr/bin/
cp sure.png AppDir/usr/share/icons/hicolor/256x256/apps/HEllo.png
cp HEllo.desktop AppDir/usr/share/applications/

# --- Run linuxdeployqt ---
echo "Bundling dependencies with linuxdeployqt..."
linuxdeployqt AppDir/usr/share/applications/HEllo.desktop -appimage

echo "Installation complete!"
echo "You can now run the HEllo application from your application menu or by running the generated AppImage."
