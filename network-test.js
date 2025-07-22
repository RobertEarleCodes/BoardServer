#!/usr/bin/env node

const http = require('http');
const os = require('os');

// Get local IP address
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const interface of interfaces[name]) {
      if (interface.family === 'IPv4' && !interface.internal) {
        return interface.address;
      }
    }
  }
  return 'localhost';
}

const PORT = 3001; // Use different port to avoid conflicts
const HOST = '0.0.0.0';
const localIP = getLocalIP();

const server = http.createServer((req, res) => {
  const clientIP = req.socket.remoteAddress;
  const timestamp = new Date().toISOString();
  
  console.log(`${timestamp} - Connection from: ${clientIP}`);
  
  res.writeHead(200, { 
    'Content-Type': 'text/html',
    'Access-Control-Allow-Origin': '*'
  });
  
  res.end(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>Network Test Server</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
            .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .success { color: #28a745; font-size: 24px; font-weight: bold; }
            .info { background: #e9ecef; padding: 15px; border-radius: 5px; margin: 20px 0; }
            .code { background: #f8f9fa; border: 1px solid #dee2e6; padding: 10px; border-radius: 3px; font-family: monospace; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="success">✅ Network Connection Successful!</div>
            
            <div class="info">
                <h3>Connection Details:</h3>
                <p><strong>Your IP:</strong> ${clientIP}</p>
                <p><strong>Server IP:</strong> ${localIP}</p>
                <p><strong>Server Port:</strong> ${PORT}</p>
                <p><strong>Time:</strong> ${timestamp}</p>
            </div>
            
            <div class="info">
                <h3>Test Results:</h3>
                <p>✅ Server is accessible from your device</p>
                <p>✅ Network routing is working correctly</p>
                <p>✅ Firewall is properly configured</p>
            </div>
            
            <div class="info">
                <h3>Main Application Access:</h3>
                <p>Your Board Management Server should be accessible at:</p>
                <div class="code">http://${localIP}:3000</div>
            </div>
        </div>
    </body>
    </html>
  `);
});

server.listen(PORT, HOST, () => {
  console.log('='.repeat(60));
  console.log('🧪 Network Test Server Started');
  console.log('='.repeat(60));
  console.log(`🖥️  Server: ${HOST}:${PORT}`);
  console.log('');
  console.log('📱 Test URLs:');
  console.log(`   🏠 Local: http://localhost:${PORT}`);
  console.log(`   🌐 LAN: http://${localIP}:${PORT}`);
  console.log('');
  console.log('🔍 Instructions:');
  console.log('1. Try accessing from this machine first');
  console.log('2. Then try from another device on your network');
  console.log('3. Watch this terminal for connection logs');
  console.log('');
  console.log('Press Ctrl+C to stop');
  console.log('='.repeat(60));
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down test server...');
  server.close(() => {
    console.log('✅ Test server stopped');
    process.exit(0);
  });
});
