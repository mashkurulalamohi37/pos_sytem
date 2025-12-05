# Building Windows .exe Executable

This guide will help you build a Windows .exe executable from your Flutter app.

## Prerequisites

### Required: Visual Studio

You need **Visual Studio** with the "Desktop development with C++" workload to build Windows apps.

#### Install Visual Studio:

1. **Download Visual Studio Community** (Free):
   - Go to: https://visualstudio.microsoft.com/downloads/
   - Download "Visual Studio Community" (free version)

2. **During Installation, Select:**
   - ✅ **Desktop development with C++** workload
   - ✅ All default components (CMake, Windows SDK, etc.)

3. **Verify Installation:**
   ```bash
   flutter doctor
   ```
   You should see:
   ```
   [√] Visual Studio - develop Windows apps
   ```

## Building the .exe

### Step 1: Verify Windows Support

```bash
flutter doctor
```

Make sure Windows desktop support shows as enabled.

### Step 2: Build Release Executable

```bash
# Build optimized release version
flutter build windows --release
```

This will create the executable in:
```
build\windows\x64\runner\Release\aronium.exe
```

### Step 3: Test the Executable

1. Navigate to the build folder:
   ```bash
   cd build\windows\x64\runner\Release
   ```

2. Double-click `aronium.exe` to run it

## Creating a Distributable Package

The built .exe requires supporting files. Here's how to create a complete package:

### Option 1: Manual Package (Recommended)

1. **Build the app:**
   ```bash
   flutter build windows --release
   ```

2. **Copy the entire Release folder:**
   - Location: `build\windows\x64\runner\Release`
   - This folder contains:
     - `aronium.exe` (main executable)
     - `flutter_windows.dll` (Flutter runtime)
     - `data\` folder (app assets and code)
     - Other required DLLs

3. **Zip the Release folder:**
   - Right-click the `Release` folder
   - Select "Send to" > "Compressed (zipped) folder"
   - Name it: `Aronium_POS_v1.0.0.zip`

4. **Distribute:**
   - Users can extract the zip and run `aronium.exe`
   - All files must be in the same folder

### Option 2: Using Inno Setup (Professional Installer)

Create a professional installer with Inno Setup:

1. **Download Inno Setup:**
   - https://jrsoftware.org/isdl.php

2. **Create Installer Script:**
   ```inno
   [Setup]
   AppName=Aronium POS
   AppVersion=1.0.0
   DefaultDirName={pf}\Aronium POS
   DefaultGroupName=Aronium POS
   OutputDir=installer
   OutputBaseFilename=Aronium_POS_Setup
   Compression=lzma
   SolidCompression=yes

   [Files]
   Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

   [Icons]
   Name: "{group}\Aronium POS"; Filename: "{app}\aronium.exe"
   Name: "{commondesktop}\Aronium POS"; Filename: "{app}\aronium.exe"
   ```

3. **Build Installer:**
   - Open the script in Inno Setup Compiler
   - Click "Build" > "Compile"

### Option 3: Using NSIS (Nullsoft Scriptable Install System)

Another popular installer option:

1. **Download NSIS:**
   - https://nsis.sourceforge.io/Download

2. **Create installer script** (similar to Inno Setup)

## Build Commands Reference

### Development Build (with hot reload)
```bash
flutter run -d windows
```

### Release Build
```bash
flutter build windows --release
```

### Debug Build
```bash
flutter build windows --debug
```

### Profile Build (for performance testing)
```bash
flutter build windows --profile
```

## File Structure After Build

```
build\windows\x64\runner\Release\
├── aronium.exe              # Main executable
├── flutter_windows.dll      # Flutter runtime
├── data\                    # App assets and code
│   ├── flutter_assets\
│   └── app.so
├── *.dll                    # Required libraries
└── ...                      # Other dependencies
```

## Optimizing the Build

### Reduce File Size

1. **Tree shake unused code:**
   ```bash
   flutter build windows --release --tree-shake-icons
   ```

2. **Remove debug symbols:**
   - Already done in release builds

### Performance Optimization

The release build is already optimized with:
- ✅ Code minification
- ✅ Dead code elimination
- ✅ Optimized compilation

## Troubleshooting

### Issue: "Visual Studio not found"

**Solution:**
1. Install Visual Studio Community
2. Select "Desktop development with C++" workload
3. Restart your computer
4. Run `flutter doctor` again

### Issue: Build fails with CMake errors

**Solution:**
```bash
# Clean build
flutter clean
flutter pub get
flutter build windows --release
```

### Issue: .exe won't run on another computer

**Solution:**
- Make sure you distribute the **entire Release folder**, not just the .exe
- All DLLs and the data folder are required
- The target computer must have Windows 10 or later

### Issue: Antivirus flags the .exe

**Solution:**
- This is common with unsigned executables
- You can:
  1. Sign the executable with a code signing certificate
  2. Submit to antivirus vendors for whitelisting
  3. Use a trusted installer (Inno Setup, NSIS)

## Code Signing (Optional, for Distribution)

To avoid "Unknown Publisher" warnings:

1. **Get a Code Signing Certificate:**
   - Purchase from: DigiCert, Sectigo, etc.
   - Or use self-signed for internal use

2. **Sign the executable:**
   ```bash
   signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com aronium.exe
   ```

## Distribution Checklist

- [ ] Build release version: `flutter build windows --release`
- [ ] Test the .exe on a clean Windows machine
- [ ] Package all required files (entire Release folder)
- [ ] Create installer (optional but recommended)
- [ ] Test installer on clean machine
- [ ] Code sign executable (optional)
- [ ] Create user documentation

## Quick Start Commands

```bash
# 1. Build the executable
flutter build windows --release

# 2. Navigate to build folder
cd build\windows\x64\runner\Release

# 3. Test it
.\aronium.exe

# 4. Package for distribution
# Zip the entire Release folder or create installer
```

## File Size Expectations

- **Release build**: ~50-100 MB (includes all dependencies)
- **Zipped package**: ~30-60 MB (compressed)
- **Installer**: ~40-70 MB (with compression)

## System Requirements

**Minimum Requirements:**
- Windows 10 (64-bit) or later
- 4 GB RAM
- 200 MB free disk space

**Recommended:**
- Windows 11
- 8 GB RAM
- 500 MB free disk space

## Next Steps

1. Install Visual Studio if not already installed
2. Build the release version
3. Test the executable
4. Create a distributable package
5. Distribute to users

For questions or issues, refer to:
- [Flutter Windows Desktop Documentation](https://docs.flutter.dev/platform-integration/windows)
- [Visual Studio Documentation](https://docs.microsoft.com/visualstudio/)

