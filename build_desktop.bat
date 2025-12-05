@echo off
echo ========================================
echo Building Aronium POS for Desktop Platforms
echo ========================================
echo.

echo Checking Flutter installation...
flutter doctor
echo.

echo Getting dependencies...
flutter pub get
echo.

echo Building Windows release version...
flutter build windows --release
echo.

if %ERRORLEVEL% EQU 0 (
    echo ========================================
    echo Build successful!
    echo ========================================
    echo.
    echo Windows executable location:
    echo build\windows\x64\runner\Release\aronium.exe
    echo.
    echo To test, navigate to:
    echo cd build\windows\x64\runner\Release
    echo aronium.exe
    echo.
    echo To create a distributable package:
    echo 1. Zip the entire Release folder
    echo 2. Or use Inno Setup/NSIS to create an installer
    echo.
) else (
    echo ========================================
    echo Build failed!
    echo ========================================
    echo.
    echo Make sure you have:
    echo 1. Visual Studio installed with "Desktop development with C++"
    echo 2. Run: flutter doctor to check setup
    echo 3. Check VISUAL_STUDIO_INSTALL_GUIDE.md for help
    echo.
)

pause
