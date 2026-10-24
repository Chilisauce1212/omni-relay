@echo off
setlocal enabledelayedexpansion

:: Check for admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator rights...
    echo After clicking Yes, this window will reopen as admin.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ==========================================
echo   Qwen Omni Relay - Service Installer
echo ==========================================
echo.

echo [1/4] Looking for Node.js...

:: Try to find node via direct version check first
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js not found or not in PATH.
    echo Please install Node.js from https://nodejs.org
    echo After installing, re-run this installer.
    pause
    exit /b 1
)

:: Get full path to node.exe
for /f "tokens=*" %%i in ('node -e "console.log(process.execPath)" 2^>nul') do set NODE=%%i
echo        Found: %NODE%

echo [2/3] Registering Windows service (Task Scheduler)...
set PSFILE=%TEMP%\qwen-relay-install.ps1
(
echo $action=New-ScheduledTaskAction -Execute '%NODE%' -Argument 'ecs-relay.js' -WorkingDirectory '%~dp0'
echo $trigger=New-ScheduledTaskTrigger -AtStartup
echo $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit (New-TimeSpan -Days 365) -Hidden
echo $principal=New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest
echo Register-ScheduledTask -TaskName 'QwenOmniRelay' -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force
) > "%PSFILE%"

powershell -ExecutionPolicy Bypass -File "%PSFILE%"
set ERR=%errorlevel%
del "%PSFILE%"

if %ERR% neq 0 (
    echo ERROR: Failed to register service.
    pause
    exit /b 1
)
echo        Done.

echo [3/3] Starting relay now...
schtasks /run /tn "QwenOmniRelay"
if %errorlevel% neq 0 (
    echo WARNING: Could not start service immediately.
    echo It will start automatically on next reboot.
) else (
    echo        Started.
)

echo.
echo ==========================================
echo   INSTALL SUCCESS
echo.
echo   Relay runs as a Windows service:
echo   - Auto-starts on every boot
echo   - Auto-restarts if killed
echo   - No windows, no taskbar
echo.
echo   To check status:
echo     taskschd.msc ^> QwenOmniRelay
echo   To uninstall:
echo     Right-click uninstall-service.bat ^> Run as admin
echo ==========================================
pause