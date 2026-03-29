services:
  openclaw:
    build: https://github.com/openclaw/openclaw.git#${openclaw_version}
    restart: unless-stopped
    ports:
      - "127.0.0.1:18789:18789"
    volumes:
      - openclaw_data:/home/node/.openclaw
    environment:
      - HOME=/home/node
      - OPENCLAW_GATEWAY_BIND=lan
      - OPENCLAW_GATEWAY_TOKEN=${gateway_token}
    command: ["node", "dist/index.js", "gateway", "--bind", "lan", "--port", "18789", "--allow-unconfigured"]
    init: true
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://127.0.0.1:18789/healthz').then((r)=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 20s

  qdrant:
    image: qdrant/qdrant:${qdrant_version}
    restart: unless-stopped
    ports:
      - "127.0.0.1:6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:6333/readyz"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 10s

  n8n:
    image: n8nio/n8n:${n8n_version}
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    environment:
      - N8N_HOST=${n8n_host}
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://${n8n_host}/
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 15s

%{ if enable_kokoro }
  kokoro:
    image: ghcr.io/remsky/kokoro-fastapi-cpu:${kokoro_version}
    restart: unless-stopped
    ports:
      - "127.0.0.1:8880:8880"
    volumes:
      - kokoro_data:/app/api/src/voices
    environment:
      - PYTHONUNBUFFERED=1
%{ endif }

%{ if enable_piper }
  piper:
    image: lscr.io/linuxserver/piper:${piper_version}
    restart: unless-stopped
    ports:
      - "127.0.0.1:10200:10200"
    volumes:
      - piper_data:/config
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Warsaw
      - PIPER_VOICE=pl_PL-darkman-medium
%{ endif }

%{ if enable_fcm }
  fcm-push:
    image: node:22-alpine
    restart: unless-stopped
    ports:
      - "127.0.0.1:3100:3100"
    volumes:
      - fcm_data:/data
      - ./services/fcm-push/index.js:/app/index.js:ro
    command: ["node", "/app/index.js"]
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3100/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 5s
%{ endif }

volumes:
  openclaw_data:
  qdrant_data:
  n8n_data:
%{ if enable_kokoro }
  kokoro_data:
%{ endif }
%{ if enable_piper }
  piper_data:
%{ endif }
%{ if enable_fcm }
  fcm_data:
%{ endif }
