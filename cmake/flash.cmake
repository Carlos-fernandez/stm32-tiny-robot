set(OPENOCD_CONFIG "${CMAKE_CURRENT_SOURCE_DIR}/scripts/openocd/interface_stlink.cfg")
set(OPENOCD_TARGET "${CMAKE_CURRENT_SOURCE_DIR}/scripts/openocd/target_stm32g4x.cfg")

function(flash)
    message(STATUS "Flashing the firmware to STM32G491RE...")

    if(NOT EXISTS "${OPENOCD_CONFIG}" OR NOT EXISTS "${OPENOCD_TARGET}")
        message(FATAL_ERROR "OpenOCD configuration files not found.")
    endif()

    execute_process(
        COMMAND openocd -f ${OPENOCD_CONFIG} -f ${OPENOCD_TARGET} -c "program ${CMAKE_BINARY_DIR}/your_firmware.elf verify reset exit"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        RESULT_VARIABLE result
    )

    if(result)
        message(FATAL_ERROR "Flashing failed with error code: ${result}")
    else()
        message(STATUS "Flashing completed successfully.")
    endif()
endfunction()