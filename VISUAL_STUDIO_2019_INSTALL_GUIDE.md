# Visual Studio 2019 Installation Guide for Flutter Windows Development

This guide will help you install Visual Studio 2019, which is required for building Flutter Windows applications.

## Why Visual Studio 2019?

Flutter's Windows desktop support currently expects Visual Studio 2019 (VS 16). While you may have Visual Studio 2022 installed, Flutter specifically looks for the 2019 version when building Windows applications.

## Step 1: Download Visual Studio 2019 Community Edition

1. Go to the Visual Studio 2019 archive download page:
   - https://visualstudio.microsoft.com/vs/older-downloads/
   - Or direct link: https://my.visualstudio.com/Downloads?q=visual%20studio%202019

   > **Note:** You may need to sign in with a free Microsoft account to access these downloads.

2. Find "Visual Studio Community 2019" and click "Download"
   - The installer will be a small file (approximately 1-2 MB)

## Step 2: Run the Installer

1. Run the downloaded installer (e.g., `vs_community.exe`)
2. If prompted by User Account Control, click "Yes" to proceed
3. Wait for the installer to initialize

## Step 3: Select Required Workload

**IMPORTANT:** You must select the correct workload!

1. In the Visual Studio Installer window, select the "Workloads" tab
2. Check the box for "Desktop development with C++" 
   - This is essential for Flutter Windows development
   - It should be in the "Desktop & Mobile" section

3. Ensure these components are selected (they should be by default):
   - MSVC v142 - VS 2019 C++ x64/x86 build tools
   - Windows 10 SDK
   - C++ CMake tools for Windows
   - C++ core features

## Step 4: Choose Installation Location

1. Click on the "Installation locations" tab if you want to change the default install path
2. You can keep the default location if disk space is not a concern
3. **Note:** Visual Studio 2019 can coexist with Visual Studio 2022 on the same machine

## Step 5: Install

1. Click the "Install" button in the bottom right
2. Wait for the installation to complete
   - This may take 15-30 minutes depending on your internet speed
   - The installer will download approximately 4-6 GB of data

3. Restart your computer when prompted

## Step 6: Verify Installation

After installation is complete:

1. Open Command Prompt or PowerShell
2. Run: `flutter doctor -v`
3. Verify that Visual Studio is now detected:
   ```
   [√] Visual Studio - develop Windows apps
       • Visual Studio Community 2019 version 16.x.x
   ```

## Step 7: Try Building Your Flutter Windows App

Once Visual Studio 2019 is installed:

1. Navigate to your Flutter project directory
2. Run: `flutter build windows --release`
3. If successful, your Windows executable will be located at:
   ```
   build\windows\x64\runner\Release\aronium.exe
   ```

## Troubleshooting

### Issue: Visual Studio Still Not Detected

If Flutter still cannot find Visual Studio after installation:

1. Make sure you selected the "Desktop development with C++" workload
2. Try restarting your computer
3. Run: `flutter config --clear-features`
4. Run: `flutter config --enable-windows-desktop`
5. Try building again

### Issue: Build Fails with CMake Errors

If you encounter CMake errors:

1. Run: `flutter clean`
2. Run: `flutter pub get`
3. Try building again: `flutter build windows --release`

### Issue: Multiple Visual Studio Versions Conflict

If you have both VS 2019 and VS 2022 installed and encounter conflicts:

1. In your Flutter project, run: `flutter clean`
2. Delete the `build\windows` directory manually
3. Try building again

## System Requirements

- Windows 10 or later (64-bit)
- 8 GB RAM minimum (16 GB recommended)
- 8 GB available disk space
- 1.8 GHz processor or faster

## Next Steps

After installing Visual Studio 2019, you can:

1. Build your Flutter Windows application
2. Create a distribution package
3. Test your application on Windows

For more information, see the [Flutter Windows documentation](https://docs.flutter.dev/platform-integration/windows/building).
