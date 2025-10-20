#!/usr/bin/env pwsh
# Manual STM32CubeG4 Driver Download Script
# Use this if you want to get the full official HAL drivers

Write-Host "=== STM32CubeG4 Full Driver Download ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will help you download the complete STM32CubeG4 HAL drivers." -ForegroundColor Yellow
Write-Host "The project currently uses minimal drivers that work for basic builds." -ForegroundColor Gray
Write-Host ""

$response = Read-Host "Do you want to download the full STM32CubeG4 package? (y/N)"
if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "Download cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Opening STM32CubeG4 download page..." -ForegroundColor Cyan
Start-Process "https://www.st.com/en/embedded-software/stm32cubeg4.html"

Write-Host ""
Write-Host "Instructions:" -ForegroundColor Yellow
Write-Host "1. Download STM32CubeG4 from the opened webpage" -ForegroundColor White
Write-Host "2. Extract the downloaded zip file" -ForegroundColor White  
Write-Host "3. Copy the 'Drivers' folder from STM32CubeG4 to this project root" -ForegroundColor White
Write-Host "4. Replace the existing 'Drivers' folder when prompted" -ForegroundColor White
Write-Host "5. Run: cmake --build build/debug --clean-first" -ForegroundColor White
Write-Host ""
Write-Host "After replacing with full drivers, you'll have access to:" -ForegroundColor Cyan
Write-Host "- Complete HAL peripheral drivers (UART, SPI, I2C, etc.)" -ForegroundColor White
Write-Host "- Full CMSIS Device Support Package" -ForegroundColor White
Write-Host "- Complete BSP (Board Support Package) files" -ForegroundColor White
Write-Host "- Documentation and examples" -ForegroundColor White