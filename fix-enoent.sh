#!/bin/bash

echo "========================================="
echo "ENOENT Error Diagnosis and Fix"
echo "========================================="

echo "🔍 CHECKING FOR MISSING FILES/DIRECTORIES..."
echo

# Check if we're in the right directory
if [ ! -f "server.js" ]; then
    echo "❌ server.js not found in current directory"
    echo "   Current directory: $(pwd)"
    echo "   Make sure you're in the BoardServer directory"
    exit 1
else
    echo "✅ server.js found"
fi

# Check for required directories
echo
echo "📁 CHECKING REQUIRED DIRECTORIES:"

if [ ! -d "public" ]; then
    echo "❌ public/ directory missing"
    mkdir -p public
    echo "   Created public/ directory"
else
    echo "✅ public/ directory exists"
fi

if [ ! -d "uploads" ]; then
    echo "❌ uploads/ directory missing"
    mkdir -p uploads
    echo "   Created uploads/ directory"
else
    echo "✅ uploads/ directory exists"
fi

if [ ! -d "node_modules" ]; then
    echo "❌ node_modules/ directory missing"
    echo "   Run: npm install"
else
    echo "✅ node_modules/ directory exists"
fi

# Check for required files
echo
echo "📄 CHECKING REQUIRED FILES:"

if [ ! -f "package.json" ]; then
    echo "❌ package.json missing"
else
    echo "✅ package.json exists"
fi

if [ ! -f "public/index.html" ]; then
    echo "❌ public/index.html missing"
    echo "   This is required for the web interface"
else
    echo "✅ public/index.html exists"
fi

# Check if board_data.json exists or can be created
if [ ! -f "board_data.json" ]; then
    echo "ℹ️  board_data.json will be created automatically"
    # Test if we can create it
    if touch board_data.json 2>/dev/null; then
        echo "✅ Can create board_data.json"
        rm board_data.json
    else
        echo "❌ Cannot create board_data.json - permission issue"
    fi
else
    echo "✅ board_data.json exists"
fi

# Check file permissions
echo
echo "🔐 CHECKING PERMISSIONS:"
echo "Current user: $(whoami)"
echo "Directory permissions: $(ls -ld . | awk '{print $1, $3, $4}')"

if [ -f "server.js" ]; then
    echo "server.js permissions: $(ls -l server.js | awk '{print $1, $3, $4}')"
fi

# Check if there are any symlinks or broken links
echo
echo "🔗 CHECKING FOR BROKEN SYMLINKS:"
find . -type l -exec test ! -e {} \; -print 2>/dev/null | head -5

# Check for common ENOENT causes in Node.js apps
echo
echo "🚨 COMMON ENOENT FIXES:"
echo
echo "1. MISSING UPLOADS DIRECTORY:"
echo "   mkdir -p uploads"
echo
echo "2. MISSING PUBLIC DIRECTORY:"
echo "   mkdir -p public"
echo
echo "3. MISSING DEPENDENCIES:"
echo "   rm -rf node_modules package-lock.json"
echo "   npm install"
echo
echo "4. PERMISSION ISSUES:"
echo "   sudo chown -R \$USER:\$USER ."
echo "   chmod 755 uploads public"
echo
echo "5. WRONG WORKING DIRECTORY:"
echo "   cd /full/path/to/BoardServer"
echo "   pwd  # should show BoardServer directory"
echo
echo "6. FILE PATH ISSUES IN CODE:"
echo "   Check server.js for hardcoded paths"
echo

echo "🔧 QUICK FIX - RUN THESE COMMANDS:"
echo "=================================="
echo "# Ensure you're in the right directory"
echo "cd \$(dirname \$0)"
echo "pwd"
echo
echo "# Create missing directories"
echo "mkdir -p uploads public"
echo
echo "# Fix permissions"
echo "chmod 755 uploads public"
echo "chmod 644 *.js *.json 2>/dev/null || true"
echo
echo "# Reinstall dependencies if needed"
echo "if [ ! -d node_modules ]; then npm install; fi"
echo
echo "# Test server startup"
echo "node server.js"
echo

# Test for specific file access
echo "🧪 TESTING FILE ACCESS:"
echo

# Test creating files in current directory
if touch test_write.tmp 2>/dev/null; then
    echo "✅ Can write to current directory"
    rm test_write.tmp
else
    echo "❌ Cannot write to current directory"
fi

# Test uploads directory
if [ -d uploads ] && touch uploads/test_write.tmp 2>/dev/null; then
    echo "✅ Can write to uploads/ directory"
    rm uploads/test_write.tmp
else
    echo "❌ Cannot write to uploads/ directory"
fi

echo
echo "========================================="
echo "📋 NEXT STEPS:"
echo "1. Run the quick fix commands above"
echo "2. Try starting the server again"
echo "3. If still failing, run with DEBUG:"
echo "   DEBUG=* node server.js"
echo "========================================="
