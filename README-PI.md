# Raspberry Pi Board Server

Clean deployment files for Raspberry Pi - no platform-specific dependencies included.

## Quick Setup on Pi

```bash
# 1. Clone this repository
git clone <your-repo-url>
cd BoardServer

# 2. Install dependencies
npm install

# 3. Start server
npm start
```

## Files Included

- `server.js` - Main server application
- `package.json` - Dependencies configuration
- `public/index.html` - Web interface
- Setup and troubleshooting scripts

## Access Your Server

Once running, access at:
- Local: `http://localhost:3000`
- LAN: `http://YOUR_PI_IP:3000`

## Troubleshooting

If you encounter issues:
```bash
./pi-troubleshoot.sh
```

## Manual Setup

```bash
# Install Node.js (if needed)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install dependencies
npm install

# Create required directories
mkdir -p uploads

# Start server
node server.js
```
