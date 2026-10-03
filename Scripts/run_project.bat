@echo off
setlocal enabledelayedexpansion
title AeroFly Airline Reservation System - IIS Express Runner
color 0b

echo ===================================================================
echo     AeroFly Airline Reservation System (ARS) - Aptech Semester 3
echo ===================================================================
echo.

:: Get clean directory without trailing backslash
set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"

set "PORT=8085"

echo [1/3] Ensuring SQL Server LocalDB (MSSQLLocalDB) is started...
sqllocaldb start MSSQLLocalDB >nul 2>&1
echo       SQL Server LocalDB is ready.
echo.

echo [2/3] Starting IIS Express on http://localhost:%PORT%/ ...
echo       Project Path: "%PROJECT_DIR%"
start "IIS Express - AeroFly ARS" "C:\Program Files\IIS Express\iisexpress.exe" /path:"%PROJECT_DIR%" /port:%PORT%

echo.
echo [3/3] Waiting for server and launching default browser...
ping 127.0.0.1 -n 3 >nul
start http://localhost:%PORT%/Default.aspx

echo.
echo ===================================================================
echo [SUCCESS] AeroFly ARS is now running at:
echo           http://localhost:%PORT%/Default.aspx
echo.
echo NOTE: Do not close the 'IIS Express' console window while using the app!
echo ===================================================================
echo.
pause
