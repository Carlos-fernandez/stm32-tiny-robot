param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

Write-Host "Downloading STM32CubeG4 HAL drivers..." -ForegroundColor Green

# Ensure TLS 1.2 for GitHub downloads
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch { }

# Prepare folders
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$driversDir  = Join-Path $projectRoot 'Drivers'
New-Item -ItemType Directory -Path $driversDir -ErrorAction SilentlyContinue | Out-Null

# Remove existing drivers (optional unless -Force)
if ($Force) {
    if (Test-Path (Join-Path $driversDir 'STM32G4xx_HAL_Driver')) {
        Write-Host "Removing existing drivers (HAL)..." -ForegroundColor Yellow
        Remove-Item (Join-Path $driversDir 'STM32G4xx_HAL_Driver') -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path (Join-Path $driversDir 'CMSIS')) {
        Write-Host "Removing existing drivers (CMSIS)..." -ForegroundColor Yellow
        Remove-Item (Join-Path $driversDir 'CMSIS') -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Candidate URLs (try in order)
$urls = @(
    # codeload is more reliable than html redirects
    'https://codeload.github.com/STMicroelectronics/STM32CubeG4/zip/refs/heads/master',
    'https://codeload.github.com/STMicroelectronics/STM32CubeG4/zip/refs/heads/main',
    # try a few known tags as fallback
    'https://codeload.github.com/STMicroelectronics/STM32CubeG4/zip/refs/tags/v1.6.1',
    'https://codeload.github.com/STMicroelectronics/STM32CubeG4/zip/refs/tags/v1.6.0',
    'https://codeload.github.com/STMicroelectronics/STM32CubeG4/zip/refs/tags/v1.5.0'
)

# Create temp working directory
$tempRoot = Join-Path $env:TEMP ("stm32cube_dl_" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tempRoot | Out-Null
$zipPath = Join-Path $tempRoot 'STM32CubeG4.zip'

function Invoke-Download($uri, $dest) {
    Write-Host "Attempting download: $uri" -ForegroundColor Cyan
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Headers['User-Agent'] = 'curl/8.0 (ps)'
        $wc.DownloadFile($uri, $dest)
        return $true
    } catch {
        Write-Host "  Download failed: $($_.Exception.Message)" -ForegroundColor DarkYellow
        return $false
    }
}

$downloaded = $false
foreach ($u in $urls) {
    if (Invoke-Download -uri $u -dest $zipPath) { $downloaded = $true; $chosenUrl = $u; break }
}

if (-not $downloaded) {
    Write-Host "✗ Unable to download STM32CubeG4 from GitHub."
    Write-Host "Please download manually from: https://www.st.com/en/embedded-software/stm32cubeg4.html"
    exit 1
}

Write-Host "Extracting archive..." -ForegroundColor Yellow
Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

# Find extracted folder (supports -master or -main suffix)
$extracted = Get-ChildItem -Path $tempRoot -Directory | Where-Object { $_.Name -like 'STM32CubeG4-*' } | Select-Object -First 1
if (-not $extracted) {
    Write-Host "✗ Extracted content not found."
    exit 1
}

$srcDrivers = Join-Path $extracted.FullName 'Drivers'
$srcHAL = Join-Path $srcDrivers 'STM32G4xx_HAL_Driver'
$srcCMSIS = Join-Path $srcDrivers 'CMSIS'

# Auto-detect HAL and CMSIS if default structure not present or empty
if (-not (Test-Path $srcHAL) -or ((Get-ChildItem -Path $srcHAL -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0)) {
    Write-Host "HAL default path missing or empty. Scanning for HAL driver..." -ForegroundColor Yellow
    $halHeader = Get-ChildItem -Path $extracted.FullName -Recurse -Filter 'stm32g4xx_hal.h' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($halHeader) { $srcHAL = Split-Path -Parent $halHeader.FullName | Split-Path -Parent } # go up from Inc to HAL root
    # If still empty, fetch HAL from dedicated repo (submodule content not in zip archives)
    if (-not (Test-Path $srcHAL) -or ((Get-ChildItem -Path $srcHAL -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0)) {
        Write-Host "HAL not found in STM32CubeG4 archive (likely a submodule). Downloading HAL from dedicated repo..." -ForegroundColor Yellow
        $halUrls = @(
            'https://codeload.github.com/STMicroelectronics/stm32g4xx_hal_driver/zip/refs/heads/master',
            'https://codeload.github.com/STMicroelectronics/stm32g4xx_hal_driver/zip/refs/heads/main',
            'https://codeload.github.com/STMicroelectronics/stm32g4xx_hal_driver/zip/refs/tags/v1.6.1',
            'https://codeload.github.com/STMicroelectronics/stm32g4xx_hal_driver/zip/refs/tags/v1.6.0'
        )
        $halZip = Join-Path $tempRoot 'stm32g4xx_hal_driver.zip'
        $halDownloaded = $false
        foreach ($hu in $halUrls) {
            if (Invoke-Download -uri $hu -dest $halZip) { $halDownloaded = $true; $chosenHalUrl = $hu; break }
        }
        if (-not $halDownloaded) {
            Write-Host '✗ Failed to download HAL driver repo.' -ForegroundColor Red
            Write-Host '  Try manual download: https://github.com/STMicroelectronics/stm32g4xx_hal_driver' -ForegroundColor Yellow
            exit 1
        }
        Write-Host "Extracting HAL driver archive..." -ForegroundColor Yellow
        Expand-Archive -Path $halZip -DestinationPath $tempRoot -Force
        # HAL repo may use '-' or '_' in folder name; detect by content
        $halExtracted = Get-ChildItem -Path $tempRoot -Directory | Where-Object { $_.Name -like 'stm32g4xx*hal*driver*' } | Select-Object -First 1
        if (-not $halExtracted) {
            # Fallback: search for header file and go up
            $halHeader2 = Get-ChildItem -Path $tempRoot -Recurse -Filter 'stm32g4xx_hal.h' -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($halHeader2) {
                $srcHAL = Split-Path -Parent $halHeader2.FullName | Split-Path -Parent
            } else {
                Write-Host '✗ Unable to locate extracted HAL driver folder.' -ForegroundColor Red
                exit 1
            }
        } else {
            $srcHAL = $halExtracted.FullName
        }
    }
}
if (-not (Test-Path $srcCMSIS)) {
    Write-Host "CMSIS default path missing. Scanning for CMSIS..." -ForegroundColor Yellow
    $cmsisDevice = Get-ChildItem -Path $extracted.FullName -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.FullName -like '*CMSIS*Device*STM32G4xx*Include' } | Select-Object -First 1
    if ($cmsisDevice) { $srcCMSIS = (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $cmsisDevice.FullName))) }
}

if (-not (Test-Path $srcHAL) -or -not (Test-Path $srcCMSIS)) {
    Write-Host "✗ Expected driver folders not found in archive." -ForegroundColor Red
    Write-Host "  Looked for: $srcHAL and $srcCMSIS" -ForegroundColor Gray
    exit 1
}

Write-Host "Preview extracted HAL driver files (top 10):" -ForegroundColor Gray
Get-ChildItem -Path $srcHAL -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 10 | ForEach-Object { Write-Host ("  " + $_.FullName) -ForegroundColor DarkGray }

$halCount = (Get-ChildItem -Path $srcHAL -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
$cmsisCount = (Get-ChildItem -Path $srcCMSIS -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Host "Found $halCount HAL files, $cmsisCount CMSIS files in archive." -ForegroundColor Gray
if ($halCount -eq 0) {
    Write-Host "HAL contents (depth 2):" -ForegroundColor Gray
    Get-ChildItem -Path $srcHAL -Depth 2 -ErrorAction SilentlyContinue | ForEach-Object { Write-Host ("  " + $_.FullName) -ForegroundColor DarkGray }
}

Write-Host "Copying drivers..." -ForegroundColor Yellow
# Ensure destination subfolders are clean to avoid residual empty dirs
if (Test-Path (Join-Path $driversDir 'STM32G4xx_HAL_Driver')) { Remove-Item (Join-Path $driversDir 'STM32G4xx_HAL_Driver') -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path (Join-Path $driversDir 'CMSIS')) { Remove-Item (Join-Path $driversDir 'CMSIS') -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path (Join-Path $srcHAL 'Inc')) {
    New-Item -ItemType Directory -Path (Join-Path $driversDir 'STM32G4xx_HAL_Driver') -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -LiteralPath (Join-Path $srcHAL 'Inc') -Destination (Join-Path $driversDir 'STM32G4xx_HAL_Driver') -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $srcHAL 'Src') -Destination (Join-Path $driversDir 'STM32G4xx_HAL_Driver') -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Copy-Item -LiteralPath $srcHAL  -Destination $driversDir -Recurse -Force
}
Copy-Item -LiteralPath $srcCMSIS -Destination $driversDir -Recurse -Force

# Post copy counts
$destHAL = Join-Path $driversDir 'STM32G4xx_HAL_Driver'
$destHALCount = (Get-ChildItem -Path $destHAL -Recurse -File | Measure-Object).Count
Write-Host "Copied HAL files: $destHALCount" -ForegroundColor Gray

# Verify key files exist (accept either specific part header or family header)
$ok = $true
$mustHave = Join-Path $driversDir 'STM32G4xx_HAL_Driver\Inc\stm32g4xx_hal.h'
if (-not (Test-Path $mustHave)) { $ok = $false; Write-Host "Missing: $mustHave" -ForegroundColor Red }

$deviceHeaderSpecific = Join-Path $driversDir 'CMSIS\Device\ST\STM32G4xx\Include\stm32g491xx.h'
$deviceHeaderFamily   = Join-Path $driversDir 'CMSIS\Device\ST\STM32G4xx\Include\stm32g4xx.h'
if (-not (Test-Path $deviceHeaderSpecific) -and -not (Test-Path $deviceHeaderFamily)) {
    Write-Host "CMSIS Device headers for G4 not found in Cube archive. Downloading cmsis_device_g4..." -ForegroundColor Yellow
    function Get-CmsisDeviceG4 {
        param($tmpRoot)
        $cdUrls = @(
            'https://codeload.github.com/STMicroelectronics/cmsis_device_g4/zip/refs/heads/master',
            'https://codeload.github.com/STMicroelectronics/cmsis_device_g4/zip/refs/heads/main',
            'https://codeload.github.com/STMicroelectronics/cmsis_device_g4/zip/refs/tags/v1.6.1',
            'https://codeload.github.com/STMicroelectronics/cmsis_device_g4/zip/refs/tags/v1.6.0'
        )
        $zip = Join-Path $tmpRoot 'cmsis_device_g4.zip'
        $okdl = $false
        foreach ($u in $cdUrls) { if (Invoke-Download -uri $u -dest $zip) { $okdl = $true; $script:chosenCmsisUrl = $u; break } }
        if (-not $okdl) { throw 'Failed to download cmsis_device_g4' }
        Expand-Archive -Path $zip -DestinationPath $tmpRoot -Force
        $cdExtracted = Get-ChildItem -Path $tmpRoot -Directory | Where-Object { $_.Name -like 'cmsis_device_g4-*' } | Select-Object -First 1
        if (-not $cdExtracted) {
            $hdr = Get-ChildItem -Path $tmpRoot -Recurse -Filter 'stm32g4xx.h' -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($hdr) { return (Split-Path -Parent $hdr.FullName) } else { throw 'Unable to locate cmsis_device_g4 Include' }
        }
        return (Join-Path $cdExtracted.FullName 'Include')
    }

    try {
        $cdInclude = Get-CmsisDeviceG4 -tmpRoot $tempRoot
        $cdRoot = Split-Path -Parent $cdInclude
        $destDevice = Join-Path $driversDir 'CMSIS\Device\ST\STM32G4xx'
        New-Item -ItemType Directory -Path $destDevice -ErrorAction SilentlyContinue | Out-Null
        Copy-Item -LiteralPath (Join-Path $cdRoot 'Include') -Destination $destDevice -Recurse -Force
        if (Test-Path (Join-Path $cdRoot 'Source')) {
            Copy-Item -LiteralPath (Join-Path $cdRoot 'Source') -Destination $destDevice -Recurse -Force
        }
    } catch {
        Write-Host ("✗ Failed to install cmsis_device_g4: " + $_.Exception.Message) -ForegroundColor Red
    }
}

if (-not $ok) {
    Write-Host "✗ Driver installation incomplete." -ForegroundColor Red
    Write-Host "  Please check GitHub rate limits or try again with VPN if blocked." -ForegroundColor Yellow
    exit 1
}

# Write a marker with basic version info
$marker = Join-Path $driversDir '.stm32cube_g4_downloaded'
"STM32CubeG4 source: $chosenUrl" | Out-File -FilePath $marker -Encoding utf8 -Force
"Installed on: $(Get-Date -Format o)" | Out-File -FilePath $marker -Append -Encoding utf8

# Cleanup
Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n✓ STM32CubeG4 HAL drivers installed successfully!" -ForegroundColor Green
Write-Host "You can now rebuild your project with full HAL support." -ForegroundColor Cyan