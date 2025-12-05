@echo off
REM CMake wrapper to replace Visual Studio 16 2019 with auto-detection or VS 2026

setlocal enabledelayedexpansion

set "ARGS=%*"
set "ARGS=!ARGS:-G Visual Studio 16 2019=-G "Visual Studio 18 2026"!"

REM If VS 2026 doesn't work, try without generator (auto-detect)
if "%ARGS%"=="%*" (
    set "ARGS=%*"
    set "ARGS=!ARGS:-G Visual Studio 16 2019=!"
)

REM Call actual CMake
"D:\Visual code Things\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" %ARGS%

endlocal

