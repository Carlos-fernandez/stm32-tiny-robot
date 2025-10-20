set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_LINKER arm-none-eabi-ld)

set(CMAKE_C_FLAGS "-mcpu=cortex-m4 -mthumb -mfloat-abi=soft -g -O2")
set(CMAKE_CXX_FLAGS "-mcpu=cortex-m4 -mthumb -mfloat-abi=soft -g -O2")
set(CMAKE_EXE_LINKER_FLAGS "-T${CMAKE_CURRENT_SOURCE_DIR}/../linker/STM32G491RETx_FLASH.ld -Wl,--gc-sections")

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/../include
    ${CMAKE_CURRENT_SOURCE_DIR}/../Drivers/CMSIS/Device/ST/STM32G4xx/Include
    ${CMAKE_CURRENT_SOURCE_DIR}/../Drivers/STM32G4xx_HAL_Driver/Inc
)

set(FLASH_TOOL openocd)
set(FLASH_CONFIG ${CMAKE_CURRENT_SOURCE_DIR}/flash.cmake)

set(DEBUG_TOOL gdb)
set(DEBUG_CONFIG ${CMAKE_CURRENT_SOURCE_DIR}/debug.gdb)