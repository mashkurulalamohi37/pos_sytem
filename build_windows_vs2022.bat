@echo off
echo ========================================
echo Building Aronium POS for Windows with VS 2022
echo ========================================
echo.

echo Cleaning previous build artifacts...
rmdir /s /q build\windows 2>nul
echo.

echo Setting environment for VS 2022...
set CMAKE_GENERATOR="Visual Studio 17 2022"
set CMAKE_GENERATOR_INSTANCE="D:\vs code cach"
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
) else (
    echo ========================================
    echo Build failed!
    echo ========================================
    echo.
    echo Make sure you have:
    echo 1. Visual Studio 2022 installed with "Desktop development with C++"
    echo 2. Run: flutter doctor to check setup
    echo.
)

pause
