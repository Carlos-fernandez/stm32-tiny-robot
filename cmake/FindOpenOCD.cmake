# FindOpenOCD.cmake

find_program(OPENOCD_EXECUTABLE NAMES openocd)

if(NOT OPENOCD_EXECUTABLE)
    message(FATAL_ERROR "OpenOCD not found. Please install OpenOCD and ensure it is in your PATH.")
endif()

message(STATUS "Found OpenOCD: ${OPENOCD_EXECUTABLE}")

set(OPENOCD_CONFIG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/scripts/openocd")
set(OPENOCD_INTERFACE_CONFIG "${OPENOCD_CONFIG_DIR}/interface_stlink.cfg")
set(OPENOCD_TARGET_CONFIG "${OPENOCD_CONFIG_DIR}/target_stm32g4x.cfg")

if(NOT EXISTS "${OPENOCD_INTERFACE_CONFIG}")
    message(FATAL_ERROR "OpenOCD interface configuration file not found: ${OPENOCD_INTERFACE_CONFIG}")
endif()

if(NOT EXISTS "${OPENOCD_TARGET_CONFIG}")
    message(FATAL_ERROR "OpenOCD target configuration file not found: ${OPENOCD_TARGET_CONFIG}")
endif()

message(STATUS "OpenOCD interface config: ${OPENOCD_INTERFACE_CONFIG}")
message(STATUS "OpenOCD target config: ${OPENOCD_TARGET_CONFIG}")