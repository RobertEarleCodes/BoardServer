const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs');
const os = require('os');
const multer = require('multer');

const app = express();
const PORT = 3000;

// Configure multer for image uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    // Use timestamp to avoid filename conflicts
    const timestamp = Date.now();
    const ext = path.extname(file.originalname);
    cb(null, `board-image-${timestamp}${ext}`);
  }
});

const upload = multer({ 
  storage: storage,
  fileFilter: function (req, file, cb) {
    // Accept only image files
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  },
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Middleware
app.use(bodyParser.json());
app.use(express.static('public'));
app.use('/uploads', express.static('uploads')); // Serve uploaded images

// Data storage file
const DATA_FILE = 'board_data.json';

// Initialize data structure
let boardData = {
  boards: [], // Array of board configurations (image + zones)
  currentBoard: null, // Currently selected board ID
  routes: [] // Routes are tied to the current board
};

// Load existing data
function loadData() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE, 'utf8');
      const loadedData = JSON.parse(data);
      
      // Migrate old data structure to new structure
      if (loadedData.zones && !loadedData.boards) {
        console.log('Migrating old data structure...');
        
        // Create a board from old data if it exists
        if (loadedData.boardImage && loadedData.zones.length > 0) {
          const boardId = Date.now().toString();
          boardData.boards = [{
            id: boardId,
            name: `Migrated Board`,
            imagePath: `/${loadedData.boardImage}`,
            zones: loadedData.zones,
            createdAt: new Date().toISOString()
          }];
          boardData.currentBoard = boardId;
          
          // Migrate routes
          if (loadedData.routes) {
            boardData.routes = loadedData.routes.map(route => ({
              ...route,
              boardId: boardId,
              createdAt: new Date().toISOString()
            }));
          }
        } else {
          // Initialize empty structure
          boardData.boards = [];
          boardData.currentBoard = null;
          boardData.routes = [];
        }
        
        // Save migrated data
        saveData();
        console.log('Data migration completed');
      } else {
        // Use new data structure
        boardData = loadedData;
      }
      
      // Ensure all required properties exist
      if (!boardData.boards) boardData.boards = [];
      if (!boardData.routes) boardData.routes = [];
      if (!boardData.currentBoard) boardData.currentBoard = null;
      
      console.log('Loaded board data successfully');
    }
  } catch (error) {
    console.log('No existing data found or error loading, starting fresh');
    boardData = {
      boards: [],
      currentBoard: null,
      routes: []
    };
  }
}

// Save data
function saveData() {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(boardData, null, 2));
    console.log('Data saved successfully');
  } catch (error) {
    console.error('Error saving data:', error);
  }
}

// Get local IP address
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const interface of interfaces[name]) {
      // Skip internal and non-IPv4 addresses
      if (interface.family === 'IPv4' && !interface.internal) {
        return interface.address;
      }
    }
  }
  return 'localhost';
}

// Routes
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Get all data
app.get('/api/data', (req, res) => {
  res.json(boardData);
});

// Get current board data
app.get('/api/current-board', (req, res) => {
  if (!boardData.currentBoard) {
    return res.json({ board: null, routes: [] });
  }
  
  const board = boardData.boards.find(b => b.id === boardData.currentBoard);
  const routes = boardData.routes.filter(r => r.boardId === boardData.currentBoard);
  
  res.json({ 
    board: board || null,
    routes: routes
  });
});

// Save zones for current board
app.post('/api/zones', (req, res) => {
  const { zones } = req.body;
  
  if (!boardData.currentBoard) {
    return res.status(400).json({ success: false, error: 'No board selected' });
  }
  
  const board = boardData.boards.find(b => b.id === boardData.currentBoard);
  if (!board) {
    return res.status(400).json({ success: false, error: 'Board not found' });
  }
  
  board.zones = zones;
  saveData();
  res.json({ success: true });
});

// Save route
app.post('/api/routes', (req, res) => {
  const { name, selectedZones } = req.body;
  
  if (!boardData.currentBoard) {
    return res.status(400).json({ success: false, error: 'No board selected' });
  }
  
  // Check if route name already exists for this board
  const existingRouteIndex = boardData.routes.findIndex(route => 
    route.name === name && route.boardId === boardData.currentBoard
  );
  
  const routeData = { 
    name, 
    zones: selectedZones, 
    boardId: boardData.currentBoard,
    createdAt: new Date().toISOString()
  };
  
  if (existingRouteIndex !== -1) {
    // Update existing route
    boardData.routes[existingRouteIndex] = routeData;
  } else {
    // Add new route
    boardData.routes.push(routeData);
  }
  
  saveData();
  res.json({ success: true });
});

// Upload board image and create new board
app.post('/api/upload-image', upload.single('boardImage'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file uploaded' });
    }
    
    // Ensure boards array exists
    if (!boardData.boards) {
      boardData.boards = [];
    }
    
    // Delete old board image if replacing current board
    if (boardData.currentBoard) {
      const currentBoard = boardData.boards.find(b => b.id === boardData.currentBoard);
      if (currentBoard && currentBoard.imagePath) {
        const oldImagePath = path.join(__dirname, currentBoard.imagePath.substring(1)); // Remove leading slash
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath);
        }
      }
    }
    
    // Create new board configuration
    const boardId = Date.now().toString();
    const newBoard = {
      id: boardId,
      name: `Board ${new Date().toLocaleDateString()}`,
      imagePath: `/uploads/${req.file.filename}`,
      zones: [],
      createdAt: new Date().toISOString()
    };
    
    // Replace current board or add new one
    if (boardData.currentBoard) {
      const index = boardData.boards.findIndex(b => b.id === boardData.currentBoard);
      if (index !== -1) {
        boardData.boards[index] = newBoard;
      } else {
        boardData.boards.push(newBoard);
      }
    } else {
      boardData.boards.push(newBoard);
    }
    
    boardData.currentBoard = boardId;
    
    // Clear routes when board changes (routes for old board are preserved)
    // Routes are now tied to specific boards
    
    saveData();
    
    res.json({ 
      success: true, 
      board: newBoard
    });
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({ success: false, error: 'Failed to upload image: ' + error.message });
  }
});

// Delete current board
app.delete('/api/board-image', (req, res) => {
  try {
    if (!boardData.currentBoard) {
      return res.json({ success: true });
    }
    
    const board = boardData.boards.find(b => b.id === boardData.currentBoard);
    if (board && board.imagePath) {
      const imagePath = path.join(__dirname, board.imagePath.substring(1));
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }
    
    // Remove board and its routes
    boardData.boards = boardData.boards.filter(b => b.id !== boardData.currentBoard);
    boardData.routes = boardData.routes.filter(r => r.boardId !== boardData.currentBoard);
    boardData.currentBoard = null;
    
    saveData();
    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting board:', error);
    res.status(500).json({ success: false, error: 'Failed to delete board' });
  }
});

// Delete route
app.delete('/api/routes/:name', (req, res) => {
  const routeName = req.params.name;
  
  if (!boardData.currentBoard) {
    return res.status(400).json({ success: false, error: 'No board selected' });
  }
  
  boardData.routes = boardData.routes.filter(route => 
    !(route.name === routeName && route.boardId === boardData.currentBoard)
  );
  
  saveData();
  res.json({ success: true });
});

// Start server
loadData();

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
  console.log('Created uploads directory');
}

app.listen(PORT, '0.0.0.0', () => {
  const localIP = getLocalIP();
  console.log('='.repeat(50));
  console.log('Board Server Started Successfully!');
  console.log('='.repeat(50));
  console.log(`Local access: http://localhost:${PORT}`);
  console.log(`LAN access: http://${localIP}:${PORT}`);
  console.log('='.repeat(50));
  console.log('The server is accessible from any device on your local network');
  console.log('Use Ctrl+C to stop the server');
});
