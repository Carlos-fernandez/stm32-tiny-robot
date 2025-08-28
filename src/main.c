#include "stm32g4xx.h"

#define LED_PIN GPIO_PIN_5
#define LED_GPIO_PORT GPIOA
#define LED_GPIO_CLK_ENABLE() __HAL_RCC_GPIOA_CLK_ENABLE()

void delay(volatile uint32_t s) {
    for(volatile uint32_t i = 0; i < s; i++);
}

int main(void) {
    // Enable GPIOA Clock
    LED_GPIO_CLK_ENABLE();

    // Configure LED Pin as Output
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Pin = LED_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(LED_GPIO_PORT, &GPIO_InitStruct);

    while (1) {
        HAL_GPIO_TogglePin(LED_GPIO_PORT, LED_PIN);
        delay(1000000); // Simple delay
    }
}