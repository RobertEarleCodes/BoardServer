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

echo "=== SUGGESTED FIXES ==="
echo "1. If port is in use: sudo kill -9 <process_id>"
echo "2. If dependencies missing: rm -rf node_modules && npm install"
echo "3. If permission issues: sudo chown -R \$USER:users ."
echo "4. If memory issues: sudo systemctl stop unnecessary-services"
echo "5. If Node.js too old: Update Node.js to v18+"
echo "6. Try different port: PORT=3001 node server.js"
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
