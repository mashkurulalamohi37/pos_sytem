# Building Windows .exe from Android Studio

This guide shows you how to build a Windows .exe executable directly from Android Studio.

## Prerequisites

1. **Android Studio** installed (you already have it ✅)
2. **Flutter Plugin** installed in Android Studio
3. **Visual Studio** installed with "Desktop development with C++" workload
   - Download: https://visualstudio.microsoft.com/downloads/
   - Select: "Desktop development with C++" during installation

## Step 1: Configure Android Studio for Windows Desktop

### 1.1 Install Flutter Plugin (if not already installed)

1. Open Android Studio
2. Go to **File** → **Settings** (or **Android Studio** → **Preferences** on Mac)
3. Navigate to **Plugins**
4. Search for "Flutter"
5. Install the **Flutter plugin** (Dart plugin will be installed automatically)
6. Restart Android Studio

### 1.2 Configure Flutter SDK

1. Go to **File** → **Settings** → **Languages & Frameworks** → **Flutter**
2. Set **Flutter SDK path** to your Flutter installation
   - Usually: `C:\src\flutter` or where you installed Flutter
3. Click **Apply** and **OK**

### 1.3 Enable Windows Desktop Support

1. In Android Studio, open your project
2. Go to **File** → **Settings** → **Languages & Frameworks** → **Flutter**
3. Under **Additional run args**, you can leave it empty
4. Make sure **Enable Flutter web support** is checked (if needed)
5. Click **Apply**

## Step 2: Open Your Project in Android Studio

1. **Open Android Studio**
2. Click **Open** or **File** → **Open**
3. Navigate to your project folder: `D:\aronium`
4. Click **OK**

Android Studio will:
- Index the project
- Detect Flutter project
- Show Flutter device selector

## Step 3: Configure Run/Debug Configurations

### 3.1 Add Windows Desktop Configuration

1. Click the **Run/Debug Configuration** dropdown (top toolbar)
2. Click **Edit Configurations...**
3. Click the **+** button → Select **Flutter**
4. Configure:
   - **Name**: `Windows Desktop`
   - **Dart entrypoint**: `lib/main.dart`
   - **Additional run args**: Leave empty
5. Click **OK**

### 3.2 Select Windows as Target Device

1. In the top toolbar, find the **Device Selector** dropdown
2. Click it and look for **Windows (desktop)**
3. If you don't see it:
   - Click **Device Manager** (or **Tools** → **Device Manager**)
   - Click **New Device**
   - Select **Windows Desktop**
   - Click **Finish**

## Step 4: Build Windows .exe from Android Studio

### Option A: Build and Run (Development)

1. Select **Windows (desktop)** from device selector
2. Click the **Run** button (green play icon) or press **Shift + F10**
3. Android Studio will:
   - Build the app
   - Launch it in a Windows window
   - Enable hot reload for development

### Option B: Build Release .exe

1. Select **Windows (desktop)** from device selector
2. Go to **Build** → **Flutter** → **Build Windows (Release)**
   - Or use the terminal in Android Studio:
     ```
     flutter build windows --release
     ```
3. The .exe will be created at:
   ```
   build\windows\x64\runner\Release\aronium.exe
   ```

## Step 5: Using Android Studio Terminal

Android Studio has a built-in terminal:

1. Click **View** → **Tool Windows** → **Terminal**
   - Or click the **Terminal** tab at the bottom
2. Run Flutter commands:
   ```bash
   # Build release
   flutter build windows --release
   
   # Check devices
   flutter devices
   
   # Run on Windows
   flutter run -d windows
   ```

## Step 6: View Build Output

1. After building, click **View** → **Tool Windows** → **Build**
2. Or click the **Build** tab at the bottom
3. You'll see the build progress and any errors

## Troubleshooting

### Issue: "Windows (desktop)" not showing in device selector

**Solution:**
1. Make sure Visual Studio is installed with C++ workload
2. Run in terminal: `flutter doctor`
3. Verify Windows desktop is enabled: `flutter config --enable-windows-desktop`
4. Restart Android Studio

### Issue: Build fails with CMake errors

**Solution:**
1. Make sure Visual Studio is installed correctly
2. In Android Studio terminal, run:
   ```bash
   flutter clean
   flutter pub get
   flutter build windows --release
   ```

### Issue: Flutter plugin not found

**Solution:**
1. Go to **File** → **Settings** → **Plugins**
2. Search for "Flutter"
3. Install Flutter plugin
4. Restart Android Studio

### Issue: Can't find Flutter SDK

**Solution:**
1. Go to **File** → **Settings** → **Languages & Frameworks** → **Flutter**
2. Click the folder icon next to **Flutter SDK path**
3. Navigate to your Flutter installation folder
4. Click **OK**

## Quick Reference: Android Studio Shortcuts

- **Run**: `Shift + F10` (or green play button)
- **Debug**: `Shift + F9` (or bug icon)
- **Stop**: `Ctrl + F2` (or red square)
- **Hot Reload**: `Ctrl + \` (or lightning bolt icon)
- **Hot Restart**: `Ctrl + Shift + \`
- **Open Terminal**: `Alt + F12`

## Build Configurations

### Debug Build (Development)
- **How**: Click Run button or `Shift + F10`
- **Location**: `build\windows\x64\runner\Debug\`
- **Features**: Hot reload, debugging, larger file size

### Release Build (Distribution)
- **How**: **Build** → **Flutter** → **Build Windows (Release)**
- **Location**: `build\windows\x64\runner\Release\`
- **Features**: Optimized, smaller size, no debugging

### Profile Build (Performance Testing)
- **How**: Terminal: `flutter build windows --profile`
- **Location**: `build\windows\x64\runner\Profile\`
- **Features**: Performance profiling enabled

## Viewing the .exe Location

After building, you can view the .exe in Android Studio:

1. Click **Project** tab (left sidebar)
2. Navigate to: `build → windows → x64 → runner → Release`
3. Right-click `aronium.exe` → **Show in Explorer** (Windows)
4. Or **Reveal in Finder** (Mac)

## Creating Distributable Package

After building the release .exe:

1. Navigate to: `build\windows\x64\runner\Release`
2. Copy the **entire Release folder**
3. Zip it for distribution
4. Users need all files in the Release folder (not just the .exe)

## Android Studio vs Command Line

| Feature | Android Studio | Command Line |
|---------|---------------|--------------|
| Build Release | Build menu | `flutter build windows --release` |
| Hot Reload | ✅ Built-in | ✅ Available |
| Debugging | ✅ Full debugger | Basic |
| Device Manager | ✅ GUI | Command line |
| Error Highlighting | ✅ IDE integration | Terminal output |
| Code Completion | ✅ Yes | No |

## Recommended Workflow

1. **Development**: Use Android Studio with Run button (hot reload)
2. **Testing**: Use Android Studio debugger
3. **Release Build**: Use **Build** → **Flutter** → **Build Windows (Release)**
4. **Distribution**: Package the Release folder

## Next Steps

1. ✅ Open project in Android Studio
2. ✅ Select Windows (desktop) as device
3. ✅ Click Run to test
4. ✅ Build → Flutter → Build Windows (Release) for .exe
5. ✅ Package Release folder for distribution

## Tips

- Use **Run** for development (faster, hot reload)
- Use **Build Windows (Release)** for final .exe
- Check **Build** tab for errors
- Use **Terminal** tab for Flutter commands
- **Project** tab shows file structure

For more help, see:
- [Flutter Desktop Documentation](https://docs.flutter.dev/platform-integration/windows)
- [Android Studio Flutter Guide](https://docs.flutter.dev/tools/android-studio)

