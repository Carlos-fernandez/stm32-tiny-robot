#!/bin/bash
set -e

BUILD_DIR=build
ELF_FILE=$BUILD_DIR/blinky.elf
BIN_FILE=$BUILD_DIR/blinky.bin
HEX_FILE=$BUILD_DIR/blinky.hex

echo "==> Configuring project..."
cmake -B $BUILD_DIR -DCMAKE_TOOLCHAIN_FILE=Toolchain.cmake -DCMAKE_BUILD_TYPE=Release

echo "==> Building firmware..."
cmake --build $BUILD_DIR

echo "==> Generating .bin and .hex files..."
arm-none-eabi-objcopy -O binary $ELF_FILE $BIN_FILE
arm-none-eabi-objcopy -O ihex   $ELF_FILE $HEX_FILE

echo "Build complete: $ELF_FILE, $BIN_FILE, $HEX_FILE"
