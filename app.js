const express = require("express");
const app = express();

const path = require("path");

app.use(express.static("public"));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "views", "index.html"));
});

// INTENTIONALLY VULNERABLE ENDPOINT (we will document later)
app.get("/debug", (req, res) => {
  res.json({
    env: process.env,
    message: "Debug mode enabled"
  });
});

module.exports = app;
