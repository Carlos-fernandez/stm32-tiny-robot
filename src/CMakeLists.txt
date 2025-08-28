cmake_minimum_required(VERSION 3.20)

project(STM32G491RE_Project C CXX ASM)

# Set the target MCU and linker script
set(MCU cortex-m4)
set(MCU_DEF STM32G491xx)
set(LD_SCRIPT ${CMAKE_SOURCE_DIR}/linker/STM32G491RETx_FLASH.ld)

# Cross compiler setup
include(cmake/arm-gcc-toolchain.cmake)

# Use clang tools on host
find_program(CLANG_FORMAT clang-format)

# Compiler flags
add_compile_options(-Wall -Wextra -Wno-unused-parameter)

# Fetch STM32 HAL/LL drivers from GitHub
include(FetchContent)
FetchContent_Declare(
  stm32g4_hal
  GIT_REPOSITORY https://github.com/STMicroelectronics/STM32CubeG4.git
  GIT_TAG v1.5.0 # You can change this to the latest tag
)
FetchContent_MakeAvailable(stm32g4_hal)

# Copy necessary files if missing
set(HAL_CONF_SRC ${stm32g4_hal_SOURCE_DIR}/Projects/NUCLEO-G491RE/Templates/Inc/stm32g4xx_hal_conf.h)
set(HAL_CONF_DEST ${PROJECT_SOURCE_DIR}/src/stm32g4xx_hal_conf.h)
if(NOT EXISTS ${HAL_CONF_DEST})
    file(COPY ${HAL_CONF_SRC} DESTINATION ${PROJECT_SOURCE_DIR}/src)
    message(STATUS "Copied stm32g4xx_hal_conf.h to src/")
endif()

set(SYSTEM_SRC ${stm32g4_hal_SOURCE_DIR}/Projects/NUCLEO-G491RE/Templates/Src/system_stm32g4xx.c)
set(SYSTEM_DEST ${PROJECT_SOURCE_DIR}/src/system_stm32g4xx.c)
if(NOT EXISTS ${SYSTEM_DEST})
    file(COPY ${SYSTEM_SRC} DESTINATION ${PROJECT_SOURCE_DIR}/src)
    message(STATUS "Copied system_stm32g4xx.c to src/")
endif()

# Copy the startup file if missing
set(STARTUP_SRC ${stm32g4_hal_SOURCE_DIR}/Drivers/CMSIS/Device/ST/STM32G4xx/Source/Templates/gcc/startup_stm32g491xx.s)
set(STARTUP_DEST ${PROJECT_SOURCE_DIR}/src/startup_stm32g491xx.s)
if(NOT EXISTS ${STARTUP_DEST})
    file(COPY ${STARTUP_SRC} DESTINATION ${PROJECT_SOURCE_DIR}/src)
    message(STATUS "Copied startup_stm32g491xx.s to src/")
endif()

# Include necessary directories
include_directories(
    ${stm32g4_hal_SOURCE_DIR}/Drivers/STM32G4xx_HAL_Driver/Inc
    ${stm32g4_hal_SOURCE_DIR}/Drivers/STM32G4xx_HAL_Driver/Inc/Legacy
    ${stm32g4_hal_SOURCE_DIR}/Drivers/CMSIS/Device/ST/STM32G4xx/Include
    ${stm32g4_hal_SOURCE_DIR}/Drivers/CMSIS/Include
    src
)

# Collect source files
file(GLOB_RECURSE SOURCES
    src/*.c
    ${stm32g4_hal_SOURCE_DIR}/Drivers/STM32G4xx_HAL_Driver/Src/*.c
    src/startup_stm32g491xx.s  # Add the startup file explicitly
)

# Create the executable
add_executable(${PROJECT_NAME}.elf ${SOURCES})

# Set compiler definitions and flags
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE
    STM32G491xx
    USE_HAL_DRIVER
)

target_compile_options(${PROJECT_NAME}.elf PRIVATE
    -mcpu=${MCU}
    -mthumb
    -O2
    -Wall
    -ffunction-sections
    -fdata-sections
)

# Linker flags
target_link_options(${PROJECT_NAME}.elf PRIVATE
    -T${LD_SCRIPT}
    -mcpu=${MCU}
    -mthumb
    -Wl,--gc-sections
)

# Generate .bin and .hex files after the build
add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMENT "Generating .bin and .hex files..."
)
