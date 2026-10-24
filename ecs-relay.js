// Qwen-Omni 中继（ECS 版，支持 URL 参数）
// 客户端：ws://IP:8765/?apikey=xxx&workspace=xxx&model=xxx
// 参数可选——不传则用 config.json 兜底

const { WebSocketServer, WebSocket } = require('ws');
const fs = require('fs');

const PORT = process.env.PORT || 8765;

// 读取本地兜底配置
let fallback = { apiKey: '', workspaceId: '' };
try {
  const cfg = JSON.parse(fs.readFileSync('config.json', 'utf8'));
  fallback = { apiKey: cfg.apiKey || '', workspaceId: cfg.workspaceId || '' };
} catch (_) {}

const wss = new WebSocketServer({ port: PORT }, () => {
  console.log(`[relay] ECS 中继已启动，端口 ${PORT}`);
});

wss.on('connection', (clientWs, req) => {
  const url = new URL(req.url || '/', 'http://localhost');
  const apiKey = url.searchParams.get('apikey') || fallback.apiKey;
  const workspaceId = url.searchParams.get('workspace') || fallback.workspaceId;
  const model = url.searchParams.get('model') || 'qwen3.8-omni-flash-realtime';

  if (!apiKey || !workspaceId) {
    console.error('[relay] 缺少 apikey 或 workspace');
    clientWs.close(4001, 'Missing apikey or workspace');
    return;
  }

  console.log(`[relay] 新连接 → ${workspaceId.slice(0, 10)}...`);

  const upstreamUrl = `wss://${workspaceId}.cn-beijing.maas.aliyuncs.com/api-ws/v1/realtime?model=${encodeURIComponent(model)}`;
  const upstream = new WebSocket(upstreamUrl, {
    headers: {
      'Authorization': `Bearer ${apiKey}`,
      'X-DashScope-WorkSpace': workspaceId
    }
  });

  const pending = [];

  upstream.on('open', () => {
    for (const { data, isBinary } of pending) upstream.send(data, { binary: isBinary });
    pending.length = 0;
  });

  upstream.on('message', (data, isBinary) => {
    if (clientWs.readyState === WebSocket.OPEN) clientWs.send(data, { binary: isBinary });
  });

  upstream.on('error', (e) => {
    console.error('[relay] 上游错误:', e.message);
    if (clientWs.readyState === WebSocket.OPEN) clientWs.close(4002, e.message);
  });

  upstream.on('close', (code, reason) => {
    if (clientWs.readyState === WebSocket.OPEN) clientWs.close(code || 1000, reason);
  });

  clientWs.on('message', (data, isBinary) => {
    if (upstream.readyState === WebSocket.OPEN) {
      upstream.send(data, { binary: isBinary });
    } else {
      pending.push({ data, isBinary });
    }
  });

  clientWs.on('close', (code, reason) => {
    if (upstream.readyState === WebSocket.OPEN) upstream.close(code || 1000, reason);
  });

  clientWs.on('error', (e) => {
    if (upstream.readyState === WebSocket.OPEN) upstream.close(4000);
  });
});