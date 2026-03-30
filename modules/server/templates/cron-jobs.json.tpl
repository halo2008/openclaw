{
  "version": 1,
  "jobs": [
%{ for i, job in cron_jobs ~}
    {
      "id": "${job.id}",
      "name": "${job.name}",
      "enabled": true,
      "schedule": {
        "kind": "cron",
        "expr": "${job.schedule_expr}",
        "tz": "${job.schedule_tz}"
      },
      "sessionTarget": "isolated",
      "wakeMode": "next-heartbeat",
      "payload": {
        "kind": "agentTurn",
        "message": "${replace(replace(job.message, "\"", "\\\""), "\n", "\\n")}",
        "lightContext": true
      },
      "delivery": {
        "mode": "none"
      },
      "deleteAfterRun": false
    }%{ if i < length(cron_jobs) - 1 },%{ endif }
%{ endfor ~}
  ]
}
