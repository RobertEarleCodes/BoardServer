#!/bin/bash

# BoardServer Global Deployment Script
echo "🌍 Setting up BoardServer for Global Internet Access"
echo "===================================================="

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create uploads directory
mkdir -p uploads

echo ""
echo "🌐 GLOBAL ACCESS SETUP CHECKLIST:"
echo ""
echo "✅ 1. Server Configuration: DONE"
echo "   - Server will bind to 0.0.0.0:3000 (all interfaces)"
echo "   - Security features enabled in production mode"
echo ""
echo "⚠️  2. ROUTER CONFIGURATION NEEDED:"
echo "   - Log into your router admin panel"
echo "   - Set up Port Forwarding:"
echo "     External Port: 3000 → Internal IP: [Pi's IP] Port: 3000"
echo ""
echo "⚠️  3. FIREWALL CONFIGURATION NEEDED:"
echo "   - On Pi: sudo ufw allow 3000"
echo "   - On Router: Allow incoming port 3000"
echo ""
echo "🔍 4. FIND YOUR PUBLIC IP:"
echo "   - Run: curl ifconfig.me"
echo "   - Your global URL will be: http://[PUBLIC_IP]:3000"
echo ""
echo "🚀 TO START GLOBAL SERVER:"
echo "   npm run start:global"
echo ""
echo "⚠️  SECURITY NOTICE:"
echo "   Your server will be accessible from ANYWHERE on the internet!"
echo "   Make sure you understand the security implications."
echo ""
echo "🔧 TROUBLESHOOTING:"
echo "   - If timeout: Check router port forwarding"
echo "   - If refused: Check firewall settings"
echo "   - If unreachable: Verify public IP"
echo ""
echo "� Ready for configuration! Follow the steps above."
