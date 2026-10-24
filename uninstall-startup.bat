@echo off
echo Removing auto-start...
del /f "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Qwen-Omni-Relay.lnk" 2>nul
taskkill /f /im node.exe 2>nul
echo Done.
pause