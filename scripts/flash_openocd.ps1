# PowerShell script to flash STM32G491RE using OpenOCD

$openocdPath = "C:\path\to\openocd\bin\openocd.exe"
$interfaceConfig = "scripts/openocd/interface_stlink.cfg"
$targetConfig = "scripts/openocd/target_stm32g4x.cfg"
$firmwarePath = "build/your_firmware.bin"

# Check if OpenOCD is installed
if (-Not (Test-Path $openocdPath)) {
    Write-Host "OpenOCD not found at $openocdPath. Please install OpenOCD and update the path."
    exit 1
}

# Start OpenOCD
Start-Process -FilePath $openocdPath -ArgumentList "-f $interfaceConfig", "-f $targetConfig", "-c 'program $firmwarePath verify reset exit'" -NoNewWindow -Wait

Write-Host "Flashing completed."