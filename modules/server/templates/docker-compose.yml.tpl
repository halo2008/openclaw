services:
  openclaw:
    build: https://github.com/openclaw/openclaw.git
    restart: unless-stopped
    ports:
      - "127.0.0.1:18789:18789"
    volumes:
      - openclaw_data:/home/node/.openclaw
    environment:
      - HOME=/home/node
      - OPENCLAW_GATEWAY_BIND=lan
    command: ["node", "dist/index.js", "gateway", "--bind", "lan", "--port", "18789", "--allow-unconfigured"]
    init: true
    healthcheck:
      test: ["CMD", "node", "-e", "fetch('http://127.0.0.1:18789/healthz').then((r)=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 20s

  qdrant:
    image: qdrant/qdrant:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage

  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    environment:
      - N8N_HOST=${n8n_host}
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://${n8n_host}/

%{ if enable_kokoro }
  kokoro:
    image: ghcr.io/remsky/kokoro-fastapi-cpu:latest
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
    image: lscr.io/linuxserver/piper:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:10200:10200"
    volumes:
      - piper_data:/config
    environment:
      - PIPER_VOICE=pl_PL-gosia-medium
      - PIPER_LENGTH=1.0
      - PIPER_NOISE=0.667
      - PIPER_NOISEW=0.333
      - PIPER_SPEAKER=0
      - PIPER_PROCS=1
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
