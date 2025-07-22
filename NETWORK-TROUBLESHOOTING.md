# LAN Access Troubleshooting Guide

## Current Server Status
Your Board Management Server is correctly configured for LAN access:
- ✅ Server binds to `0.0.0.0:3000` (all network interfaces)
- ✅ Local IP detected: `192.168.1.250`
- ✅ macOS Application Firewall allows Node.js connections
- ✅ Server should be accessible at: `http://192.168.1.250:3000`

## Common Issues & Solutions

### 1. Testing from the Same Machine
**Issue**: When testing `http://192.168.1.250:3000` from the same Mac, it might not work the same as external access.

**Solution**: Test from a different device (phone, tablet, another computer) on the same network.

### 2. Router Configuration
**Issue**: Some routers block device-to-device communication by default.

**Check**: 
- Router settings for "AP Isolation" or "Client Isolation" - should be DISABLED
- Guest network isolation - make sure you're not on a guest network
- Access the router admin panel (usually `http://192.168.1.1`) and look for wireless security settings

### 3. Network Discovery Issues
**Issue**: Devices can't find each other on the network.

**Solutions**:
```bash
# On the server machine (Mac), check if other devices can ping it:
ping 192.168.1.250

# From another device, try to ping the Mac:
ping 192.168.1.250
```

### 4. Port-Specific Blocking
**Issue**: Router or ISP might block certain ports.

**Test**: Use the network test server on port 3001:
```bash
node network-test.js
```
Then try accessing `http://192.168.1.250:3001` from another device.

### 5. macOS Additional Firewall Settings
**Check**:
```bash
# Check if stealth mode is enabled (should be disabled for LAN access)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode

# If stealth mode is on, disable it:
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode off
```

### 6. Network Interface Issues
**Check if the correct network interface is active**:
```bash
# List all network interfaces
ifconfig

# Check routing table
netstat -rn
```

## Step-by-Step Testing

### Step 1: Test Local Access
1. Open browser on the Mac
2. Go to `http://localhost:3000`
3. Should work ✅

### Step 2: Test LAN IP from Same Machine
1. On the same Mac, try `http://192.168.1.250:3000`
2. May or may not work (this is normal)

### Step 3: Test from Another Device
1. Connect phone/tablet/laptop to the same WiFi network
2. Open browser and go to `http://192.168.1.250:3000`
3. This should work if everything is configured correctly

### Step 4: Network Test Server
1. Run: `node network-test.js`
2. Try accessing `http://192.168.1.250:3001` from another device
3. Watch the terminal for connection logs

## Advanced Diagnostics

### Check if port 3000 is accessible from network:
```bash
# Install nmap if needed: brew install nmap
nmap -p 3000 192.168.1.250
```

### Check network connectivity:
```bash
# From another machine, test if port is open:
telnet 192.168.1.250 3000
```

### Disable macOS firewall temporarily (for testing only):
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
# Remember to re-enable it after testing:
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

## Expected Behavior
- ✅ `http://localhost:3000` - Should always work
- ✅ `http://192.168.1.250:3000` from another device - Should work if network allows
- ❓ `http://192.168.1.250:3000` from same machine - May or may not work (varies by system)

## Quick Fix Checklist
1. [ ] Test from a different device on the same network
2. [ ] Check router for AP/Client isolation settings
3. [ ] Verify you're on the same WiFi network (not guest network)
4. [ ] Try the network test server on port 3001
5. [ ] Temporarily disable firewall for testing
6. [ ] Check if other devices can ping 192.168.1.250

## Still Not Working?
If none of the above works, the issue might be:
- Router firmware blocking inter-device communication
- ISP-level restrictions (common in some public/corporate networks)
- Network hardware issues
- Need to restart router/modem
