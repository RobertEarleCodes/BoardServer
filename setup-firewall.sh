#!/bin/bash

# Firewall Setup Script for BoardServer
echo "🔥 BoardServer Firewall Setup"
echo "============================"

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  This script needs sudo privileges for firewall configuration"
    echo "Please run: sudo ./setup-firewall.sh"
    exit 1
fi

echo ""
echo "🔍 Checking firewall status..."

# Check if UFW is installed
if command -v ufw >/dev/null 2>&1; then
    echo "✅ UFW is installed"
    
    # Check UFW status
    UFW_STATUS=$(ufw status | head -1)
    echo "   Status: $UFW_STATUS"
    
    # Enable UFW if not active
    if echo "$UFW_STATUS" | grep -q "inactive"; then
        echo ""
        echo "🔧 Enabling UFW..."
        ufw --force enable
    fi
    
    # Allow port 3000
    echo ""
    echo "🚪 Opening port 3000 for BoardServer..."
    ufw allow 3000
    
    echo ""
    echo "✅ Firewall configured successfully!"
    echo ""
    echo "📋 Current UFW rules:"
    ufw status numbered
    
else
    echo "❌ UFW not found, installing..."
    
    # Update package list
    apt update
    
    # Install UFW
    apt install -y ufw
    
    if [ $? -eq 0 ]; then
        echo "✅ UFW installed successfully"
        
        # Enable UFW
        echo "🔧 Enabling UFW..."
        ufw --force enable
        
        # Allow SSH (important!)
        echo "🔐 Allowing SSH access..."
        ufw allow ssh
        
        # Allow port 3000
        echo "🚪 Opening port 3000 for BoardServer..."
        ufw allow 3000
        
        echo ""
        echo "✅ Firewall setup complete!"
        echo ""
        echo "📋 Current UFW rules:"
        ufw status numbered
    else
        echo "❌ Failed to install UFW"
        echo "Please install manually: sudo apt install ufw"
        exit 1
    fi
fi

echo ""
echo "🌍 Your BoardServer port (3000) is now open!"
echo "⚠️  Remember to also configure port forwarding on your router"
echo "    for global internet access."
