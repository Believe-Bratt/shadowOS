@echo off
REM ============================================================================
REM ShadowOS Wallpaper Setup — BeltrixOS Inspired Cyber City
REM ============================================================================
REM This script downloads a cyberpunk city wallpaper matching the BeltrixOS aesthetic
REM ============================================================================

setlocal enabledelayedexpansion

set "WALLPAPER_DIR=%~dp0"
set "WALLPAPER_FILE=%WALLPAPER_DIR%cyber-city.jpg"

echo === ShadowOS Wallpaper Setup ===
echo.

REM Check if wallpaper already exists
if exist "%WALLPAPER_FILE%" (
    echo Wallpaper already exists at: %WALLPAPER_FILE%
    set /p "confirm=Do you want to re-download? (y/N): "
    if /i not "!confirm!"=="y" (
        echo Exiting...
        exit /b 0
    )
)

echo Downloading cyberpunk city wallpaper...
echo.

REM Try using PowerShell to download
powershell -Command "& {
    try {
        Invoke-WebRequest -Uri 'https://images.pexels.com/photos/12832188/pexels-photo-12832188.jpeg?auto=compress&cs=tinysrgb&w=1920' -OutFile '%WALLPAPER_FILE%' -UseBasicParsing
        Write-Host 'Wallpaper downloaded successfully!'
        Write-Host '  Location: %WALLPAPER_FILE%'
    } catch {
        Write-Host 'Warning: Download failed.'
        Write-Host 'Please manually add a wallpaper to: %WALLPAPER_FILE%'
        exit 1
    }
}" 2>nul

if exist "%WALLPAPER_FILE%" (
    echo.
    echo To set the wallpaper:
    echo   - Right-click on desktop ^> Personalize ^> Background ^> Browse
    echo   - Select: %%USERPROFILE%%\\.config\\shadowos\\cyberpunk-theme\\wallpapers\\cyber-city.jpg
) else (
    echo.
    echo Please manually download a cyberpunk city wallpaper and place it at:
    echo   %WALLPAPER_FILE%
    echo.
    echo Recommended sources: Pexels, Unsplash (search "cyberpunk city")
)

pause
