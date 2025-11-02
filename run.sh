#!/bin/bash
# This script will build and run the HEllo application using Qt 6.

# Exit on error
set -e

# Find the qmake6 executable
QMAKE=$(find /usr/lib /opt -name "qmake6" | head -n 1)

if [ -z "$QMAKE" ]; then
    echo "qmake6 not found. Please ensure Qt 6 development tools are installed."
    exit 1
fi

# Clean the project to remove any old Qt 5 build artifacts
echo "Cleaning the project..."
make clean || true # Don't fail if clean fails (e.g., first run)

# Build the project using qmake6
echo "Building the project with $QMAKE..."
$QMAKE

make

# Run the application
echo "Running the application..."
./HEllo
