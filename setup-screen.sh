#!/bin/bash

echo "========================================="
echo "Setting up Screen for Pi Server"
echo "========================================="

# Check if screen is installed
if ! command -v screen >/dev/null 2>&1; then
    echo "📦 Installing screen..."
    sudo apt-get update
    sudo apt-get install -y screen
    echo "✅ Screen installed!"
else
    echo "✅ Screen is already installed"
fi

echo
echo "🚀 SCREEN COMMANDS FOR YOUR SERVER:"
echo

echo "1. START SERVER IN SCREEN:"
echo "   screen -S board-server"
echo "   cd /path/to/BoardServer"
echo "   node server.js"
echo

echo "2. DETACH FROM SCREEN (leave server running):"
echo "   Press: Ctrl+A then D"
echo

echo "3. REATTACH TO SCREEN:"
echo "   screen -r board-server"
echo

echo "4. LIST ALL SCREEN SESSIONS:"
echo "   screen -ls"
echo

echo "5. KILL SCREEN SESSION:"
echo "   screen -X -S board-server quit"
echo

echo "========================================="
echo "🎯 QUICK SETUP - Copy these commands:"
echo "========================================="

echo
echo "# Create and start screen session"
echo "screen -S board-server"
echo
echo "# Inside screen, navigate and start server"
echo "cd \$(pwd)"
echo "node server.js"
echo
echo "# To detach: Ctrl+A then D"
echo "# To reattach: screen -r board-server"
echo

echo "========================================="
echo "📋 SCREEN CHEAT SHEET:"
echo "========================================="
echo "Ctrl+A then D     - Detach from screen"
echo "Ctrl+A then K     - Kill current window"
echo "Ctrl+A then C     - Create new window"
echo "Ctrl+A then N     - Next window"
echo "Ctrl+A then P     - Previous window"
echo "Ctrl+A then \"     - List all windows"
echo "screen -r         - Reattach to session"
echo "screen -ls        - List all sessions"
echo "exit              - Exit screen session"
echo "========================================="
