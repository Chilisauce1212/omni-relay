# Qwen Omni Relay

本地 WebSocket 中继——配合 [Qwen 实时语音助手 Chrome 扩展](https://github.com/Chilisauce1212/omni-relay) 使用，为浏览器扩展提供百炼鉴权转发。

## 为什么需要它

浏览器 WebSocket 不支持自定义请求头，百炼 Qwen-Omni 的鉴权必须通过 `Authorization` 头。这个中继跑在本地（127.0.0.1），替浏览器完成鉴权转发。

## 使用方法

### Windows

1. 下载 `omni-relay-win.zip`（[Releases](https://github.com/Chilisauce1212/omni-relay/releases)）
2. 解压到任意目录
3. 双击 `start.bat`
4. 保持窗口打开，然后在 Chrome 扩展里填 API Key 即可对话

### macOS / Linux

```bash
git clone https://github.com/Chilisauce1212/omni-relay.git
cd omni-relay
npm install
node ecs-relay.js
```

## 技术要求

- Node.js 18+ ([下载](https://nodejs.org))

## 原理

```
Chrome 扩展（ws://127.0.0.1:8765）
        │
        ▼
  本地中继（127.0.0.1:8765）
        │  wss://百炼 + Authorization Header
        ▼
  Qwen-Omni API
```

中继不解析、不存储任何语音数据——纯透明转发。