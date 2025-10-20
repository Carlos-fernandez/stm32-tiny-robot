# STM32 Flashing Guide

## 🔥 Quick Flash Commands

### Method 1: OpenOCD (Available on your system)
```powershell
# Build and flash
cmake --build build/debug --target flash_openocd

# Or manually with OpenOCD
openocd -f scripts/openocd/interface_stlink.cfg -f scripts/openocd/target_stm32g4x.cfg -c "program build/debug/STM32G491RE_Project.elf verify reset exit"
```

### Method 2: STM32CubeProgrammer (Recommended - needs installation)
```powershell
# After installing STM32CubeProgrammer
cmake --build build/debug --target flash
```

## 📦 Installing STM32CubeProgrammer

1. **Download**: [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html)
2. **Install** and add to PATH, or run:
   ```powershell
   # If using Chocolatey
   choco install stm32cubeprogrammer
   ```

## 🔌 Hardware Connection

### For Nucleo-G491RE Board:
1. Connect board via **USB cable** (ST-Link USB connector)
2. **Power LED** should be on
3. Board appears as **ST-Link** device

### For Custom STM32G491RE Board:
1. Connect **ST-Link V2/V3** programmer
2. Connect **SWDIO, SWCLK, GND, VCC** pins
3. Ensure **3.3V power** to your board

## 🚀 Step-by-Step Flashing

### Using OpenOCD (You have this):
```powershell
# 1. Build firmware
cmake --build build/debug

# 2. Connect board and flash
cmake --build build/debug --target flash_openocd
```

### Using STM32CubeProgrammer (after installing):
```powershell
# 1. Build firmware  
cmake --build build/debug

# 2. Flash via STM32CubeProgrammer
cmake --build build/debug --target flash

# Or manually:
STM32_Programmer_CLI -c port=SWD -w build/debug/STM32G491RE_Project.hex -v -rst
```

## 🛠️ Troubleshooting

### "Device not found":
- Check USB connection
- Install ST-Link drivers
- Try different USB port
- Press RESET button on board

### "Permission denied":
- Run terminal as Administrator
- Close other ST software (STM32CubeIDE, etc.)

### OpenOCD connection issues:
- Check `scripts/openocd/` config files exist
- Verify ST-Link connection
- Try: `openocd -f interface/stlink.cfg -f target/stm32g4x.cfg`

## 📊 Verify Flashing

After successful flash, your board should:
1. **LED blinks** (PA5 - onboard LED on Nucleo boards)
2. **Reset and run** automatically
3. Show **"Verified OK"** message

## 🎯 What Gets Flashed

- **Firmware**: `build/debug/STM32G491RE_Project.elf`
- **Size**: ~216 bytes (minimal LED blink program)
- **Flash Address**: 0x08000000 (STM32 flash start)