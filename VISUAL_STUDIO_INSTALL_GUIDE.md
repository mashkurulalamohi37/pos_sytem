# Visual Studio Installation Guide for Flutter Windows Development

## Step 1: Download Visual Studio Community 2022

1. Go to: https://visualstudio.microsoft.com/vs/community/
2. Click the "Free download" button under Visual Studio Community 2022

## Step 2: Run the Installer

1. Run the downloaded file (vs_community.exe)
2. Wait for the installer to initialize

## Step 3: Select Required Components

**IMPORTANT:** You must select the correct workload!

1. In the Visual Studio Installer window, select the "Workloads" tab
2. Check the box for "Desktop development with C++" 
3. Ensure these components are selected (they should be by default):
   - MSVC v143 - VS 2022 C++ x64/x86 build tools
   - Windows 10/11 SDK
   - C++ CMake tools for Windows
   - C++ core features

## Step 4: Install

1. Click the "Install" button in the bottom right
2. Wait for the installation to complete (this may take 15-30 minutes)
3. Restart your computer when prompted

## Step 5: Verify Installation

After installation is complete and you've restarted your computer:

1. Open Command Prompt
2. Run: `flutter doctor`
3. You should now see Visual Studio properly detected

## Step 6: Try Building Again

Once Visual Studio is installed:

1. Run: `flutter build windows --release`

## Troubleshooting

If you still encounter issues:
- Make sure you selected "Desktop development with C++" during installation
- Try running the installer again and modify the installation to add any missing components
- Ensure your Windows is up to date
