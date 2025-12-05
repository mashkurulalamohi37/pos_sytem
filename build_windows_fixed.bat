@echo off
REM Build script for Windows with Visual Studio 2026 support

REM Set Visual Studio path
set "VS_PATH=D:\Visual code Things"

REM Set CMake generator to auto-detect (or try VS 2026)
set "CMAKE_GENERATOR="

REM Clean previous builds
echo Cleaning previous builds...
flutter clean

REM Build for Windows
echo Building for Windows...
flutter build windows

pause

