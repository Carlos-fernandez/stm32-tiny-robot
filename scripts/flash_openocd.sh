#!/bin/bash

# OpenOCD configuration for STM32G491RE
OPENOCD_CONFIG="scripts/openocd/interface_stlink.cfg"
TARGET_CONFIG="scripts/openocd/target_stm32g4x.cfg"

# Check if OpenOCD is installed
if ! command -v openocd &> /dev/null
then
    echo "OpenOCD could not be found. Please install it first."
    exit 1
fi

# Flash the firmware
openocd -f $OPENOCD_CONFIG -f $TARGET_CONFIG -c "program build/your_firmware.elf verify reset exit"