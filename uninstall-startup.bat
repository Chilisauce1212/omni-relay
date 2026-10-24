@echo off
echo Removing auto-start...
schtasks /delete /tn "Qwen-Omni-Relay" /f 2>nul
taskkill /f /im node.exe 2>nul
echo Done. Relay removed from startup.
pause