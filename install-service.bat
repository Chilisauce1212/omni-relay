@echo off
:: Auto-elevate to admin if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo === Qwen Omni Relay Service Installer ===
echo.

:: Find Node.js
for /f "tokens=*" %%i in ('where node 2^>nul') do set NODE=%%i
if "%NODE%"=="" (
    echo ERROR: Node.js not found. Install from https://nodejs.org
    pause
    exit /b 1
)
echo Node.js found: %NODE%

:: Write PowerShell install script to temp file
set PSFILE=%TEMP%\qwen-relay-install.ps1
(
echo $action=New-ScheduledTaskAction -Execute '%NODE%' -Argument 'ecs-relay.js' -WorkingDirectory '%~dp0'
echo $trigger=New-ScheduledTaskTrigger -AtStartup
echo $settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit (New-TimeSpan -Days 365) -Hidden
echo $principal=New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest
echo Register-ScheduledTask -TaskName 'QwenOmniRelay' -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force
) > "%PSFILE%"

powershell -ExecutionPolicy Bypass -File "%PSFILE%"
del "%PSFILE%"

if %errorlevel% neq 0 (
    echo ERROR: Failed to register service.
    pause
    exit /b 1
)

:: Start immediately
echo Starting relay service...
schtasks /run /tn "QwenOmniRelay"

echo.
echo ==========================================
echo  INSTALLED: Qwen Omni Relay Service
echo  - Starts on boot, no login needed
echo  - Auto-restarts if killed
echo  - Zero windows, runs silently
echo  Uninstall: run uninstall-service.bat
echo ==========================================
pause