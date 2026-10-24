' Qwen Omni Relay - 无窗口后台启动
' 双击此文件，中继在后台静默运行。
CreateObject("Wscript.Shell").Run "cmd /c cd /d %~dp0 && node ecs-relay.js > relay.log 2>&1", 0, False