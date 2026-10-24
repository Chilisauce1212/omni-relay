' Qwen Omni Relay - 最小化到任务栏
Dim scriptDir
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
CreateObject("Wscript.Shell").Run "cmd /c title Qwen Omni Relay & cd /d """ & scriptDir & """ & node ecs-relay.js", 7, False