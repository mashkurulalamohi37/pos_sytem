# Quick Visual Studio Installation Guide

## The Problem
```
[X] Visual Studio - develop Windows apps
    X Visual Studio not installed
```

## The Solution (5 Steps)

### 1. Download
- Go to: **https://visualstudio.microsoft.com/downloads/**
- Click **"Free download"** under **Community**

### 2. Install
- Run the downloaded installer
- Wait for it to load

### 3. Select Workload
- On the **"Workloads"** tab
- ✅ **CHECK** "Desktop development with C++"
- (Keep all default components checked)

### 4. Install
- Click **"Install"** button
- Wait 15-30 minutes
- **Restart your computer** when done

### 5. Verify
```bash
flutter doctor
```

Should show:
```
[√] Visual Studio - develop Windows apps
```

## Then Build Your App

```bash
flutter build windows --release
```

Or from Android Studio:
- **Build** → **Flutter** → **Build Windows (Release)**

---

**Download:** https://visualstudio.microsoft.com/downloads/

**Time:** 15-30 minutes

**Size:** ~6-8 GB

