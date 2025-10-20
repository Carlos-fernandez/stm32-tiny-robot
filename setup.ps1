#!/usr/bin/env pwsh
# STM32 Tiny Robot - Setup Script for Windows
# This script helps new users set up the development environment automatically

Write-Host "=== STM32 Tiny Robot Setup Script ===" -ForegroundColor Cyan
Write-Host ""

# Check required tools
Write-Host "Checking development tools..." -ForegroundColor Yellow

# Check ARM GCC Toolchain
try {
    $gcc_version = & arm-none-eabi-gcc --version 2>$null | Select-Object -First 1
    Write-Host "✓ ARM GCC Toolchain: $gcc_version" -ForegroundColor Green
} catch {
    Write-Host "✗ ARM GCC Toolchain not found" -ForegroundColor Red
    Write-Host "  Please install: https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm" -ForegroundColor Yellow
    $missing_tools = $true
}

# Check CMake
try {
    $cmake_version = & cmake --version 2>$null | Select-Object -First 1
    Write-Host "✓ CMake: $cmake_version" -ForegroundColor Green
} catch {
    Write-Host "✗ CMake not found" -ForegroundColor Red
    Write-Host "  Please install: https://cmake.org/download/" -ForegroundColor Yellow
    $missing_tools = $true
}

# Check Ninja
try {
    $ninja_version = & ninja --version 2>$null
    Write-Host "✓ Ninja Build System: $ninja_version" -ForegroundColor Green
} catch {
    Write-Host "✗ Ninja not found" -ForegroundColor Red
    Write-Host "  Please install: choco install ninja (or download from https://ninja-build.org/)" -ForegroundColor Yellow
    $missing_tools = $true
}

if ($missing_tools) {
    Write-Host ""
    Write-Host "Please install the missing tools and run this script again." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Checking STM32 HAL drivers..." -ForegroundColor Yellow

$hal_marker = "Drivers/.stm32cube_g4_downloaded"
$hal_key_files = @(
    "Drivers/STM32G4xx_HAL_Driver/Inc/stm32g4xx_hal.h",
    "Drivers/CMSIS/Device/ST/STM32G4xx/Include/stm32g491xx.h"
)

$drivers_present = $true
foreach ($file in $hal_key_files) {
    if (-not (Test-Path $file)) {
        $drivers_present = $false
        break
    }
}

if ($drivers_present) {
    Write-Host "✓ STM32CubeG4 drivers found" -ForegroundColor Green
    if (Test-Path $hal_marker) {
        $version_info = Get-Content $hal_marker -First 1
        Write-Host "  $version_info" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠ STM32CubeG4 drivers not found" -ForegroundColor Yellow
    Write-Host "  Don't worry - CMake will download them automatically during configuration!" -ForegroundColor Cyan
    Write-Host "  This is a one-time download (~50MB)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Configuring project..." -ForegroundColor Yellow

# Clean previous build
if (Test-Path "build/debug") {
    Write-Host "Cleaning previous build..." -ForegroundColor Gray
    Remove-Item -Recurse -Force "build/debug" -ErrorAction SilentlyContinue
}

# Configure with CMake
try {
    Write-Host "Running CMake configure..." -ForegroundColor Gray
    & cmake --preset debug
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Project configured successfully" -ForegroundColor Green
    } else {
        throw "CMake configuration failed"
    }
} catch {
    Write-Host "✗ CMake configuration failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Building project..." -ForegroundColor Yellow

# Build the project
try {
    Write-Host "Running build..." -ForegroundColor Gray
    & cmake --build build/debug
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Project built successfully" -ForegroundColor Green
        Write-Host ""
        Write-Host "Build outputs:" -ForegroundColor Cyan
        Get-ChildItem "build/debug" -Filter "*.elf" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        Get-ChildItem "build/debug" -Filter "*.hex" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        Get-ChildItem "build/debug" -Filter "*.bin" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    } else {
        throw "Build failed"
    }
} catch {
    Write-Host "✗ Build failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Flash firmware: cmake --build build/debug --target flash" -ForegroundColor White
Write-Host "2. Or use: openocd + gdb for debugging" -ForegroundColor White
Write-Host "3. Edit src/main.c for your robot code" -ForegroundColor White
Write-Host ""
Write-Host "VS Code tasks available:" -ForegroundColor Cyan
Write-Host "- Build: Ctrl+Shift+P -> Tasks: Run Task -> Build" -ForegroundColor White
Write-Host "- Flash: Ctrl+Shift+P -> Tasks: Run Task -> Flash" -ForegroundColor White