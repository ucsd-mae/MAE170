arduino-cli config add board_manager.additional_urls https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json

arduino-cli core update-index

arduino-cli core install rp2040:rp2040

:: update preferences for arduino IDE 1.8
@echo off
setlocal enabledelayedexpansion

SET "PREFS_PATH=%LOCALAPPDATA%\Arduino15\preferences.txt"
SET "URL=https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json"

:: 1. Skip entirely if the file does not exist
IF NOT EXIST "%PREFS_PATH%" (
   type nul > "%PREFS_PATH%"
   )

:: 2. Check if the URL is already present anywhere in the file
findstr /C:"%URL%" "%PREFS_PATH%" >nul && exit /b

:: 3. Check if the key itself exists
findstr /B /C:"boardsmanager.additional.urls=" "%PREFS_PATH%" >nul
IF %ERRORLEVEL% NEQ 0 (
    :: Key doesn't exist: append the key and the URL directly
    echo boardsmanager.additional.urls=%URL%>>"%PREFS_PATH%"
    exit /b
)

:: 4. Key exists but URL does not: append URL with a comma delimiter
set "TEMP_PREFS=%PREFS_PATH%.tmp"
(for /f "tokens=1* delims==" %%A in ('type "%PREFS_PATH%"') do (
    if "%%A"=="boardsmanager.additional.urls" (
        echo boardsmanager.additional.urls=%%B,%URL%
    ) else (
        if "%%B"=="" (echo %%A) else (echo %%A=%%B)
    )
)) > "%TEMP_PREFS%"

move /y "%TEMP_PREFS%" "%PREFS_PATH%" >nul