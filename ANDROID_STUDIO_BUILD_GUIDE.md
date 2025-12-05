# Building Windows .exe from Android Studio - Quick Guide

Your Windows desktop is already configured! ✅

## Quick Steps

### 1. Open Project in Android Studio

1. Open **Android Studio**
2. **File** → **Open** → Select `D:\aronium`
3. Wait for indexing to complete

### 2. Select Windows as Target

1. Look at the **top toolbar** for the device selector dropdown
2. Click it and select **Windows (desktop)**
   - It should show: `Windows (desktop) • windows • windows-x64`

### 3. Build Release .exe

**Method 1: Using Build Menu (Recommended)**
1. Click **Build** → **Flutter** → **Build Windows (Release)**
2. Wait for build to complete
3. Your .exe will be at: `build\windows\x64\runner\Release\aronium.exe`

**Method 2: Using Terminal in Android Studio**
1. Click **View** → **Tool Windows** → **Terminal** (or `Alt + F12`)
2. Run:
   ```bash
   flutter build windows --release
   ```

### 4. Run/Test (Development Mode)

1. Select **Windows (desktop)** from device selector
2. Click the **Run** button (green play icon) or press **Shift + F10**
3. App will launch in a window with hot reload enabled

## Visual Guide

```
Android Studio Toolbar:
┌─────────────────────────────────────────────────────────┐
│ [Run ▶] [Debug 🐛] [Device: Windows (desktop) ▼]      │
└─────────────────────────────────────────────────────────┘

After clicking Run:
- App launches in Windows window
- Hot reload enabled (Ctrl + \)
- See output in Run tab at bottom
```

## Build Output Location

After building release, find your .exe:

```
Project View (Left Sidebar):
aronium/
└── build/
    └── windows/
        └── x64/
            └── runner/
                └── Release/
                    ├── aronium.exe  ← Your executable
                    ├── flutter_windows.dll
                    ├── data/
                    └── *.dll
```

**To view in File Explorer:**
- Right-click `aronium.exe` in Project view
- Select **Show in Explorer** (Windows)

## Keyboard Shortcuts

- **Run**: `Shift + F10`
- **Debug**: `Shift + F9`
- **Stop**: `Ctrl + F2`
- **Hot Reload**: `Ctrl + \`
- **Hot Restart**: `Ctrl + Shift + \`
- **Open Terminal**: `Alt + F12`
- **Build**: `Ctrl + Shift + F9`

## Troubleshooting

### Windows (desktop) not showing in device selector?

1. In Android Studio terminal, run:
   ```bash
   flutter doctor
   ```
2. Make sure Visual Studio is installed
3. Restart Android Studio

### Build fails?

1. Open terminal in Android Studio (`Alt + F12`)
2. Run:
   ```bash
   flutter clean
   flutter pub get
   flutter build windows --release
   ```

### Can't find Flutter SDK?

1. **File** → **Settings** → **Languages & Frameworks** → **Flutter**
2. Set **Flutter SDK path** (usually `C:\src\flutter`)
3. Click **Apply**

## Creating Distributable Package

After building release:

1. Navigate to: `build\windows\x64\runner\Release`
2. **Copy the entire Release folder** (not just the .exe)
3. **Zip it** for distribution
4. Users need all files in the folder

## What You'll See

**During Build:**
- Progress in **Build** tab (bottom)
- Status: "Building Windows application..."
- Time: ~2-5 minutes

**After Build:**
- Success message in Build tab
- .exe file in `build\windows\x64\runner\Release\`

## Next Steps

1. ✅ Open project in Android Studio
2. ✅ Select **Windows (desktop)** from device selector
3. ✅ **Build** → **Flutter** → **Build Windows (Release)**
4. ✅ Find .exe in `build\windows\x64\runner\Release\`
5. ✅ Package Release folder for distribution

That's it! You're ready to build Windows .exe from Android Studio! 🎉

