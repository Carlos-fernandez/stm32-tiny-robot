cmake_minimum_required(VERSION 3.20)

# Project setup
project(STM32G491RE_Project C ASM)

# Include STM32CubeG4 download module
include(cmake/DownloadSTM32CubeG4.cmake)

# Ensure STM32CubeG4 drivers are available (downloads automatically if missing)
ensure_stm32cube_g4_drivers()

# MCU and HAL config
set(DEVICE STM32G491xx)
add_compile_definitions(
    USE_HAL_DRIVER
    ${DEVICE}
)

# Paths
set(PROJ_DIR         ${CMAKE_CURRENT_SOURCE_DIR})
set(LINKER_SCRIPT    ${PROJ_DIR}/linker/STM32G491RETx_FLASH.ld)

set(HAL_DIR          ${PROJ_DIR}/Drivers/STM32G4xx_HAL_Driver)
set(CMSIS_DEVICE_DIR ${PROJ_DIR}/Drivers/CMSIS/Device/ST/STM32G4xx)
set(CMSIS_CORE_DIR   ${PROJ_DIR}/Drivers/CMSIS)

# Sources (HAL-based blink)
set(SRCS
    ${PROJ_DIR}/src/main_hal.c
    ${CMSIS_DEVICE_DIR}/Source/Templates/system_stm32g4xx.c
    ${CMSIS_DEVICE_DIR}/Source/Templates/gcc/startup_stm32g491xx.s
    ${HAL_DIR}/Src/stm32g4xx_hal.c
    ${HAL_DIR}/Src/stm32g4xx_hal_cortex.c
    ${HAL_DIR}/Src/stm32g4xx_hal_rcc.c
    ${HAL_DIR}/Src/stm32g4xx_hal_gpio.c
    ${HAL_DIR}/Src/stm32g4xx_hal_pwr_ex.c
    ${HAL_DIR}/Src/stm32g4xx_hal_flash.c
)

add_executable(${PROJECT_NAME} ${SRCS})

target_include_directories(${PROJECT_NAME} PRIVATE
    ${PROJ_DIR}/include
    ${HAL_DIR}/Inc
    ${CMSIS_DEVICE_DIR}/Include
    ${CMSIS_CORE_DIR}/Include
)

# Compile definitions
target_compile_definitions(${PROJECT_NAME} PRIVATE
    ${DEVICE}
)

# Compiler flags
target_compile_options(${PROJECT_NAME} PRIVATE
    -mcpu=cortex-m4 
    -mthumb 
    -mfpu=fpv4-sp-d16 
    -mfloat-abi=hard
    -ffunction-sections 
    -fdata-sections
    -Wall
    $<$<CONFIG:Debug>:-Og -g3>
    $<$<CONFIG:Release>:-O2>
)

# Linker flags
target_link_options(${PROJECT_NAME} PRIVATE
    -T${LINKER_SCRIPT}
    -Wl,--gc-sections
    -Wl,-Map=${PROJECT_NAME}.map
    --specs=nosys.specs
)

# Post-build: generate HEX/BIN files and show size
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
    COMMENT "Generating HEX/BIN and showing size"
)

# Flash targets
add_custom_target(flash
    COMMAND STM32_Programmer_CLI -c port=SWD -w ${PROJECT_NAME}.hex -v -rst
    DEPENDS ${PROJECT_NAME}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Flashing via STM32CubeProgrammer"
)

add_custom_target(flash_openocd
    COMMAND openocd -f interface/stlink.cfg -f target/stm32g4x.cfg -c "program $<TARGET_FILE:${PROJECT_NAME}> verify reset exit"
    DEPENDS ${PROJECT_NAME}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Flashing via OpenOCD"
)

# Target to manually download STM32CubeG4 drivers
add_custom_target(download-drivers
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_SOURCE_DIR}/cmake/DownloadSTM32CubeG4.cmake
    COMMENT "Manually download STM32CubeG4 drivers"
)

# Help target to show available commands
add_custom_target(show-help
    COMMAND ${CMAKE_COMMAND} -E echo "Available targets:"
    COMMAND ${CMAKE_COMMAND} -E echo "  all              - Build firmware (default)"  
    COMMAND ${CMAKE_COMMAND} -E echo "  clean            - Clean build files"
    COMMAND ${CMAKE_COMMAND} -E echo "  flash            - Flash firmware via STM32CubeProgrammer"
    COMMAND ${CMAKE_COMMAND} -E echo "  flash_openocd    - Flash firmware via OpenOCD"
    COMMAND ${CMAKE_COMMAND} -E echo "  download-drivers - Download full STM32CubeG4 drivers"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Quick commands:"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build build/debug                 - Build project"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build build/debug --target flash  - Build & flash"
    COMMENT "Show available build targets and commands"
)