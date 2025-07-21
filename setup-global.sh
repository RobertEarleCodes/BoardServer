#!/bin/bash

# BoardServer Global Deployment Script
echo "🌍 Setting up BoardServer for Global Access"
echo "============================================="

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create uploads directory
mkdir -p uploads

# Set environment for global access
echo "🌐 Configuring for global deployment..."
export NODE_ENV=production
export HOST=0.0.0.0
export PORT=${PORT:-3000}

echo ""
echo "⚠️  SECURITY NOTICE:"
echo "   Your server will be accessible from the internet!"
echo "   Make sure you have proper firewall rules configured."
echo ""
echo "🔧 To run globally, use one of these methods:"
echo ""
echo "   Method 1 - Environment variables:"
echo "   NODE_ENV=production npm start"
echo ""
echo "   Method 2 - Direct command:"
echo "   npm run start:global"
echo ""
echo "   Method 3 - With custom port:"
echo "   NODE_ENV=production PORT=8080 npm start"
echo ""
echo "🚀 Ready for global deployment!"
