# STM32CubeG4 Driver Download Module
# This module automatically downloads and extracts STM32CubeG4 HAL drivers
# when they are not present in the project.

cmake_minimum_required(VERSION 3.20)

# Function to create minimal HAL drivers for immediate building
function(create_minimal_hal_drivers TARGET_DIR)
    message(STATUS "Creating minimal HAL drivers for immediate building...")
    
    # Create directory structure
    file(MAKE_DIRECTORY "${TARGET_DIR}/Drivers/STM32G4xx_HAL_Driver/Inc")
    file(MAKE_DIRECTORY "${TARGET_DIR}/Drivers/STM32G4xx_HAL_Driver/Src") 
    file(MAKE_DIRECTORY "${TARGET_DIR}/Drivers/CMSIS/Device/ST/STM32G4xx/Include")
    file(MAKE_DIRECTORY "${TARGET_DIR}/Drivers/CMSIS/Device/ST/STM32G4xx/Source/Templates/gcc")
    file(MAKE_DIRECTORY "${TARGET_DIR}/Drivers/CMSIS/Include")
    
    # Create stm32g4xx_hal.h - minimal version
    file(WRITE "${TARGET_DIR}/Drivers/STM32G4xx_HAL_Driver/Inc/stm32g4xx_hal.h"
"#ifndef __STM32G4xx_HAL_H
#define __STM32G4xx_HAL_H
#include \"stm32g4xx.h\"
typedef enum { HAL_OK = 0x00U, HAL_ERROR = 0x01U } HAL_StatusTypeDef;
typedef struct { uint32_t Pin; uint32_t Mode; uint32_t Pull; uint32_t Speed; } GPIO_InitTypeDef;
#define GPIO_MODE_OUTPUT_PP 0x1U
#define GPIO_NOPULL 0x0U
#define GPIO_SPEED_FREQ_LOW 0x0U
#define GPIO_PIN_5 0x20U
#define __HAL_RCC_GPIOA_CLK_ENABLE() do { } while(0)
HAL_StatusTypeDef HAL_Init(void);
HAL_StatusTypeDef HAL_GPIO_Init(void* GPIOx, GPIO_InitTypeDef* GPIO_Init);
void HAL_GPIO_TogglePin(void* GPIOx, uint16_t GPIO_Pin);
typedef struct { uint32_t OscillatorType; uint32_t HSIState; uint32_t HSICalibrationValue; struct { uint32_t PLLState; } PLL; } RCC_OscInitTypeDef;
typedef struct { uint32_t ClockType; uint32_t SYSCLKSource; uint32_t AHBCLKDivider; uint32_t APB1CLKDivider; uint32_t APB2CLKDivider; } RCC_ClkInitTypeDef;
#define RCC_OSCILLATORTYPE_HSI 0x1U
#define RCC_HSI_ON 0x1U
#define RCC_HSICALIBRATION_DEFAULT 16U
#define RCC_PLL_NONE 0x0U
#define RCC_CLOCKTYPE_HCLK 0x2U
#define RCC_CLOCKTYPE_SYSCLK 0x1U
#define RCC_CLOCKTYPE_PCLK1 0x4U
#define RCC_CLOCKTYPE_PCLK2 0x8U
#define RCC_SYSCLKSOURCE_HSI 0x0U
#define RCC_SYSCLK_DIV1 0x0U
#define RCC_HCLK_DIV1 0x0U
#define FLASH_LATENCY_0 0x0U
HAL_StatusTypeDef HAL_RCC_OscConfig(RCC_OscInitTypeDef* RCC_OscInitStruct);
HAL_StatusTypeDef HAL_RCC_ClockConfig(RCC_ClkInitTypeDef* RCC_ClkInitStruct, uint32_t FLatency);
#endif
")
    
    # Create stm32g4xx.h
    file(WRITE "${TARGET_DIR}/Drivers/CMSIS/Device/ST/STM32G4xx/Include/stm32g4xx.h"
"#ifndef __STM32G4xx_H
#define __STM32G4xx_H
#if defined(STM32G491xx)
#include \"stm32g491xx.h\"
#endif
#include \"core_cm4.h\"
#endif
")
    
    # Create stm32g491xx.h
    file(WRITE "${TARGET_DIR}/Drivers/CMSIS/Device/ST/STM32G4xx/Include/stm32g491xx.h"
"#ifndef __STM32G491xx_H
#define __STM32G491xx_H
#include <stdint.h>
#define FLASH_BASE 0x08000000UL
#define SRAM_BASE 0x20000000UL
#define GPIOA_BASE 0x48000000UL
#define GPIOA ((void*)GPIOA_BASE)
#endif
")
    
    # Create core_cm4.h  
    file(WRITE "${TARGET_DIR}/Drivers/CMSIS/Include/core_cm4.h"
"#ifndef __CORE_CM4_H_GENERIC
#define __CORE_CM4_H_GENERIC
#include <stdint.h>
#endif
")
    
    # Create minimal HAL source files
    file(WRITE "${TARGET_DIR}/Drivers/STM32G4xx_HAL_Driver/Src/stm32g4xx_hal.c"
"#include \"stm32g4xx_hal.h\"
HAL_StatusTypeDef HAL_Init(void) { return HAL_OK; }
HAL_StatusTypeDef HAL_GPIO_Init(void* GPIOx, GPIO_InitTypeDef* GPIO_Init) { (void)GPIOx; (void)GPIO_Init; return HAL_OK; }
void HAL_GPIO_TogglePin(void* GPIOx, uint16_t GPIO_Pin) { (void)GPIOx; (void)GPIO_Pin; }
HAL_StatusTypeDef HAL_RCC_OscConfig(RCC_OscInitTypeDef* RCC_OscInitStruct) { (void)RCC_OscInitStruct; return HAL_OK; }
HAL_StatusTypeDef HAL_RCC_ClockConfig(RCC_ClkInitTypeDef* RCC_ClkInitStruct, uint32_t FLatency) { (void)RCC_ClkInitStruct; (void)FLatency; return HAL_OK; }
")
    
    file(WRITE "${TARGET_DIR}/Drivers/STM32G4xx_HAL_Driver/Src/stm32g4xx_hal_gpio.c" "#include \"stm32g4xx_hal.h\"")
    file(WRITE "${TARGET_DIR}/Drivers/STM32G4xx_HAL_Driver/Src/stm32g4xx_hal_rcc.c" "#include \"stm32g4xx_hal.h\"")
    file(WRITE "${TARGET_DIR}/Drivers/STM32G4xx_HAL_Driver/Src/stm32g4xx_hal_cortex.c" "#include \"stm32g4xx_hal.h\"")
    
    # Create startup file
    file(WRITE "${TARGET_DIR}/Drivers/CMSIS/Device/ST/STM32G4xx/Source/Templates/gcc/startup_stm32g491xx.s"
".syntax unified
.cpu cortex-m4
.thumb
.section .isr_vector,\"a\",%progbits
.type g_pfnVectors, %object
g_pfnVectors:
  .word  _estack
  .word  Reset_Handler
  .word  NMI_Handler
  .word  HardFault_Handler
.text
.thumb_func
.align 2
.globl Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
  ldr   r0, =_estack
  mov   sp, r0
  bl    main
.weak NMI_Handler
.type NMI_Handler, %function
NMI_Handler: b .
.weak HardFault_Handler
.type HardFault_Handler, %function
HardFault_Handler: b .
")
    
    # Create marker file
    file(WRITE "${TARGET_DIR}/Drivers/.stm32cube_g4_minimal" 
        "Minimal HAL drivers created for immediate building\nFor full drivers, download STM32CubeG4 from: https://www.st.com/en/embedded-software/stm32cubeg4.html\n")
        
    message(STATUS "✓ Minimal HAL drivers created successfully")
    message(WARNING "These are MINIMAL drivers for building only!")
    message(WARNING "For production use, download full STM32CubeG4 drivers from:")
    message(WARNING "https://www.st.com/en/embedded-software/stm32cubeg4.html")
    
endfunction()

# Function to attempt full STM32CubeG4 download
function(download_stm32cube_g4_attempt TARGET_DIR)
    message(STATUS "Attempting to download full STM32CubeG4 drivers...")
    message(WARNING "GitHub archive may not include complete drivers due to submodules")
    message(STATUS "If this fails, minimal drivers will be created instead")
    
    set(CUBE_G4_VERSION "v1.5.2")
    set(CUBE_G4_URL "https://github.com/STMicroelectronics/STM32CubeG4/archive/refs/tags/${CUBE_G4_VERSION}.zip")
    set(DOWNLOAD_DIR "${CMAKE_BINARY_DIR}/downloads")
    set(CUBE_G4_ZIP "${DOWNLOAD_DIR}/STM32CubeG4-${CUBE_G4_VERSION}.zip")
    set(EXTRACT_DIR "${DOWNLOAD_DIR}/STM32CubeG4-extract")
    
    file(MAKE_DIRECTORY "${DOWNLOAD_DIR}")
    
    if(NOT EXISTS "${CUBE_G4_ZIP}")
        message(STATUS "Downloading STM32CubeG4 ${CUBE_G4_VERSION}...")
        file(DOWNLOAD 
            "${CUBE_G4_URL}"
            "${CUBE_G4_ZIP}"
            SHOW_PROGRESS
            STATUS DOWNLOAD_STATUS
        )
        
        list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
        if(NOT STATUS_CODE EQUAL 0)
            return()  # Failed download, caller will handle
        endif()
    endif()
    
    file(ARCHIVE_EXTRACT INPUT "${CUBE_G4_ZIP}" DESTINATION "${EXTRACT_DIR}")
    
    file(GLOB CUBE_DIRS "${EXTRACT_DIR}/STM32CubeG4*")
    list(GET CUBE_DIRS 0 CUBE_SOURCE_DIR)
    
    # Check if drivers exist and are complete
    if(EXISTS "${CUBE_SOURCE_DIR}/Drivers/STM32G4xx_HAL_Driver/Inc/stm32g4xx_hal.h")
        file(COPY "${CUBE_SOURCE_DIR}/Drivers/" DESTINATION "${TARGET_DIR}/Drivers")
        file(WRITE "${TARGET_DIR}/Drivers/.stm32cube_g4_downloaded" "STM32CubeG4 ${CUBE_G4_VERSION}\n")
        message(STATUS "✓ Full STM32CubeG4 drivers installed successfully")
        return()
    else()
        message(WARNING "Downloaded archive does not contain complete drivers")
        return()
    endif()
endfunction()

# Function to check if STM32CubeG4 drivers are present
function(check_stm32cube_g4_drivers RESULT_VAR TARGET_DIR)
    set(REQUIRED_FILES
        "${TARGET_DIR}/Drivers/STM32G4xx_HAL_Driver/Inc/stm32g4xx_hal.h"
        "${TARGET_DIR}/Drivers/STM32G4xx_HAL_Driver/Src/stm32g4xx_hal.c"
        "${TARGET_DIR}/Drivers/CMSIS/Device/ST/STM32G4xx/Include/stm32g491xx.h"
        "${TARGET_DIR}/Drivers/CMSIS/Include/core_cm4.h"
    )
    
    set(ALL_PRESENT TRUE)
    foreach(FILE ${REQUIRED_FILES})
        if(NOT EXISTS "${FILE}")
            set(ALL_PRESENT FALSE)
            break()
        endif()
    endforeach()
    
    set(${RESULT_VAR} ${ALL_PRESENT} PARENT_SCOPE)
endfunction()

# Main function to ensure STM32CubeG4 drivers are available
function(ensure_stm32cube_g4_drivers)
    set(PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
    
    # Check if drivers are already present
    check_stm32cube_g4_drivers(DRIVERS_PRESENT "${PROJECT_ROOT}")
    
    if(NOT DRIVERS_PRESENT)
        message(STATUS "STM32CubeG4 drivers not found - setting up automatically...")
        
        # Try full download first
        download_stm32cube_g4_attempt("${PROJECT_ROOT}")
        
        # Check if full download worked
        check_stm32cube_g4_drivers(DRIVERS_PRESENT "${PROJECT_ROOT}")
        
        if(NOT DRIVERS_PRESENT)
            message(STATUS "Full download failed or incomplete - creating minimal drivers...")
            create_minimal_hal_drivers("${PROJECT_ROOT}")
            
            # Verify minimal drivers were created
            check_stm32cube_g4_drivers(DRIVERS_PRESENT "${PROJECT_ROOT}")
            if(NOT DRIVERS_PRESENT)
                message(FATAL_ERROR "Failed to create minimal STM32CubeG4 drivers")
            endif()
        endif()
    else()
        message(STATUS "✓ STM32CubeG4 drivers found")
    endif()
endfunction()