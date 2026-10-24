// Qwen-Omni / Gemini Live 通用中继
// 客户端：ws://127.0.0.1:8765/?apikey=xxx&base_url=wss://...&model=xxx
// base_url: 完整的 WebSocket 上游地址（不含 ?model=）
// apikey: 鉴权用，作为 Authorization: Bearer 头

const { WebSocketServer, WebSocket } = require('ws');
const fs = require('fs');

const PORT = process.env.PORT || 8765;

// 兜底配置
let fallbackKey = '', fallbackUrl = '';
try {
  const cfg = JSON.parse(fs.readFileSync('config.json', 'utf8'));
  fallbackKey = cfg.apiKey || '';
  fallbackUrl = cfg.baseUrl || '';
} catch (_) {}

const wss = new WebSocketServer({ port: PORT }, () => {
  console.log(`[relay] 中继已启动，端口 ${PORT}`);
});

wss.on('connection', (clientWs, req) => {
  const url = new URL(req.url || '/', 'http://localhost');

  let apikey = url.searchParams.get('apikey') || fallbackKey;
  let baseUrl = url.searchParams.get('base_url') || fallbackUrl;

  // 兼容旧版 workspace 参数：自动拼成百炼地址
  const wsId = url.searchParams.get('workspace');
  if (!baseUrl && wsId) {
    baseUrl = `wss://${wsId}.cn-beijing.maas.aliyuncs.com/api-ws/v1/realtime`;
  }

  const model = url.searchParams.get('model') || 'qwen3.8-omni-flash-realtime';

  if (!apikey || !baseUrl) {
    console.error('[relay] 缺少 apikey 或 base_url');
    clientWs.close(4001, 'Missing apikey or base_url');
    return;
  }

  const upstreamUrl = baseUrl + '?model=' + encodeURIComponent(model);

  // 从 hostname 提取 workspace（百炼需要 X-DashScope-WorkSpace 头）
  let workspaceId = '';
  try {
    const hostname = new URL(baseUrl).hostname;
    const m = hostname.match(/^(ws-[^.]+)\./);
    if (m) workspaceId = m[1];
  } catch (_) {}

  const extraHeaders = {};
  if (workspaceId) extraHeaders['X-DashScope-WorkSpace'] = workspaceId;

  console.log(`[relay] → ${upstreamUrl.slice(0, 80)}...`);

  const upstream = new WebSocket(upstreamUrl, {
    headers: { 'Authorization': `Bearer ${apikey}`, ...extraHeaders }
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