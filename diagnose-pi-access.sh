#!/bin/bash

echo "========================================="
echo "Pi Network Access Diagnosis"
echo "========================================="

echo "🔍 DIAGNOSING WHY PI SERVER ISN'T ACCESSIBLE..."
echo

# Get Pi IP
PI_IP=$(hostname -I | awk '{print $1}')
echo "Pi IP Address: $PI_IP"
echo

# Check if server is actually running
echo "=== SERVER STATUS ==="
if pgrep -f "node server.js" > /dev/null; then
    echo "✅ Server process is running"
    PID=$(pgrep -f "node server.js")
    echo "   Process ID: $PID"
else
    echo "❌ Server process not found"
    echo "   Start with: node server.js"
    exit 1
fi

# Check what interface the server is bound to
echo
echo "=== SERVER BINDING ==="
if command -v netstat >/dev/null 2>&1; then
    BINDING=$(netstat -tulpn 2>/dev/null | grep ":3000")
    if [ -n "$BINDING" ]; then
        echo "Server listening on:"
        echo "$BINDING"
        
        if echo "$BINDING" | grep -q "0.0.0.0:3000"; then
            echo "✅ Bound to all interfaces (0.0.0.0) - GOOD"
        elif echo "$BINDING" | grep -q "127.0.0.1:3000"; then
            echo "❌ Bound to localhost only (127.0.0.1) - BAD"
            echo "   This prevents external access!"
        elif echo "$BINDING" | grep -q ":::3000"; then
            echo "✅ Bound to IPv6 all interfaces - GOOD"
        fi
    else
        echo "❌ No process listening on port 3000"
    fi
else
    echo "netstat not available"
fi

# Test local connectivity
echo
echo "=== LOCAL CONNECTIVITY TEST ==="
if command -v curl >/dev/null 2>&1; then
    # Test localhost
    LOCAL_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
    if [ "$LOCAL_RESPONSE" = "200" ]; then
        echo "✅ localhost:3000 responds (HTTP $LOCAL_RESPONSE)"
    else
        echo "❌ localhost:3000 not responding (HTTP $LOCAL_RESPONSE)"
    fi
    
    # Test via IP
    IP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$PI_IP:3000 2>/dev/null)
    if [ "$IP_RESPONSE" = "200" ]; then
        echo "✅ $PI_IP:3000 responds (HTTP $IP_RESPONSE)"
    else
        echo "❌ $PI_IP:3000 not responding (HTTP $IP_RESPONSE)"
        echo "   This is likely a firewall issue"
    fi
else
    echo "curl not available for testing"
fi

# Check firewall status
echo
echo "=== FIREWALL STATUS ==="
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null)
    echo "UFW Status:"
    echo "$UFW_STATUS"
    
    if echo "$UFW_STATUS" | grep -q "Status: active"; then
        if echo "$UFW_STATUS" | grep -q "3000"; then
            echo "✅ Port 3000 is allowed in UFW"
        else
            echo "❌ Port 3000 is NOT allowed in UFW"
            echo "   FIX: sudo ufw allow 3000"
        fi
    else
        echo "ℹ️  UFW firewall is inactive"
    fi
else
    echo "UFW not available"
fi

# Check iptables
if command -v iptables >/dev/null 2>&1; then
    echo
    echo "iptables rules for port 3000:"
    sudo iptables -L INPUT -n | grep 3000 || echo "No specific rules for port 3000"
fi

echo
echo "=== IMMEDIATE FIXES ==="
echo
echo "🔧 Try these fixes in order:"
echo

echo "1. FIREWALL FIX (most likely):"
echo "   sudo ufw allow 3000"
echo

echo "2. DISABLE FIREWALL TEMPORARILY:"
echo "   sudo ufw disable"
echo "   # Test if this fixes access, then re-enable with port allowed"
echo

echo "3. CHECK SERVER BINDING:"
echo "   grep -n 'HOST.*=' server.js"
echo "   # Should show: const HOST = '0.0.0.0';"
echo

echo "4. RESTART SERVER:"
echo "   pkill -f 'node server.js'"
echo "   node server.js"
echo

echo "5. TRY DIFFERENT PORT:"
echo "   PORT=8080 node server.js"
echo "   # Then test: http://$PI_IP:8080"
echo

echo
echo "=== NETWORK INFO ==="
echo "Your Pi network details:"
echo "IP: $PI_IP"
echo "Test URLs:"
echo "  From Pi: http://localhost:3000"
echo "  From other devices: http://$PI_IP:3000"
echo

echo "=== NEXT STEPS ==="
echo "1. Try: sudo ufw allow 3000"
echo "2. Test from another device: http://$PI_IP:3000"
echo "3. If still fails, try: sudo ufw disable"
echo "4. Test again"
echo "5. If it works, re-enable UFW: sudo ufw enable"
echo
echo "========================================="
