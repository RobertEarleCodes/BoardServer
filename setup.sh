#!/bin/bash

# Board Server Setup Script for Raspberry Pi

echo "========================================="
echo "Board Server Setup for Raspberry Pi"
echo "========================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
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

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "========================================="
    echo "Setup completed successfully!"
    echo "========================================="
    echo ""
    echo "To start the server, run:"
    echo "  npm start"
    echo ""
    echo "The server will be accessible at:"
    echo "  Local: http://localhost:3000"
    echo "  LAN: http://YOUR_PI_IP:3000"
    echo ""
    echo "To make it run automatically on boot:"
    echo "  sudo npm install -g pm2"
    echo "  pm2 start server.js --name board-server"
    echo "  pm2 startup"
    echo "  pm2 save"
    echo ""
else
    echo "Installation failed. Please check the errors above."
    exit 1
fi
