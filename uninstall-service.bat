@echo off
:: Auto-elevate to admin if not already
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Removing Qwen Omni Relay service...
schtasks /delete /tn "QwenOmniRelay" /f
taskkill /f /im node.exe 2>nul
echo Done.
pause