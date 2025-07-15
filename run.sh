#!/bin/bash
# This script will build and run the HEllo application.

# Exit on error
set -e

# Find the qmake executable
QMAKE=$(find /usr/lib /opt -name "qmake" | head -n 1)

if [ -z "$QMAKE" ]; then
    echo "qmake not found. Please install Qt development tools."
    exit 1
fi

# Build the project
echo "Building the project..."
$QMAKE
make

# Run the application
echo "Running the application..."
./HEllo
