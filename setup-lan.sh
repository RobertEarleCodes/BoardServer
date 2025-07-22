#!/bin/bash

# Board Server LAN Setup Script

echo "========================================="
echo "Board Server Setup - LAN Only"
echo "========================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js..."
    # For macOS with Homebrew
    if command -v brew &> /dev/null; then
        brew install node
    # For Ubuntu/Debian
    elif command -v apt-get &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    # For CentOS/RHEL/Fedora
    elif command -v yum &> /dev/null; then
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    else
        echo "Please install Node.js manually from https://nodejs.org/"
        exit 1
    fi
else
    echo "Node.js is already installed: $(node --version)"
fi

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "npm not found. Please install Node.js properly."
    exit 1
else
    echo "npm is available: $(npm --version)"
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Create uploads directory
mkdir -p uploads

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "========================================="
    echo "Setup completed successfully!"
    echo "========================================="
    echo ""
    echo "🏠 LAN-Only Board Management Server"
    echo ""
    echo "To start the server, run:"
    echo "  npm start"
    echo ""
    echo "The server will be accessible at:"
    echo "  Local: http://localhost:3000"
    echo "  LAN: http://YOUR_LOCAL_IP:3000"
    echo ""
    echo "🔒 Security: Server is configured for local network access only"
    echo "   - No internet exposure"
    echo "   - No firewall configuration needed"
    echo "   - Accessible by devices on your local network"
    echo ""
    echo "To find your local IP address:"
    echo "  - macOS/Linux: ifconfig | grep 'inet '"
    echo "  - Windows: ipconfig"
    echo ""
    echo "To make it run automatically on boot (optional):"
    echo "  sudo npm install -g pm2"
    echo "  pm2 start server.js --name board-server"
    echo "  pm2 startup"
    echo "  pm2 save"
    echo ""
else
    echo "Installation failed. Please check the errors above."
    exit 1
fi
