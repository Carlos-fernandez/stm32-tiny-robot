# STM32 Tiny Robot Project

A simple STM32G491RE-based robot firmware project with automated setup and CMake build system. This project includes all necessary configurations for building, flashing, and debugging your STM32 application.

## 🚀 Quick Start for New Users

### Prerequisites

1. **ARM GCC Toolchain**: Download from [ARM Developer](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm)
2. **CMake** (≥3.20): Download from [cmake.org](https://cmake.org/download/)  
3. **Ninja Build System**: Install via `choco install ninja` or download from [ninja-build.org](https://ninja-build.org/)

### Automated Setup

Run the setup script to automatically configure everything:

```powershell
# Windows PowerShell
.\setup.ps1
```

This script will:
- ✅ Check for required development tools
- ✅ **Automatically download minimal STM32CubeG4 HAL drivers**  
- ✅ Configure the CMake project
- ✅ Build the firmware  
- ✅ Generate .elf, .hex, and .bin files

**✨ NEW: One-Command Setup!** CMake will automatically create minimal HAL drivers if none are found, so your project builds immediately without manual downloads!

### 🔄 Getting Full STM32CubeG4 Drivers (Optional)

The project automatically creates **minimal HAL drivers** for immediate building. For production or advanced features:

```powershell
# Option 1: Use helper script  
.\download-full-drivers.ps1

# Option 2: Manual download
# 1. Download STM32CubeG4 from: https://www.st.com/en/embedded-software/stm32cubeg4.html
# 2. Extract and replace the 'Drivers' folder
# 3. Rebuild: cmake --build build/debug --clean-first
```

**Full drivers include**: Complete HAL peripherals (UART, SPI, I2C, etc.), BSP files, and documentation.

## Project Structure

The project is organized as follows:

```
stm32g491re-cmake
├── CMakeLists.txt            # Main CMake configuration file
├── CMakePresets.json         # CMake presets for different build configurations
├── cmake                     # CMake configuration files
│   ├── toolchain-gcc-arm-none-eabi.cmake  # Toolchain setup for ARM GCC
│   ├── stm32g491re.cmake     # STM32G491RE specific configurations
│   ├── flash.cmake           # Flashing configurations
│   └── FindOpenOCD.cmake     # Locate OpenOCD tool
├── linker                    # Linker script
│   └── STM32G491RETx_FLASH.ld # Memory layout and sections
├── scripts                   # Scripts for flashing and debugging
│   ├── flash_openocd.sh      # Flashing script for Linux
│   ├── flash_openocd.ps1     # Flashing script for Windows
│   └── debug.gdb             # GDB commands for debugging
├── scripts/openocd           # OpenOCD configuration files
│   ├── interface_stlink.cfg   # ST-Link interface configuration
│   └── target_stm32g4x.cfg    # STM32G4 target configuration
├── src                       # Source files
│   ├── main.c                # Main application source file
│   └── system_stm32g4xx.c    # System initialization code
├── include                   # Header files
│   └── stm32g4xx_hal_conf.h   # HAL configuration settings
├── Drivers                   # Driver files
│   ├── CMSIS                 # CMSIS header files
│   │   ├── Device            # Device specific headers
│   │   │   └── ST
│   │   │       └── STM32G4xx
│   │   │           └── Include
│   │   └── Include
│   └── STM32G4xx_HAL_Driver  # STM32G4 HAL driver files
│       ├── Inc               # Public header files
│       └── Src               # Source files
├── .vscode                   # Visual Studio Code settings
│   ├── settings.json         # VS Code specific settings
│   ├── tasks.json            # Build and flash tasks
│   └── launch.json           # Debug configurations
└── README.md                 # Project documentation
```

## Getting Started

1. **Prerequisites**: Ensure you have the ARM GCC toolchain and OpenOCD installed on your system.

2. **Building the Project**:
   - Navigate to the project directory.
   - Create a build directory: `mkdir build && cd build`
   - Run CMake: `cmake ..`
   - Build the project: `cmake --build .`

3. **Flashing the Firmware**:
   - Use the provided scripts to flash the firmware to the STM32G491RE:
     - For Linux: `./scripts/flash_openocd.sh`
     - For Windows: `.\scripts\flash_openocd.ps1`

4. **Debugging**:
   - Use the provided GDB commands in `scripts/debug.gdb` to debug your application.

## License

This project is licensed under the MIT License. See the LICENSE file for details.