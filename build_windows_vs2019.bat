@echo off
echo ========================================
echo Building Aronium POS for Windows with VS 2019
echo ========================================
echo.

echo Checking Flutter installation...
flutter doctor
echo.

echo Cleaning previous build artifacts...
flutter clean
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
    echo Executable location:
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
    echo 1. Visual Studio 2019 installed with "Desktop development with C++"
    echo 2. See VISUAL_STUDIO_2019_INSTALL_GUIDE.md for detailed instructions
    echo 3. Run: flutter doctor to check setup
    echo.
)

pause
