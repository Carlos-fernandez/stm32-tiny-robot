#ifndef STM32G4XX_HAL_CONF_H
#define STM32G4XX_HAL_CONF_H

// Enable only the HAL modules we need
#define HAL_MODULE_ENABLED
#define HAL_GPIO_MODULE_ENABLED
#define HAL_RCC_MODULE_ENABLED
#define HAL_CORTEX_MODULE_ENABLED
#define HAL_PWR_MODULE_ENABLED
#define HAL_FLASH_MODULE_ENABLED

// System clock source
#if !defined (HSI_VALUE)
#define HSI_VALUE               16000000U
#endif

#if !defined (HSE_VALUE)
#define HSE_VALUE               8000000U
#endif

#if !defined (LSI_VALUE)
#define LSI_VALUE               32000U    
#endif

#if !defined (LSE_VALUE)
#define LSE_VALUE               32768U
#endif

// Startup timeouts
#define HSE_STARTUP_TIMEOUT     100U
#define LSE_STARTUP_TIMEOUT     5000U

// Power stop entry modes are defined by HAL PWR headers; do not redefine here

// Priority grouping for interrupts
#define NVIC_PRIORITYGROUP_4         0x00000003U
#define HAL_NVIC_PRIORITYGROUP_4     NVIC_PRIORITYGROUP_4

// SysTick timer priority
#define TICK_INT_PRIORITY            0x0FU

// Flash latency definitions are provided by HAL Flash headers; do not redefine here

// Power voltage scaling
#define PWR_REGULATOR_VOLTAGE_SCALE1    PWR_CR1_VOS_0

// Assert macro (disable for simple build)
#define assert_param(expr) ((void)0U)

#ifdef HAL_RCC_MODULE_ENABLED
#include "stm32g4xx_hal_rcc.h"
#endif

#ifdef HAL_GPIO_MODULE_ENABLED
#include "stm32g4xx_hal_gpio.h"
#endif

#ifdef HAL_CORTEX_MODULE_ENABLED
#include "stm32g4xx_hal_cortex.h"
#endif

#ifdef HAL_PWR_MODULE_ENABLED
#include "stm32g4xx_hal_pwr.h"
#include "stm32g4xx_hal_pwr_ex.h"
#endif

#ifdef HAL_FLASH_MODULE_ENABLED
#include "stm32g4xx_hal_flash.h"
#endif

#endif // STM32G4XX_HAL_CONF_H