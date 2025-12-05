# How to Run Web Version on Another Device

This guide shows you how to access your Aronium POS web app from other devices.

## Method 1: Local Network Access (Development/Testing)

This method allows you to run the app on your computer and access it from other devices on the same Wi-Fi network.

### Step 1: Find Your Computer's IP Address

#### On Windows:
1. Open Command Prompt or PowerShell
2. Run: `ipconfig`
3. Look for "IPv4 Address" under your active network adapter
   - Example: `192.168.1.100`

#### On Mac/Linux:
1. Open Terminal
2. Run: `ifconfig` or `ip addr`
3. Look for your network interface (usually `en0` or `wlan0`)
   - Example: `192.168.1.100`

### Step 2: Run Flutter Web with Network Access

```bash
# Run with host binding to allow network access
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080
```

Or if you want to specify your IP address:

```bash
# Replace 192.168.1.100 with your actual IP
flutter run -d chrome --web-hostname 192.168.1.100 --web-port 8080
```

### Step 3: Access from Another Device

1. Make sure both devices are on the **same Wi-Fi network**
2. On the other device, open a web browser
3. Enter your computer's IP address with the port:
   ```
   http://192.168.1.100:8080
   ```
   (Replace `192.168.1.100` with your actual IP address)

### Troubleshooting Local Network Access

**Issue: Can't access from other device**
- ✅ Check firewall settings - allow port 8080
- ✅ Ensure both devices are on the same network
- ✅ Try disabling Windows Firewall temporarily for testing
- ✅ Check if your router blocks device-to-device communication

**Windows Firewall Fix:**
```powershell
# Allow Flutter web server through firewall
New-NetFirewallRule -DisplayName "Flutter Web" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

## Method 2: Build and Serve Locally

If you want to serve a production build:

### Step 1: Build the Web App

```bash
# Build optimized web version
flutter build web --release
```

### Step 2: Serve Using a Local Server

#### Option A: Using Python (if installed)

```bash
# Navigate to build directory
cd build/web

# Python 3
python -m http.server 8080

# Python 2
python -m SimpleHTTPServer 8080
```

#### Option B: Using Node.js (if installed)

```bash
# Install http-server globally
npm install -g http-server

# Navigate to build directory
cd build/web

# Start server
http-server -p 8080 -a 0.0.0.0
```

#### Option C: Using PHP (if installed)

```bash
# Navigate to build directory
cd build/web

# Start server
php -S 0.0.0.0:8080
```

### Step 3: Access from Other Device

1. Find your computer's IP address (see Method 1, Step 1)
2. On the other device, open browser and go to:
   ```
   http://YOUR_IP_ADDRESS:8080
   ```

## Method 3: Deploy to Hosting Service (Permanent Solution)

For permanent access from anywhere, deploy to a hosting service.

### Option A: Firebase Hosting (Recommended)

```bash
# 1. Install Firebase CLI (if not installed)
npm install -g firebase-tools

# 2. Login to Firebase
firebase login

# 3. Initialize hosting (if not already done)
firebase init hosting
# Select your project
# Set public directory: build/web
# Configure as single-page app: Yes

# 4. Build and deploy
flutter build web --release
firebase deploy --only hosting
```

Your app will be available at:
- `https://possystem-e1655.web.app`
- Or your custom domain if configured

### Option B: Netlify (Easy Drag & Drop)

1. Build the web app:
   ```bash
   flutter build web --release
   ```

2. Go to [Netlify Drop](https://app.netlify.com/drop)

3. Drag and drop the `build/web` folder

4. Your app will be live immediately with a URL like:
   - `https://random-name-123.netlify.app`

### Option C: Vercel

```bash
# 1. Install Vercel CLI
npm install -g vercel

# 2. Build the app
flutter build web --release

# 3. Deploy
cd build/web
vercel
```

### Option D: GitHub Pages

```bash
# 1. Build with base href
flutter build web --release --base-href "/your-repo-name/"

# 2. Copy build/web contents to docs folder
# 3. Push to GitHub
# 4. Enable GitHub Pages in repository settings
```

## Quick Reference Commands

### Development (Hot Reload)
```bash
# Run on local network
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 8080
```

### Production Build
```bash
# Build optimized version
flutter build web --release

# Build with HTML renderer (smaller bundle)
flutter build web --release --web-renderer html
```

### Serve Built Files
```bash
# Using Python
cd build/web && python -m http.server 8080

# Using Node.js http-server
cd build/web && http-server -p 8080 -a 0.0.0.0

# Using PHP
cd build/web && php -S 0.0.0.0:8080
```

## Security Notes

⚠️ **Important for Local Network Access:**
- Only use on trusted networks
- Don't expose to public internet without proper security
- For production use, deploy to a hosting service with HTTPS

## Troubleshooting

### Port Already in Use
If port 8080 is busy, use a different port:
```bash
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 3000
```

### CORS Issues
If you see CORS errors, make sure:
- Firebase authorized domains include your IP/domain
- You're accessing via HTTP (not file://)

### Firewall Blocking
- Windows: Allow Flutter/Dart through Windows Firewall
- Mac: Allow in System Preferences > Security & Privacy > Firewall

## Recommended Approach

**For Testing/Development:**
- Use Method 1 (Local Network Access) - Quick and easy

**For Production/Public Access:**
- Use Method 3 (Firebase Hosting) - Secure, fast, and free

## Next Steps

After deploying, you can:
- Set up a custom domain
- Enable HTTPS (automatic with Firebase/Netlify/Vercel)
- Configure CDN for better performance
- Set up automatic deployments from Git

