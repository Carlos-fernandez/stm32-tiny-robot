find_path(STM32CUBE_G4_PATH NAMES STM32Cube_FW_G4 HINTS /path/to/STM32Cube_FW_G4_Vx.x.x /usr/local/st/STM32Cube_FW_G4) # REPLACE WITH YOUR ACTUAL PATH!

if(STM32CUBE_G4_PATH)
    set(STM32G4xx_FOUND TRUE)

    include_directories(${STM32CUBE_G4_PATH}/Drivers/CMSIS/Device/ST/STM32G4xx/Include)
    include_directories(${STM32CUBE_G4_PATH}/Drivers/STM32G4xx_HAL_Driver/Inc) # If using HAL

    find_path(STM32_LINKER_SCRIPT NAMES STM32G474xE_FLASH.ld HINTS ${STM32CUBE_G4_PATH}/Drivers/CMSIS/Device/ST/STM32G4xx/Source/Templates/gcc/linker_scripts) # ADJUST FOR YOUR DEVICE!
    find_path(STM32_STARTUP_FILE NAMES startup_stm32g474xe.s HINTS ${STM32CUBE_G4_PATH}/Drivers/CMSIS/Device/ST/STM32G4xx/Source/Templates/gcc) # ADJUST FOR YOUR DEVICE!

    set(STM32G4xx_LIBRARIES "") # Add any necessary libraries here

    set(STM32G4xx_INCLUDE_DIRS ${STM32CUBE_G4_PATH}/Drivers/CMSIS/Device/ST/STM32G4xx/Include ${STM32CUBE_G4_PATH}/Drivers/STM32G4xx_HAL_Driver/Inc) # If using HAL

    message(STATUS "STM32CUBE_G4_PATH: ${STM32CUBE_G4_PATH}") # Debugging

else()
    message(FATAL_ERROR "STM32CubeG4 firmware package not found.  Set STM32CUBE_G4_PATH.")
endif()

mark_as_advanced(STM32CUBE_G4_PATH STM32_LINKER_SCRIPT STM32_STARTUP_FILE)
