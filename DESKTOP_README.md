# Aronium POS - Desktop Version

This guide helps you set up and run the desktop version of Aronium POS on Windows.

## Prerequisites

1. **Flutter SDK** (3.8.1 or higher)
2. **Visual Studio 2019** with "Desktop development with C++" workload
   - See [VISUAL_STUDIO_2019_INSTALL_GUIDE.md](VISUAL_STUDIO_2019_INSTALL_GUIDE.md) for installation instructions
   - Flutter Windows build specifically requires Visual Studio 2019
3. **Git** for version control

## Building the Desktop App

### Option 1: Using the Build Script (Recommended)

1. Run the build script:
   ```
   build_windows_vs2019.bat
   ```

2. Follow the prompts in the console

### Option 2: Manual Build

1. Get dependencies:
   ```
   flutter pub get
   ```

2. Build the Windows app:
   ```
   flutter build windows --release
   ```

3. Find the executable at:
   ```
   build\windows\x64\runner\Release\aronium.exe
   ```

## Running the App

1. Navigate to the Release folder:
   ```
   cd build\windows\x64\runner\Release
   ```

2. Run the executable:
   ```
   aronium.exe
   ```

## Creating a Distribution Package

### Simple ZIP Package

1. Navigate to the build folder:
   ```
   cd build\windows\x64\runner
   ```

2. Zip the entire Release folder
   - This folder contains the executable and all required DLLs and assets

### Professional Installer (Optional)

For a more professional installation experience, you can create an installer using Inno Setup:

1. Download and install [Inno Setup](https://jrsoftware.org/isdl.php)

2. Create a script file (e.g., `installer.iss`) with the following content:
   ```
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

3. Compile the script with Inno Setup to create your installer

## Desktop-Specific Features

The desktop version of Aronium POS includes:

1. **Optimized UI** for larger screens and mouse/keyboard input
2. **File saving** directly to the file system
3. **Window size management** for better desktop experience
4. **Keyboard shortcuts** for common operations

## Troubleshooting

### Common Issues

1. **Build fails with CMake errors**
   - Make sure Visual Studio is installed with the "Desktop development with C++" workload
   - Try running `flutter clean` and then `flutter pub get` before building again

2. **Window size plugin errors**
   - Make sure you have the latest Flutter SDK
   - Try running `flutter pub get` to ensure all dependencies are properly resolved

3. **Firebase initialization errors**
   - Ensure your Firebase configuration is properly set up for desktop platforms

### Getting Help

If you encounter issues:
1. Run `flutter doctor -v` to check your setup
2. Check the Flutter logs for detailed error messages
3. Consult the [Flutter Desktop documentation](https://docs.flutter.dev/platform-integration/windows)
