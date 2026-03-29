const http = require("http");
const fs = require("fs");
const crypto = require("crypto");

const SA_PATH = process.env.FIREBASE_SA_PATH || "/data/firebase-sa.json";
const TOKENS_FILE = process.env.TOKENS_FILE || "/data/fcm-tokens.json";
const PORT = parseInt(process.env.PORT || "3100", 10);

const SA = JSON.parse(fs.readFileSync(SA_PATH, "utf-8"));

function loadTokens() {
  try { return JSON.parse(fs.readFileSync(TOKENS_FILE, "utf-8")); } catch(e) { return {}; }
}
function saveTokens(t) { fs.writeFileSync(TOKENS_FILE, JSON.stringify(t, null, 2)); }

async function getAccessToken() {
  const now = Math.floor(Date.now() / 1000);
  const header = Buffer.from(JSON.stringify({ alg: "RS256", typ: "JWT" })).toString("base64url");
  const payload = Buffer.from(JSON.stringify({
    iss: SA.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: SA.token_uri, iat: now, exp: now + 3600
  })).toString("base64url");
  const sig = crypto.createSign("RSA-SHA256").update(header + "." + payload).sign(SA.private_key, "base64url");
  const jwt = header + "." + payload + "." + sig;

  const res = await fetch(SA.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=" + jwt
  });
  return (await res.json()).access_token;
}

async function sendPush(fcmToken, data) {
  const token = await getAccessToken();
  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${SA.project_id}/messages:send`, {
    method: "POST",
    headers: { Authorization: "Bearer " + token, "Content-Type": "application/json" },
    body: JSON.stringify({ message: { token: fcmToken, data, android: { priority: "high" } } })
  });
  return await res.json();
}

const server = http.createServer(async (req, res) => {
  let body = "";
  req.on("data", c => body += c);
  req.on("end", async () => {
    res.setHeader("Content-Type", "application/json");
    try {
      const data = body ? JSON.parse(body) : {};

      if (req.url === "/register" && req.method === "POST") {
        const tokens = loadTokens();
        tokens[data.deviceId || "default"] = { fcmToken: data.fcmToken, updatedAt: new Date().toISOString() };
        saveTokens(tokens);
        res.end(JSON.stringify({ success: true, devices: Object.keys(tokens).length }));

      } else if (req.url === "/push" && req.method === "POST") {
        const tokens = loadTokens();
        const results = [];
        for (const [id, info] of Object.entries(tokens)) {
          try {
            const r = await sendPush(info.fcmToken, {
              type: data.type || "news",
              title: data.title || "ClawAPK",
              body: data.body || "",
              ttsMessage: data.ttsMessage || ""
            });
            results.push({ deviceId: id, success: !r.error, response: r });
          } catch(e) { results.push({ deviceId: id, success: false, error: e.message }); }
        }
        res.end(JSON.stringify({ sent: results.length, results }));

      } else if (req.url === "/health") {
        res.end(JSON.stringify({ ok: true }));

      } else {
        res.statusCode = 404;
        res.end(JSON.stringify({ error: "not found" }));
      }
    } catch(e) {
      res.statusCode = 500;
      res.end(JSON.stringify({ error: e.message }));
    }
  });
});

server.listen(PORT, "0.0.0.0", () => console.log(`FCM push service listening on :${PORT}`));
