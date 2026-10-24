' Qwen Omni Relay - 最小化启动（任务栏可见，右键可关闭）
CreateObject("Wscript.Shell").Run "cmd /c title Qwen Omni Relay ^& cd /d %~dp0 ^& node ecs-relay.js ^& pause", 7, False