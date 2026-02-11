const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Secure AWS Platform is live!!!");
});

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

app.listen(3000, () => {
  console.log("App running on port 3000");
});