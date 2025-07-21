# Board Server for Raspberry Pi

A web-based interactive board management system that allows you to create zones and routes on a board image. Perfect for climbing route planning, game boards, or any spatial reference system.

## Features

- **Set Board Mode**: Click anywhere on the board to place blue zones
- **Set Route Mode**: Select zones to create named routes
- **Image Upload**: Upload your own board/wall image
- **Route Management**: Save, view, and delete routes
- **Local Storage**: All data is saved locally on the server
- **LAN Access**: Accessible from any device on your local network
- **Zero Setup**: Just install dependencies and run!

## Quick Start

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. **Start the Server**:
   ```bash
   npm start
   ```

3. **Access the Application**:
   - Local: http://localhost:3000
   - LAN: http://YOUR_PI_IP:3000

## How to Use

### Set Board Mode
1. Click "Set Board" button
2. Click anywhere on the board area to place blue zones
3. Each zone gets a number automatically
4. Use "Clear All Zones" to remove all zones

### Set Route Mode
1. Click "Set Route" button
2. Click on zones to select them (they turn yellow)
3. Enter a name for your route
4. Click "Save Route"

### Managing Routes
- Click on a saved route to highlight its zones on the board
- Use the delete button to remove routes
- Routes are automatically saved to local storage

## Installation on Raspberry Pi

1. **Install Node.js** (if not already installed):
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

2. **Clone/Download this project**:
   ```bash
   # If using git
   git clone <your-repo-url>
   cd BoardServer
   
   # Or download and extract the files
   ```

3. **Install dependencies**:
   ```bash
   npm install
   ```

4. **Run the server**:
   ```bash
   npm start
   ```

5. **Make it run automatically** (optional):
   ```bash
   # Install PM2 for process management
   sudo npm install -g pm2
   
   # Start the app with PM2
   pm2 start server.js --name "board-server"
   
   # Make it start on boot
   pm2 startup
   pm2 save
   ```

## Network Access

The server automatically binds to `0.0.0.0:3000`, making it accessible from any device on your local network. When you start the server, it will display both the local and LAN IP addresses.

## File Structure

```
BoardServer/
├── server.js           # Main server file
├── package.json        # Dependencies
├── public/
│   └── index.html     # Web interface
├── board_data.json    # Auto-generated data file
└── README.md          # This file
```

## Technical Details

- **Backend**: Node.js with Express
- **Frontend**: Vanilla HTML/CSS/JavaScript
- **Storage**: JSON file-based storage
- **Network**: Accessible over LAN
- **Dependencies**: Express, body-parser

## Browser Compatibility

Works on all modern browsers including:
- Chrome/Chromium
- Firefox
- Safari
- Edge

## Mobile Friendly

The interface is responsive and works well on tablets and smartphones.

## Troubleshooting

### Can't access from other devices
- Make sure your Raspberry Pi and other devices are on the same network
- Check if the Pi's firewall is blocking port 3000
- Try accessing using the Pi's IP address directly

### Server won't start
- Make sure Node.js is installed: `node --version`
- Make sure you ran `npm install`
- Check if port 3000 is already in use

### Data not saving
- Check file permissions in the BoardServer directory
- Make sure the server has write access to create `board_data.json`

## License

MIT License - feel free to modify and use as needed!
