@echo off
echo ========================================
echo Building Aronium POS for Windows using CMake directly
echo ========================================
echo.

echo Cleaning previous build artifacts...
rmdir /s /q build\windows 2>nul
mkdir build\windows
cd build\windows
echo.

echo Running CMake with Visual Studio 2022...
cmake -G "Visual Studio 17 2022" -A x64 ..\..\windows
if %ERRORLEVEL% NEQ 0 (
    echo CMake configuration failed!
    cd ..\..
    pause
    exit /b 1
)
echo.

echo Building with CMake...
cmake --build . --config Release
if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    cd ..\..
    pause
    exit /b 1
)
echo.

echo ========================================
echo Build successful!
echo ========================================
echo.
echo Executable location:
echo build\windows\runner\Release\aronium.exe
echo.
echo To test, navigate to:
echo cd build\windows\runner\Release
echo aronium.exe
echo.

cd ..\..
pause
