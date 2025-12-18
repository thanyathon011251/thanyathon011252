<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>ESP32 GPIO2 Control</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { 
      font-family: Arial, sans-serif; 
      text-align: center; 
      margin-top: 50px; 
      background: #f0f0f0; 
    }
    .container { 
      display: inline-block; 
      padding: 30px; 
      background: white; 
      border-radius: 15px; 
      box-shadow: 0 4px 10px rgba(0,0,0,0.1); 
    }
    button { 
      padding: 20px 40px; 
      margin: 10px; 
      font-size: 18px; 
      border: none; 
      border-radius: 10px; 
      cursor: pointer; 
      transition: 0.3s; 
    }
    .on { background: #4CAF50; color: white; }
    .off { background: #f44336; color: white; }
    .status { 
      margin-top: 20px; 
      font-size: 24px; 
      font-weight: bold; 
    }
  </style>
</head>
<body>

<div class="container">
  <h1>ESP32 GPIO2 Control</h1>
  <button id="btnOn" class="on">ON</button>
  <button id="btnOff" class="off">OFF</button>
  <div class="status" id="status">Connecting...</div>
</div>

<!-- MQTT.js -->
<script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>
<script>
  // Topic ตรงกับ ESP32
  const TOPIC_CMD = "oonoun";
  const TOPIC_STATUS = "oonoun";

  const clientId = 'web_' + Math.random().toString(16).substr(2, 8);

  // HiveMQ Public Broker - wss:// + port 8884 + path /mqtt
  const client = mqtt.connect('wss://broker.hivemq.com:8884/mqtt', {
    clientId: clientId,
    keepalive: 60,
    reconnectPeriod: 1000,
    connectTimeout: 30 * 1000
  });

  let currentState = null;
  const statusEl = document.getElementById('status');

  client.on('connect', () => {
    console.log('Connected to HiveMQ!');
    client.subscribe(TOPIC_STATUS);
    statusEl.textContent = 'Connected';
    statusEl.style.color = 'blue';

    // ขอสถานะทันที
    client.publish(TOPIC_CMD, 'status');
  });

  client.on('message', (topic, message) => {
    const msg = message.toString().trim();
    console.log('Received:', topic, msg);

    if (msg === '1') currentState = true;
    else if (msg === '0') currentState = false;

    updateUI();
  });

  client.on('error', (err) => {
    console.error('MQTT Error:', err);
    statusEl.textContent = 'Error!';
    statusEl.style.color = 'red';
  });

  client.on('offline', () => {
    statusEl.textContent = 'Offline';
    statusEl.style.color = 'orange';
  });

  // ปุ่ม
  document.getElementById('btnOn').onclick = () => send('1');
  document.getElementById('btnOff').onclick = () => send('0');

  function send(cmd) {
    if (client.connected) {
      client.publish(TOPIC_CMD, cmd);
      statusEl.textContent = 'Sending...';
    } else {
      statusEl.textContent = 'Not Connected!';
    }
  }

  function updateUI() {
    if (currentState === true) {
      document.getElementById('btnOn').style.opacity = '1';
      document.getElementById('btnOff').style.opacity = '0.6';
      statusEl.textContent = 'LED: ON';
      statusEl.style.color = 'green';
    } else if (currentState === false) {
      document.getElementById('btnOn').style.opacity = '0.6';
      document.getElementById('btnOff').style.opacity = '1';
      statusEl.textContent = 'LED: OFF';
      statusEl.style.color = 'red';
    }
  }
</script>

</body>
</html>
