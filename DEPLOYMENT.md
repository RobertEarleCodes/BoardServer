# Global Deployment Guide

## 🌍 Making Your BoardServer Globally Accessible

Your BoardServer can now run in different modes:

### Local Mode (Default)
```bash
npm start
# or
npm run start:local
```
- Accessible only on your local network
- Safe for development and local use

### Global Mode (Internet Access)
```bash
npm run start:global
# or
NODE_ENV=production npm start
```
- Accessible from anywhere on the internet
- Includes security headers and rate limiting

## 🚀 Deployment Options

### Option 1: Cloud Platforms

#### Heroku
```bash
# Install Heroku CLI, then:
heroku create your-board-server
git push heroku main
```

#### Railway
```bash
# Connect your GitHub repo to Railway
# Set environment variable: NODE_ENV=production
```

#### DigitalOcean App Platform
```bash
# Connect your GitHub repo
# Set environment variable: NODE_ENV=production
```

### Option 2: VPS/Server Deployment

#### Prerequisites
```bash
# Install Node.js on your server
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 for process management
sudo npm install -g pm2
```

#### Deploy
```bash
# Clone your repository
git clone https://github.com/RobertEarleCodes/BoardServer.git
cd BoardServer

# Install dependencies
npm install

# Start with PM2
NODE_ENV=production pm2 start server.js --name "board-server"

# Save PM2 configuration
pm2 save
pm2 startup
```

### Option 3: Domain & DNS Setup

1. **Get a domain name** (example.com)
2. **Point DNS to your server IP**
3. **Set up reverse proxy** (nginx/Apache)
4. **Add SSL certificate** (Let's Encrypt)

#### Nginx Configuration Example
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🔒 Security Considerations

When running globally, the server automatically enables:
- Security headers (XSS protection, content type options)
- Rate limiting (100 requests per minute per IP)
- Frame options to prevent clickjacking

### Additional Security Recommendations:
1. **Use HTTPS** in production
2. **Set up firewall rules**
3. **Regular security updates**
4. **Monitor access logs**
5. **Consider authentication** for sensitive operations

## 🌐 Environment Variables

Create a `.env` file for production:
```bash
NODE_ENV=production
HOST=0.0.0.0
PORT=3000
```

## 📊 Monitoring

Check your server status:
```bash
# If using PM2
pm2 status
pm2 logs board-server

# Check process
ps aux | grep node

# Check port
netstat -tlnp | grep :3000
```

## 🔧 Troubleshooting

### Common Issues:
- **Port in use**: Change PORT environment variable
- **Permission denied**: Use ports > 1024 or run with sudo
- **Firewall blocking**: Open port in firewall settings
- **Domain not resolving**: Check DNS configuration

### Quick Tests:
```bash
# Test local connection
curl http://localhost:3000

# Test external connection (replace with your IP)
curl http://your-server-ip:3000
```
