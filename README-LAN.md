# Board Management Server - LAN Only

A simple, secure web-based board management system designed exclusively for local network (LAN) access. This server allows you to upload board images, create interactive zones, and manage routes on your local network without any internet exposure.

## 🏠 LAN-Only Features

- **Local Network Only**: Server runs exclusively on your local network
- **Zero Internet Exposure**: No global access or security vulnerabilities
- **Simple Setup**: No firewall or router configuration needed
- **Multi-Device Access**: Any device on your local network can access the interface
- **Image Upload**: Upload board images and create interactive zones
- **Route Management**: Create and manage routes between zones
- **Data Persistence**: All data saved locally to JSON file

## 🚀 Quick Start

### Prerequisites
- Node.js (version 14 or higher)
- npm (comes with Node.js)

### Installation

1. **Clone or download this repository**
   ```bash
   git clone <repository-url>
   cd BoardServer
   ```

2. **Run the setup script**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Start the server**
   ```bash
   npm start
   ```

4. **Access the application**
   - Local: http://localhost:3000
   - LAN: http://YOUR_LOCAL_IP:3000

### Finding Your Local IP Address

**macOS/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows:**
```cmd
ipconfig
```

Look for your local IP address (usually starts with 192.168.x.x or 10.x.x.x)

## 📱 Usage

1. **Upload a Board Image**: Click "Upload Board Image" to upload an image of your board
2. **Create Zones**: Click on the board image to create interactive zones
3. **Name Zones**: Enter names for each zone you create
4. **Create Routes**: Select multiple zones and create named routes
5. **Manage**: Edit or delete zones and routes as needed

## 🔧 Configuration

The server runs with the following default settings:
- **Port**: 3000 (can be changed with PORT environment variable)
- **Host**: 0.0.0.0 (binds to all network interfaces for LAN access)
- **Data Storage**: board_data.json (local file)
- **Image Storage**: uploads/ directory

## 📁 File Structure

```
BoardServer/
├── server.js              # Main server file
├── package.json           # Node.js dependencies
├── setup.sh              # Setup script
├── public/
│   └── index.html         # Web interface
├── uploads/               # Uploaded board images
├── board_data.json        # Data storage (created automatically)
└── README.md             # This file
```

## 🔒 Security

This server is designed for **local network use only**:

- No internet exposure by design
- No external security vulnerabilities
- No sensitive data transmission over internet
- Access limited to devices on your local network
- No authentication required (trusted local environment)

## 🛠 Development

### Manual Installation
```bash
npm install
mkdir -p uploads
node server.js
```

### Available Scripts
```bash
npm start     # Start the server
npm run dev   # Start in development mode
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## 📄 License

MIT License - feel free to use and modify for your needs.

## 🆘 Troubleshooting

### Server won't start
- Ensure Node.js is installed: `node --version`
- Check if port 3000 is available: `lsof -i :3000`
- Try a different port: `PORT=3001 npm start`

### Can't access from other devices
- Ensure devices are on the same network
- Check firewall settings (local firewall, not router)
- Verify the local IP address is correct

### Images won't upload
- Check the uploads/ directory exists and is writable
- Ensure image file size is under 10MB
- Try different image formats (JPG, PNG, GIF)

## 🔍 Technical Details

- **Framework**: Express.js
- **File Upload**: Multer
- **Frontend**: Vanilla HTML/CSS/JavaScript
- **Data Storage**: JSON file
- **Image Storage**: Local filesystem
- **Network**: HTTP (no HTTPS needed for local network)

---

**Note**: This server is specifically designed for local network use only. It includes no security measures for internet exposure and should never be made accessible from the internet.
