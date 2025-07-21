#!/bin/bash

# Network Diagnostic Script for BoardServer Global Access
echo "🔍 BoardServer Network Diagnostic"
echo "================================="

echo ""
echo "📍 CURRENT NETWORK STATUS:"
echo ""

# Check if server is running
if pgrep -f "node.*server.js" > /dev/null; then
    echo "✅ Server Status: RUNNING"
    SERVER_PID=$(pgrep -f "node.*server.js")
    echo "   Process ID: $SERVER_PID"
else
    echo "❌ Server Status: NOT RUNNING"
    echo "   Start with: npm run start:global"
fi

echo ""
echo "🌐 NETWORK INFORMATION:"

# Local IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "   🏠 Local IP: $LOCAL_IP"

# Public IP address
echo "   🌍 Checking public IP..."
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "Unable to fetch")
echo "   🌍 Public IP: $PUBLIC_IP"

echo ""
echo "🔌 PORT STATUS:"

# Check if port 3000 is listening
if ss -tlnp | grep -q ":3000"; then
    echo "✅ Port 3000: LISTENING"
    ss -tlnp | grep ":3000"
else
    echo "❌ Port 3000: NOT LISTENING"
fi

echo ""
echo "🛡️  FIREWALL STATUS:"

# Check UFW status
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null | head -1)
    echo "   UFW: $UFW_STATUS"
    
    if sudo ufw status 2>/dev/null | grep -q "3000"; then
        echo "✅ Port 3000: ALLOWED in firewall"
    else
        echo "⚠️  Port 3000: NOT EXPLICITLY ALLOWED"
        echo "   Run: sudo ufw allow 3000"
    fi
else
    echo "   UFW: Not installed"
    
    # Check iptables instead
    if command -v iptables >/dev/null 2>&1; then
        echo "   Using iptables instead"
        if sudo iptables -L INPUT 2>/dev/null | grep -q "3000"; then
            echo "✅ Port 3000: Found in iptables rules"
        else
            echo "⚠️  Port 3000: Not found in iptables rules"
            echo "   Install UFW: sudo apt install ufw"
            echo "   Or configure iptables manually"
        fi
    else
        echo "   No common firewall tools found"
        echo "   Install UFW: sudo apt install ufw"
    fi
fi

echo ""
echo "🔗 ACCESS URLS:"
echo "   🏠 Local: http://localhost:3000"
echo "   🏠 LAN: http://$LOCAL_IP:3000"
if [ "$PUBLIC_IP" != "Unable to fetch" ]; then
    echo "   🌍 Global: http://$PUBLIC_IP:3000"
    echo ""
    echo "⚠️  NOTE: Global access requires router port forwarding!"
fi

echo ""
echo "🧪 QUICK TESTS:"
echo ""

# Test local connection
echo "Testing local connection..."
if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Local connection: SUCCESS"
else
    echo "❌ Local connection: FAILED"
fi

# Test LAN connection
echo "Testing LAN connection..."
if curl -s http://$LOCAL_IP:3000 >/dev/null 2>&1; then
    echo "✅ LAN connection: SUCCESS"
else
    echo "❌ LAN connection: FAILED"
fi

echo ""
echo "📋 NEXT STEPS FOR GLOBAL ACCESS:"
echo "1. Ensure server is running: npm run start:global"
echo "2. Configure router port forwarding: 3000 → $LOCAL_IP:3000"
echo "3. Allow firewall: sudo ufw allow 3000"
echo "4. Test global access: http://$PUBLIC_IP:3000"
