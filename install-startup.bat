@echo off
echo Installing auto-start (no admin needed)...
powershell -Command "$WScriptShell = New-Object -ComObject WScript.Shell; $Shortcut = $WScriptShell.CreateShortcut([Environment]::GetFolderPath('Startup') + '\Qwen-Omni-Relay.lnk'); $Shortcut.TargetPath = 'wscript.exe'; $Shortcut.Arguments = '\"%~dp0start-hidden.vbs\"'; $Shortcut.WorkingDirectory = '%~dp0'; $Shortcut.WindowStyle = 7; $Shortcut.Save()"
echo Done. Relay will start silently after each login.
echo Starting now...
wscript.exe "%~dp0start-hidden.vbs"
echo Started (no window). Check Task Manager for node.exe.
pause