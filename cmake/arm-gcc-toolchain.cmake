set(ARM_GCC_VERSION "10.3-2021.10")
set(ARM_GCC_FOLDER "gcc-arm-none-eabi-${ARM_GCC_VERSION}")
set(ARM_GCC_FILENAME "${ARM_GCC_FOLDER}-x86_64-linux.tar.bz2")
set(ARM_GCC_URL "https://developer.arm.com/-/media/Files/downloads/gnu-rm/${ARM_GCC_VERSION}/${ARM_GCC_FILENAME}")
set(TOOLCHAIN_ROOT ${CMAKE_BINARY_DIR}/arm-gcc)
set(TOOLCHAIN_DIR ${TOOLCHAIN_ROOT}/${ARM_GCC_FOLDER})
set(TOOLCHAIN_BIN ${TOOLCHAIN_DIR}/bin)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(ARM_GCC_ARCHIVE ${TOOLCHAIN_ROOT}/${ARM_GCC_FILENAME})

# Download toolchain if not already present
if(NOT EXISTS ${TOOLCHAIN_BIN}/arm-none-eabi-gcc)
    message(STATUS "ARM GCC toolchain not found. Downloading...")

    file(DOWNLOAD
        ${ARM_GCC_URL}
        ${ARM_GCC_ARCHIVE}
        SHOW_PROGRESS
        STATUS download_status
        LOG download_log
    )

    list(GET download_status 0 status_code)
    if(NOT status_code EQUAL 0)
        message(FATAL_ERROR "Failed to download ARM GCC toolchain: ${download_log}")
    endif()

    # Extract it
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xjf ${ARM_GCC_ARCHIVE}
        WORKING_DIRECTORY ${TOOLCHAIN_ROOT}
        RESULT_VARIABLE extract_result
    )

    if(NOT extract_result EQUAL 0)
        message(FATAL_ERROR "Failed to extract ARM GCC toolchain archive.")
    endif()

    # Make sure it's executable
    execute_process(
        COMMAND chmod +x ${TOOLCHAIN_BIN}/arm-none-eabi-gcc
        RESULT_VARIABLE chmod_result
    )
endif()

# Final check
if(NOT EXISTS ${TOOLCHAIN_BIN}/arm-none-eabi-gcc)
    message(FATAL_ERROR "ARM GCC toolchain setup failed. Compiler not found.")
endif()

# Set compiler
set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN}/arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN}/arm-none-eabi-gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN_BIN}/arm-none-eabi-objcopy)
set(CMAKE_SIZE ${TOOLCHAIN_BIN}/arm-none-eabi-size)