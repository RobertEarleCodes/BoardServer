#!/bin/bash

echo "========================================="
echo "Raspberry Pi Quick Fix Script"
echo "========================================="

# Make sure we're in the right directory
if [ ! -f "server.js" ]; then
    echo "❌ server.js not found. Please run this script from the BoardServer directory."
    exit 1
fi

echo "🔧 Applying common Raspberry Pi fixes..."

# Fix 1: Kill any existing Node.js processes on port 3000
echo "1. Checking for existing processes on port 3000..."
if command -v netstat >/dev/null 2>&1; then
    PID=$(netstat -tulpn 2>/dev/null | grep ":3000 " | awk '{print $7}' | cut -d'/' -f1)
    if [ -n "$PID" ] && [ "$PID" != "-" ]; then
        echo "   Killing process $PID on port 3000..."
        sudo kill -9 "$PID" 2>/dev/null || kill -9 "$PID" 2>/dev/null
    else
        echo "   ✅ Port 3000 is free"
    fi
else
    echo "   Using pkill to stop any node processes..."
    pkill -f "node server.js" 2>/dev/null || true
fi

# Fix 2: Clean and reinstall dependencies
echo "2. Cleaning and reinstalling dependencies..."
rm -rf node_modules package-lock.json 2>/dev/null || true
npm cache clean --force 2>/dev/null || true
npm install

if [ $? -ne 0 ]; then
    echo "❌ npm install failed. Trying with --no-optional..."
    npm install --no-optional
fi

# Fix 3: Create uploads directory with proper permissions
echo "3. Setting up uploads directory..."
mkdir -p uploads
chmod 755 uploads

# Fix 4: Fix file permissions
echo "4. Fixing file permissions..."
chmod +x server.js 2>/dev/null || true
chmod 644 package.json 2>/dev/null || true
if [ -f board_data.json ]; then
    chmod 644 board_data.json
fi

# Fix 5: Check and fix Node.js version if needed
echo "5. Checking Node.js version..."
NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//' | cut -d'.' -f1)
if [ -z "$NODE_VERSION" ]; then
    echo "❌ Node.js not found or not working"
    exit 1
elif [ "$NODE_VERSION" -lt 14 ]; then
    echo "⚠️  Node.js version is too old: v$NODE_VERSION"
    echo "   You need to update Node.js to v14 or higher"
    echo "   Run: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
    exit 1
else
    echo "   ✅ Node.js version is compatible: $(node --version)"
fi

# Fix 6: Test server startup
echo "6. Testing server startup..."
timeout 10s node server.js &
SERVER_PID=$!
sleep 3

if ps -p $SERVER_PID > /dev/null; then
    echo "   ✅ Server started successfully!"
    kill $SERVER_PID 2>/dev/null
    wait $SERVER_PID 2>/dev/null
else
    echo "   ❌ Server failed to start"
    echo "   Try running manually: node server.js"
    exit 1
fi

echo
echo "========================================="
echo "✅ Raspberry Pi fixes applied successfully!"
echo "========================================="
echo
echo "Now try starting your server:"
echo "  node server.js"
echo
echo "Or with a different port if needed:"
echo "  PORT=3001 node server.js"
echo
echo "Access URLs will be shown when the server starts."
echo "========================================="
