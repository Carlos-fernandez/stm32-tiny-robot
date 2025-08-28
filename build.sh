#!/bin/bash
set -e

BUILD_DIR=build
ELF_FILE=$BUILD_DIR/STM32G491RE_Project.elf
BIN_FILE=$BUILD_DIR/STM32G491RE_Project.bin
HEX_FILE=$BUILD_DIR/STM32G491RE_Project.hex

echo "==> Configuring project..."
cmake -B $BUILD_DIR -DCMAKE_TOOLCHAIN_FILE=arm-gcc-toolchain.cmake -DCMAKE_BUILD_TYPE=Release

echo "==> Building firmware..."
cmake --build $BUILD_DIR

echo "==> Generating .bin and .hex files..."
arm-none-eabi-objcopy -O binary $ELF_FILE $BIN_FILE
arm-none-eabi-objcopy -O ihex   $ELF_FILE $HEX_FILE

echo "Build complete: $ELF_FILE, $BIN_FILE, $HEX_FILE"
