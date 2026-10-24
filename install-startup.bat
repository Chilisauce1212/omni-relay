@echo off
echo Installing auto-start...
schtasks /create /tn "Qwen-Omni-Relay" /tr "wscript.exe \"%~dp0start-hidden.vbs\"" /sc onlogon /f /rl highest
echo Done. Relay will start silently after each login.
echo Starting now...
wscript.exe "%~dp0start-hidden.vbs"
echo Started (no window, check Task Manager for node.exe).
pause