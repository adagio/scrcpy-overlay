@echo off
setlocal

:: Parámetros: %1=IP, %2=X, %3=Y
set "DEVICE_IP=%~1"
if "%DEVICE_IP%"=="" set "DEVICE_IP=192.168.1.101"

set "WIN_X=%~2"
set "WIN_Y=%~3"

:: Construir argumentos de posición si se proporcionan
set "POS_ARGS="
if not "%WIN_X%"=="" set "POS_ARGS=--window-x %WIN_X%"
if not "%WIN_Y%"=="" set "POS_ARGS=%POS_ARGS% --window-y %WIN_Y%"

echo Iniciando scrcpy para el dispositivo: %DEVICE_IP%
if not "%POS_ARGS%"=="" echo Posicionando ventana en X:%WIN_X% Y:%WIN_Y%

:: Lanza scrcpy con la configuración específica del usuario y modo overlay
start "scrcpy" "C:\Users\franc\AppData\Local\Microsoft\WinGet\Packages\Genymobile.scrcpy_Microsoft.Winget.Source_8wekyb3d8bbwe\scrcpy-win64-v3.3.4\scrcpy.exe" -s %DEVICE_IP% --max-size=1024 --max-fps=30 --always-on-top --window-borderless %POS_ARGS%

:: Lanza el script de AutoHotkey para la transparencia y el click-through
start "" "%~dp0scrcpy-overlay.ahk"

exit
