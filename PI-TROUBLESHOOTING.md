# Raspberry Pi Troubleshooting Guide

## Quick Fix (Try This First)

Copy these files to your Raspberry Pi and run:

```bash
# Make scripts executable
chmod +x pi-fix.sh pi-troubleshoot.sh

# Run the quick fix
./pi-fix.sh
```

If that doesn't work, run the diagnostic:
```bash
./pi-troubleshoot.sh
```

## Common Raspberry Pi Issues

### 1. **Port Already in Use**
This is the most common issue after a reboot or crashed server.

**Symptoms:**
- `Error: listen EADDRINUSE :::3000`
- Server won't start

**Fix:**
```bash
# Kill existing process
sudo pkill -f "node server.js"
# Or find and kill specific PID
sudo netstat -tulpn | grep :3000
sudo kill -9 <PID>
```

### 2. **Outdated Node.js Version**
Older Raspberry Pi OS versions have outdated Node.js.

**Check version:**
```bash
node --version
```

**If version is below v14, update:**
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 3. **Memory Issues**
Raspberry Pi can run out of memory, especially older models.

**Check memory:**
```bash
free -h
```

**If low memory:**
```bash
# Stop unnecessary services
sudo systemctl stop bluetooth
sudo systemctl stop cups
# Add swap if none exists
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

### 4. **Permission Issues**
Sometimes files don't have correct permissions.

**Fix permissions:**
```bash
cd /path/to/BoardServer
sudo chown -R $USER:$USER .
chmod 755 uploads/
chmod 644 *.json
```

### 5. **Corrupted Dependencies**
npm modules can get corrupted on Pi.

**Clean reinstall:**
```bash
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

### 6. **Network Configuration Issues**
Pi network interface might have changed.

**Check IP:**
```bash
hostname -I
ip addr show
```

**If no IP or wrong interface:**
```bash
sudo dhcpcd
# Or restart networking
sudo systemctl restart networking
```

## Manual Debugging Steps

### 1. Test Basic Functionality
```bash
# Test Node.js
node --version
npm --version

# Test simple server
node -e "console.log('Node.js works!')"
```

### 2. Check System Resources
```bash
# Memory
free -h

# Disk space
df -h

# CPU temperature
vcgencmd measure_temp

# System load
uptime
```

### 3. Check Dependencies
```bash
# List installed packages
npm list --depth=0

# Check for missing dependencies
npm audit
```

### 4. Test Network
```bash
# Check interfaces
ip addr show

# Test localhost
curl http://localhost:3000 || echo "Server not responding"

# Test from another device (replace IP)
curl http://192.168.1.XXX:3000
```

## Alternative Solutions

### Use Different Port
If port 3000 is problematic:
```bash
PORT=3001 node server.js
```

### Run with PM2 (Process Manager)
For automatic restart and better process management:
```bash
npm install -g pm2
pm2 start server.js --name board-server
pm2 startup
pm2 save
```

### Run as System Service
Create `/etc/systemd/system/board-server.service`:
```ini
[Unit]
Description=Board Server
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/BoardServer
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Then:
```bash
sudo systemctl enable board-server
sudo systemctl start board-server
sudo systemctl status board-server
```

## Hardware-Specific Issues

### Raspberry Pi Zero/Zero W
- Very limited memory - consider using Pi 3B+ or 4
- Slower CPU - server startup might take longer

### Raspberry Pi 1/2
- Older ARM architecture might have compatibility issues
- Consider updating to newer Pi model

### SD Card Issues
- Corrupted SD card can cause random failures
- Test with: `sudo fsck /dev/mmcblk0p2`
- Consider using high-quality SD card (Class 10, A1)

## If All Else Fails

1. **Fresh OS Install**: Flash new Raspberry Pi OS
2. **Hardware Test**: Try different SD card
3. **Network Test**: Connect via Ethernet instead of WiFi
4. **Use Docker**: Run the server in a container for isolation

## Getting Help

When asking for help, provide:
1. Output of `./pi-troubleshoot.sh`
2. Exact error messages
3. Pi model and OS version
4. What changed since it last worked

This information will help diagnose the specific issue with your setup.
