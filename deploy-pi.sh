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
echo "✅ Pi Deployment Complete!"
echo "========================================="
echo
echo "🚀 Start your server with:"
echo "   npm start"
echo "   # or"
echo "   node server.js"
echo
echo "🌐 Access your server at:"
echo "   Local: http://localhost:3000"
echo "   LAN: http://$(hostname -I | awk '{print $1}'):3000"
echo
echo "📋 Troubleshooting:"
echo "   ./pi-troubleshoot.sh"
echo
echo "========================================="
