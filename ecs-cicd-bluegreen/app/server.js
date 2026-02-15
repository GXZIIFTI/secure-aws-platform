const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || "dev";

// basic request logging to stdout (good for CloudWatch)
app.use((req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    const ms = Date.now() - start;
    console.log(
      JSON.stringify({
        ts: new Date().toISOString(),
        method: req.method,
        path: req.originalUrl || req.url,
        status: res.statusCode,
        latency_ms: ms,
        version: VERSION,
      })
    );
  });
  next();
});

app.get("/", (req, res) => {
  res.send("Secure AWS Platform is live!!!");
});

app.get("/health", (req, res) => {
  res.status(500).json({ status: "unhealthy" });
});

app.get("/version", (req, res) => {
  res.status(200).json({ version: VERSION });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`server_started port=${PORT} version=${VERSION}`);
});
