@echo off
echo === Qwen Omni Relay Installer ===
echo.
echo This adds the relay to Windows startup.
echo The relay runs minimized on taskbar.
echo To uninstall, run: uninstall-startup.bat
echo.
pause
set DIR=%~dp0
powershell -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Startup')+'\Qwen-Omni-Relay.lnk');$s.TargetPath='wscript.exe';$s.Arguments='\"'+$env:DIR+'start-min.vbs\"';$s.WorkingDirectory=$env:DIR;$s.Save()"
echo.
echo Installed. Starting now...
start "" wscript.exe "%~dp0start-min.vbs"
echo Done.
pause