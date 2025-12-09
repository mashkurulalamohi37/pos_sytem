# Deploy to Vercel - Quick Guide

## Prerequisites
- Vercel account (sign up at https://vercel.com)
- Vercel CLI installed (optional, for command line deployment)

## Method 1: Deploy via Vercel Dashboard (Recommended)

### Step 1: Build the Web App
```bash
flutter build web --release
```

This creates optimized production files in `build/web/`

### Step 2: Deploy to Vercel

#### Option A: Using Vercel Dashboard (Easiest)
1. Go to https://vercel.com/dashboard
2. Click **"Add New Project"**
3. Click **"Import Git Repository"** or **"Deploy from GitHub"**
4. Select your repository: `mashkurulalamohi37/pos_sytem`
5. Configure project:
   - **Framework Preset**: Other
   - **Build Command**: `flutter build web --release`
   - **Output Directory**: `build/web`
   - **Install Command**: Leave empty (Flutter is pre-installed on Vercel)
6. Click **"Deploy"**

#### Option B: Using Vercel CLI
```bash
# Install Vercel CLI (if not installed)
npm install -g vercel

# Login to Vercel
vercel login

# Deploy from the build/web directory
cd build/web
vercel --prod
```

### Step 3: Configure Custom Domain (Optional)
1. Go to your project settings on Vercel
2. Navigate to **"Domains"**
3. Add your custom domain
4. Follow DNS configuration instructions

## Method 2: Manual Deployment

### Step 1: Build for Web
```bash
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit
```

**Build Options:**
- `--web-renderer canvaskit`: Better performance, larger bundle
- `--web-renderer html`: Smaller bundle, faster load
- `--web-renderer auto`: Automatic selection (default)

### Step 2: Upload to Vercel

1. **Zip the build folder**:
   - Navigate to `build/web/`
   - Select all files
   - Create a zip file

2. **Upload via Vercel Dashboard**:
   - Go to https://vercel.com/dashboard
   - Click **"Add New Project"**
   - Click **"Deploy"** → **"Upload Files"**
   - Upload the zip file
   - Click **"Deploy"**

## Method 3: Continuous Deployment (GitHub Integration)

### Step 1: Push Changes to GitHub
```bash
git add .
git commit -m "Enhanced web UI for products and forms"
git push origin main
```

### Step 2: Connect Vercel to GitHub
1. Go to https://vercel.com/dashboard
2. Click **"Add New Project"**
3. Click **"Import Git Repository"**
4. Select your GitHub repository
5. Configure build settings:
   ```
   Framework Preset: Other
   Build Command: flutter build web --release
   Output Directory: build/web
   Root Directory: ./
   ```
6. Click **"Deploy"**

### Step 3: Auto-Deploy on Push
- Every push to `main` branch will trigger automatic deployment
- Pull requests create preview deployments

## Vercel Configuration

### vercel.json (Already configured)
Located at `web/vercel.json`:
```json
{
  "routes": [
    { "handle": "filesystem" },
    { "src": "/.*", "dest": "/index.html" }
  ]
}
```

This ensures Flutter's client-side routing works correctly.

### Environment Variables (If needed)
1. Go to Vercel Dashboard → Your Project → Settings → Environment Variables
2. Add any required environment variables:
   - `FIREBASE_API_KEY`
   - `FIREBASE_PROJECT_ID`
   - etc.

## Build Commands Reference

### Standard Build
```bash
flutter build web --release
```

### Build with Specific Renderer
```bash
# CanvasKit (better performance)
flutter build web --release --web-renderer canvaskit

# HTML (smaller size)
flutter build web --release --web-renderer html

# Auto (default)
flutter build web --release --web-renderer auto
```

### Build with Custom Base URL
```bash
flutter build web --release --base-href /
```

## Deployment Checklist

- [ ] All changes committed to Git
- [ ] Code tested locally (`flutter run -d chrome`)
- [ ] Build completed successfully (`flutter build web --release`)
- [ ] No build errors or warnings
- [ ] Firebase configuration updated (if applicable)
- [ ] Environment variables set in Vercel
- [ ] Custom domain configured (if applicable)
- [ ] SSL certificate active (automatic with Vercel)

## Troubleshooting

### Issue: Build Fails on Vercel
**Solution**: Ensure Flutter is available in Vercel environment
- Vercel has Flutter pre-installed
- Check build logs for specific errors
- Verify `pubspec.yaml` dependencies are compatible

### Issue: Routing Not Working
**Solution**: Verify `vercel.json` configuration
- File should be in `web/` directory
- Routes should redirect to `index.html`

### Issue: Assets Not Loading
**Solution**: Check base href
- Ensure `--base-href /` is set correctly
- Verify assets are in `build/web/assets/`

### Issue: Firebase Not Working
**Solution**: Configure environment variables
- Add Firebase config to Vercel environment variables
- Ensure Firebase is initialized correctly in code

## Post-Deployment Verification

1. **Test the deployed site**:
   - Visit your Vercel URL
   - Test all enhanced features:
     - Products list with enhanced Edit/Delete buttons
     - Add Product form with web layout
     - Navigation and routing
     - Firebase authentication (if applicable)

2. **Check Performance**:
   - Run Lighthouse audit
   - Verify load times
   - Test on different devices

3. **Monitor Logs**:
   - Check Vercel deployment logs
   - Monitor for runtime errors
   - Review analytics

## Quick Deploy Script

Save this as `deploy.bat` in your project root:

```batch
@echo off
echo ========================================
echo  Deploying to Vercel
echo ========================================
echo.

echo [1/4] Cleaning previous build...
call flutter clean

echo [2/4] Getting dependencies...
call flutter pub get

echo [3/4] Building for web...
call flutter build web --release --web-renderer canvaskit

echo [4/4] Deploying to Vercel...
cd build\web
call vercel --prod

echo.
echo ========================================
echo  Deployment Complete!
echo ========================================
```

Then run:
```bash
deploy.bat
```

## Useful Commands

```bash
# Check Flutter web support
flutter doctor

# Analyze build size
flutter build web --release --analyze-size

# Build with verbose output
flutter build web --release --verbose

# Preview build locally
cd build/web
python -m http.server 8000
# Visit http://localhost:8000
```

## Resources

- **Vercel Documentation**: https://vercel.com/docs
- **Flutter Web Deployment**: https://docs.flutter.dev/deployment/web
- **Vercel CLI**: https://vercel.com/docs/cli

---

**Last Updated**: 2025-12-09
**Status**: Ready for deployment
