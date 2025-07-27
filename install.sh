#!/bin/bash

# Exit on error
set -e

# Build the project
qmake6
make

# Install the project
sudo make install

# Install the desktop file
sudo cp HEllo.desktop /usr/share/applications/

# Install the icon
sudo mkdir -p /usr/share/icons/hicolor/scalable/apps/
sudo cp sure.png /usr/share/icons/hicolor/scalable/apps/HEllo.png

echo "HEllo installed successfully."
echo "You can find it in your application menu."