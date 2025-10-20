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
# STM32 Tiny Robot (STM32G491RE)

>A lean STM32G491RE firmware template with CMake/Ninja, automatic HAL/CMSIS setup, and one-command build/flash on Windows.

## Quick start

Windows PowerShell:

```powershell
# From the repo root
./setup.ps1
```

What this does:
- Checks for required tools (ARM GCC, CMake ≥ 3.20, Ninja)
- Ensures STM32CubeG4 drivers (HAL + CMSIS Device/Core)
   - Tries to fetch full drivers automatically
   - Falls back to minimal drivers if a full download isn’t available
- Configures CMake (Debug preset)
- Builds and produces .elf, .hex, and .bin

To flash after a successful build:

```powershell
cmake --build build/debug --target flash_openocd   # OpenOCD (ST-LINK)
# or, if you have STM32CubeProgrammer CLI installed:
cmake --build build/debug --target flash
```

## Prerequisites

- ARM GNU Toolchain (arm-none-eabi-gcc): https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain
- CMake ≥ 3.20: https://cmake.org/download/
- Ninja: https://ninja-build.org/ (or `choco install ninja`)
- One of the flash tools:
   - OpenOCD (recommended for ST-LINK)
   - STM32CubeProgrammer CLI (for the `flash` target)

Optional: VS Code with CMake Tools extension.

## Build manually (alternative to setup.ps1)

```powershell
cmake --preset=debug
cmake --build build/debug
```

Artifacts are placed in `build/debug/`.

## Drivers: HAL/CMSIS

This project manages drivers for you:

- On first configure, CMake will try to download STM32CubeG4 and install the drivers under `Drivers/`.
- If a full driver archive is incomplete (common with GitHub submodules), minimal drivers are generated so you can still build immediately.
- You can force a full, robust install anytime with the helper script:

```powershell
./download-drivers.ps1
```

After installation you should have (at minimum):
- `Drivers/STM32G4xx_HAL_Driver/Inc/stm32g4xx_hal.h`
- `Drivers/STM32G4xx_HAL_Driver/Src/...`
- `Drivers/CMSIS/Device/ST/STM32G4xx/Include/stm32g491xx.h`
- `Drivers/CMSIS/Include/core_cm4.h`

Note: The build uses the official CMSIS `system_stm32g4xx.c` so HAL clock helpers (e.g., AHB/APB prescaler tables) are present.

## Project layout (key files)

```
stm32-tiny-robot/
├─ CMakeLists.txt                     # Main build config (CMake targets incl. flash/flash_openocd)
├─ CMakePresets.json                  # Debug/Release presets
├─ cmake/
│  ├─ DownloadSTM32CubeG4.cmake       # Driver setup: download or create minimal
│  ├─ toolchain-gcc-arm-none-eabi.cmake
│  ├─ flash.cmake (if present)
│  └─ FindOpenOCD.cmake (if present)
├─ linker/
│  └─ STM32G491RETx_FLASH.ld          # Linker script
├─ scripts/
│  ├─ flash_openocd.ps1               # Windows flashing helper (optional)
│  ├─ flash_openocd.sh                # Linux/macOS helper (optional)
│  └─ debug.gdb                       # Basic GDB script
├─ scripts/openocd/
│  ├─ interface_stlink.cfg
│  └─ target_stm32g4x.cfg
├─ src/
│  ├─ main_hal.c                      # Example app using HAL
│  └─ system_stm32g4xx.c              # Local stub (not used by default)
├─ include/
│  └─ stm32g4xx_hal_conf.h            # HAL configuration
└─ Drivers/                           # HAL + CMSIS (installed automatically)
```

## Flashing

If you have an ST-LINK and OpenOCD:

```powershell
cmake --build build/debug --target flash_openocd
```

If you installed STM32CubeProgrammer CLI:

```powershell
cmake --build build/debug --target flash
```

Tip (VS Code users): A “Flash” task is provided, but its ELF path may be a template in your workspace. If it fails, either update that task to point to `build/debug/STM32G491RE_Project` or use the CMake targets above.

## Troubleshooting

- Tools not found during setup
   - Ensure `arm-none-eabi-gcc`, `cmake`, and `ninja` are on PATH.

- Linker error about `AHBPrescTable`
   - The project now uses the CMSIS device `system_stm32g4xx.c` (via CMake). Reconfigure and rebuild: `cmake --preset=debug && cmake --build build/debug`.

   - Check USB cable/driver, try running OpenOCD with `-f scripts/openocd/interface_stlink.cfg -f scripts/openocd/target_stm32g4x.cfg`.

- Flash task fails with a placeholder ELF path
   - Update the VS Code task to the built ELF or use `--target flash_openocd`.

## License

MIT — see LICENSE for details.