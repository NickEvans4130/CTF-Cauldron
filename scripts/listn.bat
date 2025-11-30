@echo off
setlocal

REM Configuration - Customize these paths
set NC_PATH=nc
REM Common alternatives: ncat, netcat, C:\Tools\ncat.exe

REM Check if port was provided
if "%~1"=="" (
    echo ERROR: No port specified!
    echo.
    echo Usage: listn [port]
    echo Example: listn 9001
    echo Example: listn 4444
    echo.
    echo This runs: nc -lvnp [port]
    echo   -l = listen mode
    echo   -v = verbose
    echo   -n = no DNS lookup
    echo   -p = port number
    exit /b 1
)

set PORT=%~1

REM Validate port number
echo %PORT%| findstr /R "^[0-9][0-9]*$" >nul
if %errorlevel% neq 0 (
    echo ERROR: Invalid port number!
    echo Port must be numeric.
    exit /b 1
)

REM Check if port is in valid range
if %PORT% lss 1 (
    echo ERROR: Port must be between 1 and 65535
    exit /b 1
)
if %PORT% gtr 65535 (
    echo ERROR: Port must be between 1 and 65535
    exit /b 1
)

echo ========================================
echo NetCat Listener Starting
echo ========================================
echo.
echo Port: %PORT%
echo Command: nc -lvnp %PORT%
echo.
echo Waiting for incoming connection...
echo Press Ctrl+C to stop listening
echo ========================================
echo.

REM Start netcat listener
%NC_PATH% -lvnp %PORT%

REM Check if netcat failed
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo ERROR: Listener failed to start
    echo ========================================
    echo.
    echo Possible causes:
    echo   - NetCat not found in PATH
    echo   - Port already in use
    echo   - Insufficient permissions
    echo   - Firewall blocking the port
    echo.
    echo Try these solutions:
    echo   1. Install NetCat: choco install netcat
    echo   2. Check if port is in use: netstat -ano ^| findstr %PORT%
    echo   3. Run as Administrator
    echo   4. Use a different port
    echo.
)

endlocal