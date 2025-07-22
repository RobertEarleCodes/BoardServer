#!/bin/bash

echo "========================================="
echo "Pi Deployment - Clean Setup"
echo "========================================="

# Remove any existing platform-specific files
echo "🧹 Cleaning platform-specific files..."
rm -rf node_modules/ package-lock.json .DS_Store *.log

# Ensure required directories exist
echo "📁 Creating required directories..."
mkdir -p uploads public

# Install dependencies fresh for Pi
echo "📦 Installing dependencies for Pi..."
npm install --production

# Set proper permissions
echo "🔐 Setting file permissions..."
chmod 755 uploads public
chmod 644 *.js *.json 2>/dev/null || true

# Create empty board_data.json if it doesn't exist
if [ ! -f board_data.json ]; then
    echo "📄 Creating initial board_data.json..."
    echo '{"boards":[],"currentBoard":null,"routes":[]}' > board_data.json
fi

# Test installation
echo "🧪 Testing installation..."
if node --version >/dev/null 2>&1; then
    echo "✅ Node.js: $(node --version)"
else
    echo "❌ Node.js not found"
    exit 1
fi

if npm list express >/dev/null 2>&1; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Dependencies missing"
    exit 1
fi

echo
echo "========================================="
echo "🔧 Pi Network Configuration"
echo "========================================="

# Get Pi's IP address
PI_IP=$(hostname -I | awk '{print $1}')
echo "Pi IP Address: $PI_IP"

# Check and fix firewall
echo "🔥 Configuring firewall for port 3000..."
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow 3000/tcp
    echo "✅ UFW: Allowed port 3000"
else
    echo "ℹ️  UFW not installed, checking iptables..."
fi

# Test port availability
echo "🔍 Checking port 3000 availability..."
if netstat -tulpn 2>/dev/null | grep -q ":3000"; then
    echo "⚠️  Port 3000 is in use. Killing existing processes..."
    sudo pkill -f "node.*server.js" 2>/dev/null || true
    sleep 2
fi

# Verify server binding configuration
echo "🔧 Verifying server binding..."
if grep -q "0.0.0.0" server.js; then
    echo "✅ Server configured to bind to all interfaces (0.0.0.0)"
else
    echo "⚠️  Server may only bind to localhost"
    echo "   Check server.js HOST configuration"
fi

echo
echo "========================================="
echo "✅ Pi Deployment Complete!"
echo "========================================="
echo
echo "🚀 Start your server with:"
echo "   npm start"
echo "   # OR"
echo "   node server.js"
echo
echo "🌐 Access your server at:"
echo "   Local:  http://localhost:3000"
echo "   LAN:    http://$PI_IP:3000"
echo
echo "🔧 If LAN access fails, run:"
echo "   ./pi-fix-network.sh"
echo
echo "========================================="
