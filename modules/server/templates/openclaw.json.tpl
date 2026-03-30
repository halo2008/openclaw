{
  "agents": {
    "defaults": {
      "model": {
        "primary": "${default_model}",
        "fallbacks": [
          "google2/gemini-3.1-flash-lite-preview",
          "sambanova/Meta-Llama-3.3-70B-Instruct",
          "groq/llama-3.3-70b-versatile",
          "cerebras/qwen-3-235b-a22b-instruct-2507",
          "groq/llama-3.1-8b-instant",
          "sambanova/DeepSeek-R1",
          "cerebras/llama3.1-8b",
          "deepseek/deepseek-chat"
        ]
      },
      "memorySearch": {
        "enabled": true,
        "provider": "gemini"
      }
    }
  },
  "models": {
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com/v1",
        "apiKey": "__DEEPSEEK_API_KEY__",
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
        "apiKey": "__GOOGLE_API_KEY__",
        "api": "google-generative-ai",
        "models": [
          {
            "id": "gemini-3.1-flash-lite-preview",
            "name": "Gemini 3.1 Flash Lite",
            "input": ["text"],
            "contextWindow": 1048576
          }
        ]
      },
      "google2": {
        "baseUrl": "https://generativelanguage.googleapis.com/v1beta",
        "apiKey": "__GOOGLE_API_KEY_2__",
        "api": "google-generative-ai",
        "models": [
          {
            "id": "gemini-3.1-flash-lite-preview",
            "name": "Gemini 3.1 Flash Lite (backup)",
            "input": ["text"],
            "contextWindow": 1048576
          }
        ]
      },
      "groq": {
        "baseUrl": "https://api.groq.com/openai/v1",
        "apiKey": "__GROQ_API_KEY__",
        "api": "openai-completions",
        "models": [
          {
            "id": "llama-3.3-70b-versatile",
            "name": "Llama 3.3 70B (Groq)",
            "input": ["text"],
            "contextWindow": 131072
          },
          {
            "id": "llama-3.1-8b-instant",
            "name": "Llama 3.1 8B Instant (Groq)",
            "input": ["text"],
            "contextWindow": 131072
          }
        ]
      },
      "sambanova": {
        "baseUrl": "https://api.sambanova.ai/v1",
        "apiKey": "__SAMBANOVA_API_KEY__",
        "api": "openai-completions",
        "models": [
          {
            "id": "Meta-Llama-3.3-70B-Instruct",
            "name": "Llama 3.3 70B (SambaNova)",
            "input": ["text"],
            "contextWindow": 131072
          },
          {
            "id": "DeepSeek-R1",
            "name": "DeepSeek R1 (SambaNova)",
            "reasoning": true,
            "input": ["text"],
            "contextWindow": 131072
          }
        ]
      },
      "cerebras": {
        "baseUrl": "https://api.cerebras.ai/v1",
        "apiKey": "__CEREBRAS_API_KEY__",
        "api": "openai-completions",
        "models": [
          {
            "id": "qwen-3-235b-a22b-instruct-2507",
            "name": "Qwen 3 235B (Cerebras)",
            "input": ["text"],
            "contextWindow": 131072
          },
          {
            "id": "llama3.1-8b",
            "name": "Llama 3.1 8B (Cerebras)",
            "input": ["text"],
            "contextWindow": 131072
          }
        ]
      }
    }
  },
  "messages": {
    "tts": {
      "auto": "off"
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
      "mode": "token"
    },
    "trustedProxies": [
      "172.16.0.0/12",
      "10.0.0.0/8"
    ]
  }
}
