#include "stm32g4xx.h"

uint32_t SystemCoreClock = 16000000;  // 16MHz HSI (default)

void SystemInit(void) {
    // Minimal system initialization
    // The clock is already configured to HSI 16MHz by default
    // We don't need to change anything for basic GPIO operation
}

void SystemCoreClockUpdate(void) {
    // Simple implementation - we're using the default HSI at 16MHz
    SystemCoreClock = 16000000;
}