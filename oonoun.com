<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>ESP32 LED Control</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body {
      font-family: Arial;
      text-align: center;
      margin-top: 50px;
      background: #f0f0f0;
    }
    .box {
      background: white;
      padding: 30px;
      border-radius: 15px;
      display: inline-block;
    }
    button {
      padding: 20px 40px;
      font-size: 20px;
      margin: 10px;
      border-radius: 10px;
      border: none;
      cursor: pointer;
    }
    .on { background: green; color: white; }
    .off { background: red; color: white; }
  </style>
</head>
<body>

<div class="box">
  <h1>ESP32 LED</h1>
  <button class="on" onclick="send('1')">ON</button>
  <button class="off" onclick="send('0')">OFF</button>
  <p id="status">Connecting...</p>
</div>

<script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>
<script>
  const TOPIC = "oonoun";

  const client = mqtt.connect(
    "wss://broker.hivemq.com:8884/mqtt",
    { clientId: "web_" + Math.random().toString(16).substr(2, 8) }
  );

  const statusEl = document.getElementById("status");

  client.on("connect", () => {
    statusEl.innerText = "Connected";
  });

  function send(msg) {
    if (client.connected) {
      client.publish(TOPIC, msg);
      statusEl.innerText = "Send: " + msg;
    } else {
      statusEl.innerText = "Not connected";
    }
  }
</script>

</body>
</html>
