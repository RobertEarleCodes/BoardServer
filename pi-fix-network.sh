#!/bin/bash

echo "========================================="
echo "Pi Network Troubleshooting & Fix"
echo "========================================="

PI_IP=$(hostname -I | awk '{print $1}')
echo "Pi IP: $PI_IP"

# 1. Kill any existing server processes
echo "🔄 Stopping existing servers..."
sudo pkill -f "node.*server.js" 2>/dev/null || true
sleep 2

# 2. Configure firewall
echo "🔥 Configuring firewall..."
if command -v ufw >/dev/null 2>&1; then
    sudo ufw --force enable
    sudo ufw allow 3000/tcp
    sudo ufw allow ssh
    echo "✅ UFW configured"
    sudo ufw status
else
    # Configure iptables directly
    sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
    sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    echo "✅ iptables configured"
fi

# 3. Test port binding
echo "🧪 Testing network configuration..."

# Start server in background for testing
echo "Starting server for network test..."
PORT=3000 node server.js &
SERVER_PID=$!
sleep 3

# Test local connectivity
echo "Testing localhost..."
if curl -s http://localhost:3000 >/dev/null; then
    echo "✅ localhost:3000 - OK"
else
    echo "❌ localhost:3000 - FAILED"
fi

# Test LAN connectivity
echo "Testing LAN access..."
if curl -s http://$PI_IP:3000 >/dev/null; then
    echo "✅ $PI_IP:3000 - OK"
    echo "🎉 LAN access should work from other devices!"
else
    echo "❌ $PI_IP:3000 - FAILED"
    echo "🔧 Network binding issue detected"
fi

# Stop test server
kill $SERVER_PID 2>/dev/null || true

# 4. Network diagnostic
echo
echo "🔍 Network Diagnostic:"
echo "Listening ports:"
netstat -tulpn | grep :3000 || echo "No process on port 3000"

echo
echo "Network interfaces:"
ip addr show | grep -E "(inet |UP)"

echo
echo "========================================="
echo "🚀 Manual Test:"
echo "1. Start server: node server.js"
echo "2. Test from another device: http://$PI_IP:3000"
echo "========================================="
