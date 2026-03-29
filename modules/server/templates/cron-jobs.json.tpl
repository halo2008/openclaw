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
      "sessionTarget": "main",
      "wakeMode": "now",
      "payload": {
        "kind": "systemEvent",
        "text": "${replace(job.message, "\"", "\\\"")}"
      },
      "deleteAfterRun": false
    }%{ if i < length(cron_jobs) - 1 },%{ endif }
%{ endfor ~}
  ]
}
