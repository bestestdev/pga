#!/bin/bash

# Local build script for PGA UF2 firmware
# Usage: ./build_local.sh [board_variant] [--force-refresh]
# board_variant options: pga2040, pga2350, pga2350-psram (default)

set -e

BOARD_VARIANT=${1:-pga2350-psram}
FORCE_REFRESH=false

# Check for force refresh flag
for arg in "$@"; do
    if [[ "$arg" == "--force-refresh" ]]; then
        FORCE_REFRESH=true
    fi
done

# Set up environment variables based on board variant
case $BOARD_VARIANT in
    "pga2040")
        export MICROPY_BOARD=pga2040
        export MICROPY_BOARD_VARIANT=""
        export BOARD_NAME=pga2040
        ;;
    "pga2350")
        export MICROPY_BOARD=pga2350
        export MICROPY_BOARD_VARIANT=""
        export BOARD_NAME=pga2350
        ;;
    "pga2350-psram")
        export MICROPY_BOARD=pga2350
        export MICROPY_BOARD_VARIANT=PSRAM
        export BOARD_NAME=pga2350-psram
        ;;
    *)
        echo "Error: Invalid board variant '$BOARD_VARIANT'"
        echo "Valid options: pga2040, pga2350, pga2350-psram"
        exit 1
        ;;
esac

# Environment variables
export MICROPYTHON_VERSION=feature/psram
export MICROPYTHON_FLAVOUR=pimoroni
export PIMORONI_PICO_VERSION=main
export TAG_OR_SHA=$(git rev-parse HEAD)
export RELEASE_FILE="$BOARD_NAME-${TAG_OR_SHA}-micropython"

# User module variables (set later to avoid affecting mpy-cross build)
USER_C_MODULES_PATH="$(pwd)/modules/default.cmake"
USER_FS_MANIFEST_PATH="$(pwd)/modules/default.txt"
USER_FS_SOURCE_PATH="$(pwd)/modules/py_littlefs"
MICROPY_BOARD_DIR_PATH="$(pwd)/$MICROPY_BOARD"
MICROPY_FROZEN_MANIFEST_PATH="$(pwd)/modules/default.py"

echo "Building $BOARD_NAME firmware..."
echo "Board: $MICROPY_BOARD"
echo "Variant: $MICROPY_BOARD_VARIANT"

# Clone pimoroni-pico if it doesn't exist or force refresh
if [ ! -d "pimoroni-pico" ] || [ "$FORCE_REFRESH" = true ]; then
    if [ "$FORCE_REFRESH" = true ] && [ -d "pimoroni-pico" ]; then
        echo "Force refresh: removing existing pimoroni-pico..."
        rm -rf pimoroni-pico
    fi
    echo "Cloning pimoroni-pico..."
    git clone https://github.com/pimoroni/pimoroni-pico.git
    cd pimoroni-pico
    git checkout $PIMORONI_PICO_VERSION
    git submodule update --init --recursive
    cd ..
else
    echo "pimoroni-pico already exists, using existing directory..."
fi

# Source the build functions
source ci/micropython.sh

# Execute build steps
if [ ! -d "micropython" ] || [ "$FORCE_REFRESH" = true ]; then
    if [ "$FORCE_REFRESH" = true ] && [ -d "micropython" ]; then
        echo "Force refresh: removing existing micropython..."
        rm -rf micropython
    fi
    echo "Cloning MicroPython..."
    micropython_clone
else
    echo "MicroPython already exists, using existing directory..."
fi

echo "Building MPY Cross..."
# Disable problematic warning for mpy-cross build
export CFLAGS_EXTRA="-Wno-gnu-folding-constant"
micropython_build_mpy_cross
unset CFLAGS_EXTRA

echo "Setting version info..."
# Set GITHUB_ENV to /dev/null for local builds to avoid redirect error
export GITHUB_ENV=/dev/null
micropython_version

echo "Configuring build..."
# Set user module environment variables for cmake
export USER_C_MODULES="$USER_C_MODULES_PATH"
export USER_FS_MANIFEST="$USER_FS_MANIFEST_PATH"
export USER_FS_SOURCE="$USER_FS_SOURCE_PATH"
export MICROPY_BOARD_DIR="$MICROPY_BOARD_DIR_PATH"
export MICROPY_FROZEN_MANIFEST="$MICROPY_FROZEN_MANIFEST_PATH"
cmake_configure

echo "Building firmware..."
cmake_build

echo ""
echo "Build complete!"
echo "UF2 file: build-$BOARD_NAME/$RELEASE_FILE.uf2"
echo ""
echo "To flash to your device, copy the UF2 file to the device when in BOOTSEL mode."