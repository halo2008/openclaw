{
  "agents": {
    "defaults": {
      "model": "${default_model}"
    }
  },
  "models": {
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com/v1",
        "apiKey": "${deepseek_api_key}",
        "api": "openai-completions",
        "models": [
          {
            "id": "deepseek-chat",
            "name": "DeepSeek V3",
            "input": ["text"],
            "contextWindow": 65536
          },
          {
            "id": "deepseek-reasoner",
            "name": "DeepSeek R1",
            "reasoning": true,
            "input": ["text"],
            "contextWindow": 65536
          }
        ]
      },
      "google": {
        "baseUrl": "https://generativelanguage.googleapis.com/v1beta",
        "apiKey": "${google_api_key}",
        "api": "google-generative-ai",
        "models": [
          {
            "id": "gemini-2.0-flash-exp",
            "name": "Gemini 2.0 Flash Experimental",
            "input": ["text"],
            "contextWindow": 1048576
          }
        ]
      }
    }
  },
  "messages": {
    "tts": {
      "auto": "always",
      "provider": "openai",
      "openai": {
        "baseUrl": "http://kokoro:8880/v1",
        "apiKey": "not-needed",
        "model": "kokoro",
        "voice": "af_heart"
      },
      "edge": {
        "voice": "pl-PL-ZofiaNeural",
        "lang": "pl-PL"
      }
    }
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true,
    "ownerDisplay": "raw"
  },
  "talk": {
    "provider": "microsoft",
    "providers": {
      "openai": {
        "voiceId": "af_heart",
        "outputFormat": "mp3",
        "baseUrl": "http://kokoro:8880/v1",
        "apiKey": "not-needed",
        "modelId": "kokoro"
      },
      "microsoft": {
        "voiceId": "pl-PL-ZofiaNeural"
      }
    }
  },
  "cron": {
    "enabled": ${enable_cron},
    "sessionRetention": "24h"
  },
  "gateway": {
    "mode": "local",
    "controlUi": {
      "allowedOrigins": [
        "https://${domain}"
      ]
    },
    "auth": {
      "mode": "trusted-proxy",
      "trustedProxy": {
        "userHeader": "cf-connecting-ip",
        "requiredHeaders": [
          "cf-connecting-ip"
        ]
      }
    },
    "trustedProxies": [
      "172.16.0.0/12",
      "10.0.0.0/8"
    ]
  }
}
