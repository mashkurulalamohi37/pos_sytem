# Installing Visual Studio for Windows Desktop Development

Visual Studio is required to build Windows .exe files from Flutter. Follow these steps to install it.

## Quick Installation Guide

### Step 1: Download Visual Studio Community (Free)

1. **Go to the download page:**
   - Visit: https://visualstudio.microsoft.com/downloads/
   - Or direct link: https://visualstudio.microsoft.com/vs/community/

2. **Download Visual Studio Community:**
   - Click the **"Free download"** button under "Community"
   - The installer will download (about 3-5 MB)

### Step 2: Run the Installer

1. **Run the downloaded installer:**
   - File name: `vs_community.exe` or similar
   - Double-click to run

2. **Wait for the installer to load:**
   - It will download and prepare components

### Step 3: Select Required Workload

**IMPORTANT:** You must select the correct workload!

1. **In the Visual Studio Installer window:**
   - Look for the **"Workloads"** tab (should be selected by default)

2. **Find and CHECK this workload:**
   - ✅ **"Desktop development with C++"**
   - It's usually in the top section

3. **Verify these components are selected (they should be by default):**
   - ✅ MSVC v143 - VS 2022 C++ x64/x86 build tools
   - ✅ Windows 10/11 SDK (latest version)
   - ✅ CMake tools for Windows
   - ✅ C++ core features

### Step 4: Install

1. **Click the "Install" button** (bottom right)
2. **Wait for installation:**
   - This can take 15-30 minutes depending on your internet speed
   - Installation size: ~6-8 GB
   - You can continue using your computer during installation

3. **Restart your computer** when prompted (recommended)

### Step 5: Verify Installation

1. **Open Command Prompt or PowerShell**

2. **Run Flutter Doctor:**
   ```bash
   flutter doctor
   ```

3. **You should see:**
   ```
   [√] Visual Studio - develop Windows apps
   ```

   Instead of:
   ```
   [X] Visual Studio - develop Windows apps
   ```

## Alternative: Minimal Installation

If you want a smaller installation, you can install just the build tools:

1. **Download "Build Tools for Visual Studio":**
   - Go to: https://visualstudio.microsoft.com/downloads/
   - Scroll down to "All downloads"
   - Click "Build Tools for Visual Studio"

2. **Install with C++ build tools:**
   - Select "C++ build tools" workload
   - Install

**Note:** The full Visual Studio Community is recommended for easier troubleshooting.

## Troubleshooting

### Issue: Installer won't start

**Solution:**
- Run as Administrator
- Check Windows updates
- Temporarily disable antivirus

### Issue: Installation fails

**Solution:**
1. Close all programs
2. Run installer as Administrator
3. Check disk space (need at least 10 GB free)
4. Disable antivirus temporarily

### Issue: Flutter doctor still shows error after installation

**Solution:**
1. **Restart your computer** (important!)
2. Open a **new** Command Prompt/PowerShell window
3. Run: `flutter doctor`
4. If still not working, run: `flutter doctor -v` for details

### Issue: Can't find "Desktop development with C++"

**Solution:**
- Make sure you're on the **"Workloads"** tab
- Look in the "Desktop & Mobile" section
- It might be called "Desktop development with C++" or "Desktop development with C++ (v143)"

### Issue: Installation takes too long

**Solution:**
- This is normal! First-time installation can take 20-40 minutes
- Make sure you have a stable internet connection
- You can pause and resume if needed

## What Gets Installed

Visual Studio Community installs:
- ✅ MSVC Compiler (C++ compiler)
- ✅ Windows SDK (Windows development libraries)
- ✅ CMake (build system)
- ✅ Git (version control)
- ✅ Visual Studio IDE (optional, but useful)

**Total size:** ~6-8 GB

## After Installation

Once Visual Studio is installed:

1. **Restart your computer** (recommended)

2. **Verify:**
   ```bash
   flutter doctor
   ```

3. **Build your Windows app:**
   ```bash
   flutter build windows --release
   ```

4. **Or from Android Studio:**
   - **Build** → **Flutter** → **Build Windows (Release)**

## System Requirements

- **Windows 10 version 1903 or higher** (you have Windows 11 ✅)
- **4 GB RAM minimum** (8 GB recommended)
- **10 GB free disk space**
- **Internet connection** for download

## Why Visual Studio is Needed

Flutter Windows apps are compiled to native Windows executables (.exe files). This requires:
- C++ compiler (MSVC)
- Windows SDK
- Build tools (CMake)

Visual Studio provides all of these in one package.

## Next Steps

After installing Visual Studio:

1. ✅ Restart your computer
2. ✅ Run `flutter doctor` to verify
3. ✅ Build your Windows app
4. ✅ Create .exe file

## Quick Checklist

- [ ] Download Visual Studio Community
- [ ] Run installer
- [ ] Select "Desktop development with C++" workload
- [ ] Click Install
- [ ] Wait for installation (15-30 minutes)
- [ ] Restart computer
- [ ] Run `flutter doctor` to verify
- [ ] Build Windows app

## Need Help?

If you encounter issues:
1. Check the Visual Studio installer logs
2. Run `flutter doctor -v` for detailed error messages
3. Make sure you selected the correct workload
4. Try restarting your computer

---

**Download Link:** https://visualstudio.microsoft.com/downloads/

**Installation Time:** 15-30 minutes (depending on internet speed)

**Disk Space Required:** ~6-8 GB

