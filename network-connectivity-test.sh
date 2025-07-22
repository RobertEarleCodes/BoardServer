#!/bin/bash

echo "========================================="
echo "Network Connectivity Test for Pi Server"
echo "========================================="

# Get the Pi's IP address
PI_IP=$(hostname -I | awk '{print $1}')
PORT=3000

echo "Pi IP Address: $PI_IP"
echo "Testing port: $PORT"
echo

# Function to check command existence
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "=== BASIC CONNECTIVITY ==="
echo "1. Testing if server is listening on the port..."
if command_exists netstat; then
    LISTENING=$(netstat -ln | grep ":$PORT ")
    if [ -n "$LISTENING" ]; then
        echo "✅ Server is listening on port $PORT"
        echo "   $LISTENING"
    else
        echo "❌ Server is NOT listening on port $PORT"
        echo "   Make sure to start the server with: node server.js"
        exit 1
    fi
elif command_exists ss; then
    LISTENING=$(ss -ln | grep ":$PORT ")
    if [ -n "$LISTENING" ]; then
        echo "✅ Server is listening on port $PORT"
        echo "   $LISTENING"
    else
        echo "❌ Server is NOT listening on port $PORT"
        echo "   Make sure to start the server with: node server.js"
        exit 1
    fi
else
    echo "⚠️  Cannot check if server is listening (netstat/ss not available)"
fi

echo
echo "2. Testing local connectivity..."
if command_exists curl; then
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT 2>/dev/null)
    if [ "$RESPONSE" = "200" ]; then
        echo "✅ Server responds locally on localhost:$PORT"
    else
        echo "❌ Server not responding locally (HTTP $RESPONSE)"
        echo "   Try starting the server: node server.js"
    fi
else
    echo "⚠️  curl not available for testing"
fi

echo
echo "=== FIREWALL CHECK ==="
echo "3. Checking firewall status..."

# Check ufw (Ubuntu/Debian firewall)
if command_exists ufw; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null)
    echo "UFW Firewall status:"
    echo "$UFW_STATUS"
    
    if echo "$UFW_STATUS" | grep -q "Status: active"; then
        if echo "$UFW_STATUS" | grep -q "$PORT"; then
            echo "✅ Port $PORT is allowed in UFW"
        else
            echo "❌ Port $PORT is NOT allowed in UFW"
            echo "   Fix with: sudo ufw allow $PORT"
        fi
    else
        echo "✅ UFW firewall is inactive"
    fi
else
    echo "UFW not available"
fi

# Check iptables
if command_exists iptables; then
    echo
    echo "Checking iptables rules..."
    IPTABLES_INPUT=$(sudo iptables -L INPUT -n 2>/dev/null | grep "$PORT")
    if [ -n "$IPTABLES_INPUT" ]; then
        echo "iptables rules for port $PORT:"
        echo "$IPTABLES_INPUT"
    else
        echo "No specific iptables rules found for port $PORT"
    fi
    
    # Check if there's a general ACCEPT rule
    ACCEPT_ALL=$(sudo iptables -L INPUT -n 2>/dev/null | grep "ACCEPT.*0.0.0.0/0")
    if [ -n "$ACCEPT_ALL" ]; then
        echo "✅ General ACCEPT rule found"
    else
        echo "⚠️  No general ACCEPT rule - might be blocking connections"
    fi
fi

echo
echo "=== NETWORK INTERFACE CHECK ==="
echo "4. Checking network interfaces..."
ip addr show | grep -A 2 "inet $PI_IP"
echo

echo "5. Checking if server binds to all interfaces..."
if command_exists netstat; then
    BIND_CHECK=$(netstat -ln | grep ":$PORT" | grep "0.0.0.0")
    if [ -n "$BIND_CHECK" ]; then
        echo "✅ Server is bound to all interfaces (0.0.0.0:$PORT)"
    else
        echo "❌ Server might not be bound to all interfaces"
        echo "   Check server configuration for HOST = '0.0.0.0'"
    fi
fi

echo
echo "=== EXTERNAL CONNECTIVITY TEST ==="
echo "6. Testing external port connectivity..."

# Try to test the port from external perspective
if command_exists nc; then
    echo "Testing if port $PORT is open externally..."
    timeout 5 nc -zv $PI_IP $PORT 2>&1 | head -5
else
    echo "netcat (nc) not available for external port testing"
fi

echo
echo "=== SUGGESTED FIXES ==="
echo
echo "🔧 IMMEDIATE FIXES TO TRY:"
echo

echo "1. FIREWALL FIX (most common issue):"
echo "   sudo ufw allow $PORT"
echo "   # OR disable firewall temporarily to test:"
echo "   sudo ufw disable"
echo

echo "2. IPTABLES FIX (if using iptables):"
echo "   sudo iptables -A INPUT -p tcp --dport $PORT -j ACCEPT"
echo "   sudo iptables-save"
echo

echo "3. RESTART NETWORKING:"
echo "   sudo systemctl restart networking"
echo "   sudo systemctl restart dhcpcd"
echo

echo "4. CHECK SERVER BINDING:"
echo "   Make sure server.js has: const HOST = '0.0.0.0';"
echo

echo "5. TRY DIFFERENT PORT:"
echo "   PORT=8080 node server.js"
echo "   Then test: http://$PI_IP:8080"
echo

echo "6. DISABLE ALL FIREWALLS (TEMPORARY TEST):"
echo "   sudo ufw disable"
echo "   sudo systemctl stop iptables 2>/dev/null"
echo "   sudo systemctl stop firewalld 2>/dev/null"
echo

echo "=== TESTING FROM ANOTHER DEVICE ==="
echo
echo "From your phone/computer, try these URLs:"
echo "  http://$PI_IP:$PORT"
echo "  http://$PI_IP:8080  (if using alternative port)"
echo
echo "Also try pinging first: ping $PI_IP"
echo
echo "========================================="

echo
echo "🚀 QUICK FIX COMMANDS:"
echo "Copy and paste these commands to fix common issues:"
echo
echo "# Allow port through firewall"
echo "sudo ufw allow $PORT"
echo
echo "# OR temporarily disable firewall to test"
echo "sudo ufw disable"
echo
echo "# Restart server with verbose output"
echo "DEBUG=* node server.js"
echo
echo "========================================="
