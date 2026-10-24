@echo off
echo ?????????...
powershell -Command " = New-Object -ComObject WScript.Shell;  = .CreateShortcut([Environment]::GetFolderPath('Startup') + '\Qwen-Omni-Relay.lnk'); .TargetPath = '%~dp0start.bat'; .WorkingDirectory = '%~dp0'; .WindowStyle = 7; .Save()"
echo ??????????????
echo ??????...
start /min "" "%~dp0start.bat"
pause
