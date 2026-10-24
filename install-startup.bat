@echo off
echo ======================================
echo   Qwen Omni Relay - Installer
echo ======================================
echo.
echo This will add the relay to your startup.
echo The relay runs minimized on the taskbar.
echo You can right-click "Qwen Omni Relay" on the taskbar to close it.
echo.
echo For uninstall, run: uninstall-startup.bat
echo.
pause
echo Installing...
powershell -Command "$WScriptShell = New-Object -ComObject WScript.Shell; $Shortcut = $WScriptShell.CreateShortcut([Environment]::GetFolderPath('Startup') + '\Qwen-Omni-Relay.lnk'); $Shortcut.TargetPath = 'wscript.exe'; $Shortcut.Arguments = '\"%~dp0start-min.vbs\"'; $Shortcut.WorkingDirectory = '%~dp0'; $Shortcut.WindowStyle = 7; $Shortcut.Save()"
echo Done. Relay will start minimized after each login.
echo Starting now...
wscript.exe "%~dp0start-min.vbs"
echo.
echo Relay is running (minimized on taskbar).
echo Press any key to close this window.
pause