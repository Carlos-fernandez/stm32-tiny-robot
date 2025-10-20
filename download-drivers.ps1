# Download full STM32CubeG4 HAL drivers
Write-Host "Downloading STM32CubeG4 HAL drivers..." -ForegroundColor Green

# Remove existing minimal drivers
if (Test-Path "Drivers\STM32G4xx_HAL_Driver") {
    Write-Host "Removing existing minimal drivers..." -ForegroundColor Yellow
    Remove-Item "Drivers\STM32G4xx_HAL_Driver" -Recurse -Force
}

if (Test-Path "Drivers\CMSIS") {
    Write-Host "Removing existing minimal CMSIS..." -ForegroundColor Yellow  
    Remove-Item "Drivers\CMSIS" -Recurse -Force
}

# Download STM32CubeG4 from ST's official repository
$cubeUrl = "https://github.com/STMicroelectronics/STM32CubeG4/archive/refs/heads/master.zip"
$zipFile = "STM32CubeG4-master.zip"

Write-Host "Downloading from: $cubeUrl" -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $cubeUrl -OutFile $zipFile -UseBasicParsing
    Write-Host "Downloaded successfully!" -ForegroundColor Green
    
    # Extract the ZIP file
    Write-Host "Extracting drivers..." -ForegroundColor Yellow
    Expand-Archive -Path $zipFile -DestinationPath "temp" -Force
    
    # Copy HAL drivers
    if (Test-Path "temp\STM32CubeG4-master\Drivers\STM32G4xx_HAL_Driver") {
        Copy-Item "temp\STM32CubeG4-master\Drivers\STM32G4xx_HAL_Driver" "Drivers\" -Recurse -Force
        Write-Host "✓ Copied STM32G4xx_HAL_Driver" -ForegroundColor Green
    }
    
    # Copy CMSIS
    if (Test-Path "temp\STM32CubeG4-master\Drivers\CMSIS") {
        Copy-Item "temp\STM32CubeG4-master\Drivers\CMSIS" "Drivers\" -Recurse -Force
        Write-Host "✓ Copied CMSIS drivers" -ForegroundColor Green
    }
    
    # Clean up
    Remove-Item $zipFile -Force
    Remove-Item "temp" -Recurse -Force
    
    Write-Host "`n✓ STM32CubeG4 HAL drivers installed successfully!" -ForegroundColor Green
    Write-Host "You can now rebuild your project with full HAL support." -ForegroundColor Cyan
    
} catch {
    Write-Host "Error downloading drivers: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Falling back to basic drivers..." -ForegroundColor Yellow
    exit 1
}