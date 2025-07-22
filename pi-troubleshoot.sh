#!/bin/bash

echo "========================================="
echo "Raspberry Pi Server Troubleshooting"
echo "========================================="

# Function to check command existence
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get Pi model
get_pi_model() {
    if [ -f /proc/device-tree/model ]; then
        cat /proc/device-tree/model 2>/dev/null | tr -d '\0'
    else
        echo "Unknown Pi model"
    fi
}

echo "Pi Model: $(get_pi_model)"
echo "OS Info: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Architecture: $(uname -m)"
echo "Kernel: $(uname -r)"
echo

# Check system resources
echo "=== SYSTEM RESOURCES ==="
echo "Memory usage:"
free -h
echo
echo "Disk usage:"
df -h | grep -E "(Filesystem|/dev/root|/dev/mmcblk)"
echo
echo "CPU temperature:"
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    temp=$(cat /sys/class/thermal/thermal_zone0/temp)
    echo "$((temp/1000))°C"
else
    echo "Cannot read temperature"
fi
echo

# Check Node.js installation
echo "=== NODE.JS CHECK ==="
if command_exists node; then
    echo "✅ Node.js version: $(node --version)"
    echo "✅ npm version: $(npm --version)"
    
    # Check if Node.js version is compatible
    NODE_VERSION=$(node --version | sed 's/v//' | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 14 ]; then
        echo "⚠️  WARNING: Node.js version is too old (need v14+)"
        echo "   Update with: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
    fi
else
    echo "❌ Node.js not found!"
    echo "   Install with: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
fi
echo

# Check dependencies
echo "=== DEPENDENCIES CHECK ==="
if [ -f package.json ]; then
    echo "✅ package.json found"
    if [ -d node_modules ]; then
        echo "✅ node_modules directory exists"
        echo "Installed packages:"
        npm list --depth=0 2>/dev/null || echo "❌ Dependencies not properly installed"
    else
        echo "❌ node_modules not found - run 'npm install'"
    fi
else
    echo "❌ package.json not found - are you in the right directory?"
fi
echo

# Check port availability
echo "=== PORT CHECK ==="
PORT=3000
if command_exists netstat; then
    PROCESS=$(netstat -tulpn 2>/dev/null | grep ":$PORT ")
    if [ -n "$PROCESS" ]; then
        echo "❌ Port $PORT is in use:"
        echo "$PROCESS"
        PID=$(echo "$PROCESS" | awk '{print $7}' | cut -d'/' -f1)
        if [ -n "$PID" ] && [ "$PID" != "-" ]; then
            echo "   To kill the process: sudo kill -9 $PID"
        fi
    else
        echo "✅ Port $PORT is available"
    fi
elif command_exists ss; then
    PROCESS=$(ss -tulpn 2>/dev/null | grep ":$PORT ")
    if [ -n "$PROCESS" ]; then
        echo "❌ Port $PORT is in use:"
        echo "$PROCESS"
    else
        echo "✅ Port $PORT is available"
    fi
else
    echo "⚠️  Cannot check port status (netstat/ss not available)"
fi
echo

# Check network configuration
echo "=== NETWORK CHECK ==="
echo "Network interfaces:"
ip addr show | grep -E "(inet |UP)" | grep -v "127.0.0.1"
echo
echo "Default route:"
ip route show default
echo
echo "Pi IP addresses:"
hostname -I
echo

# Check file permissions
echo "=== FILE PERMISSIONS ==="
if [ -f server.js ]; then
    echo "✅ server.js permissions: $(ls -la server.js | awk '{print $1, $3, $4}')"
else
    echo "❌ server.js not found"
fi

if [ -d uploads ]; then
    echo "✅ uploads directory permissions: $(ls -lad uploads | awk '{print $1, $3, $4}')"
else
    echo "❌ uploads directory not found"
fi

if [ -f board_data.json ]; then
    echo "✅ board_data.json permissions: $(ls -la board_data.json | awk '{print $1, $3, $4}')"
else
    echo "ℹ️  board_data.json not found (will be created)"
fi
echo

# Check for common Pi-specific issues
echo "=== PI-SPECIFIC CHECKS ==="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Running as root - this might cause permission issues"
fi

# Check available space
AVAILABLE_SPACE=$(df . | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_SPACE" -lt 100000 ]; then
    echo "⚠️  Low disk space: ${AVAILABLE_SPACE}KB available"
fi

# Check for swap
SWAP=$(free | grep Swap | awk '{print $2}')
if [ "$SWAP" -eq 0 ]; then
    echo "⚠️  No swap space configured - might cause memory issues"
fi

# Check systemd journal for errors
if command_exists journalctl; then
    echo "Recent system errors:"
    journalctl --since "1 hour ago" --priority=err --no-pager -q | tail -5
fi
echo

echo "=== FIREWALL CHECK ==="
echo "Checking firewall status..."

# Check UFW status
if command_exists ufw; then
    UFW_STATUS=$(sudo ufw status numbered 2>/dev/null)
    echo "UFW Status:"
    echo "$UFW_STATUS"
    
    if echo "$UFW_STATUS" | grep -q "3000"; then
        echo "✅ Port 3000 is allowed in UFW"
    else
        echo "❌ Port 3000 NOT found in UFW rules"
        echo "   Fix: sudo ufw allow 3000"
    fi
else
    echo "UFW not available"
fi

# Check iptables
if command_exists iptables; then
    echo
    echo "iptables INPUT rules:"
    sudo iptables -L INPUT -n --line-numbers | grep -E "(3000|ACCEPT|DROP|REJECT)" || echo "No relevant iptables rules found"
fi
echo

# Check if server is actually listening and on which interface
echo "=== SERVER BINDING CHECK ==="
if command_exists netstat; then
    echo "Checking what's listening on port 3000:"
    LISTEN_CHECK=$(netstat -tulpn 2>/dev/null | grep ":3000")
    if [ -n "$LISTEN_CHECK" ]; then
        echo "$LISTEN_CHECK"
        if echo "$LISTEN_CHECK" | grep -q "0.0.0.0:3000"; then
            echo "✅ Server is bound to all interfaces (0.0.0.0)"
        elif echo "$LISTEN_CHECK" | grep -q "127.0.0.1:3000"; then
            echo "❌ Server is only bound to localhost (127.0.0.1)"
            echo "   This prevents external access!"
        elif echo "$LISTEN_CHECK" | grep -q ":::3000"; then
            echo "✅ Server is bound to IPv6 all interfaces"
        fi
    else
        echo "❌ No process listening on port 3000"
        echo "   Make sure server is running: node server.js"
    fi
elif command_exists ss; then
    echo "Checking what's listening on port 3000:"
    LISTEN_CHECK=$(ss -tulpn | grep ":3000")
    if [ -n "$LISTEN_CHECK" ]; then
        echo "$LISTEN_CHECK"
    else
        echo "❌ No process listening on port 3000"
    fi
fi
echo

echo "=== CONNECTIVITY TEST ==="
# Test local connectivity
if command_exists curl; then
    echo "Testing local connectivity:"
    LOCAL_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
    if [ "$LOCAL_TEST" = "200" ]; then
        echo "✅ localhost:3000 responds (HTTP $LOCAL_TEST)"
    else
        echo "❌ localhost:3000 not responding (HTTP $LOCAL_TEST)"
    fi
    
    # Test via local IP
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    IP_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://$LOCAL_IP:3000 2>/dev/null)
    if [ "$IP_TEST" = "200" ]; then
        echo "✅ $LOCAL_IP:3000 responds (HTTP $IP_TEST)"
    else
        echo "❌ $LOCAL_IP:3000 not responding (HTTP $IP_TEST)"
        echo "   This indicates a binding or firewall issue"
    fi
else
    echo "curl not available for connectivity testing"
fi
echo

echo "=== SUGGESTED FIXES ==="
echo "1. If server only binds to localhost: Check server.js HOST setting"
echo "2. If port is in use: sudo kill -9 <process_id>"
echo "3. If dependencies missing: rm -rf node_modules && npm install"
echo "4. If permission issues: sudo chown -R \$USER:users ."
echo "5. If memory issues: sudo systemctl stop unnecessary-services"
echo "6. If Node.js too old: Update Node.js to v18+"
echo "7. Try different port: PORT=3001 node server.js"
echo "8. Disable firewall temporarily: sudo ufw disable"
echo "9. Check server binding: grep -n 'HOST.*=' server.js"
echo

echo "=== MANUAL TEST ==="
echo "Run this to test the server manually:"
echo "  node server.js"
echo
echo "If it starts, access it at:"
echo "  Local: http://localhost:3000"
echo "  LAN: http://$(hostname -I | awk '{print $1}'):3000"
echo
echo "========================================="
