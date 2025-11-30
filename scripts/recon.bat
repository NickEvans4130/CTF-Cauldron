@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Recon-in-a-Box
echo ========================================
echo.

REM Check if target was provided
if "%~1"=="" (
    echo ERROR: No target specified!
    echo.
    echo Usage: recon.bat [IP or Domain] [optional: port]
    echo Example: recon.bat 192.168.1.100
    echo Example: recon.bat example.com 8080
    pause
    exit /b 1
)

set TARGET=%~1
set PORT=%~2
if "%PORT%"=="" set PORT=80

REM Configuration - Customize these paths
set NMAP_PATH=nmap
set GOBUSTER_PATH=gobuster
set WORDLIST=C:\Tools\wordlists\common.txt
REM Download wordlists from: https://github.com/danielmiessler/SecLists

echo Target: %TARGET%
echo Port: %PORT%
echo.

REM Create output directory with timestamp
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set DATE=%%c%%a%%b
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME=%%a%%b
set TIMESTAMP=%DATE%_%TIME: =0%
set OUTPUT_DIR=recon_%TARGET%_%TIMESTAMP%

echo [1/6] Creating output directory...
mkdir "%OUTPUT_DIR%" 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Could not create directory!
    pause
    exit /b 1
)
echo ✓ Directory created: %OUTPUT_DIR%
echo.

REM Create info file
echo Target: %TARGET% > "%OUTPUT_DIR%\info.txt"
echo Port: %PORT% >> "%OUTPUT_DIR%\info.txt"
echo Scan Started: %DATE% %TIME% >> "%OUTPUT_DIR%\info.txt"
echo. >> "%OUTPUT_DIR%\info.txt"

echo [2/6] Running quick Nmap scan...
echo Command: nmap -sV -sC -T4 %TARGET% -oN "%OUTPUT_DIR%\nmap_quick.txt"
%NMAP_PATH% -sV -sC -T4 %TARGET% -oN "%OUTPUT_DIR%\nmap_quick.txt"
if %errorlevel% neq 0 (
    echo WARNING: Quick Nmap scan failed or had errors
) else (
    echo ✓ Quick scan complete
)
echo.

echo [3/6] Running comprehensive Nmap scan...
echo Command: nmap -sV -sC -p- -T4 %TARGET% -oN "%OUTPUT_DIR%\nmap_full.txt"
echo This may take several minutes...
%NMAP_PATH% -sV -sC -p- -T4 %TARGET% -oN "%OUTPUT_DIR%\nmap_full.txt"
if %errorlevel% neq 0 (
    echo WARNING: Full Nmap scan failed or had errors
) else (
    echo ✓ Full scan complete
)
echo.

echo [4/6] Running Nmap vulnerability scan...
echo Command: nmap --script vuln %TARGET% -oN "%OUTPUT_DIR%\nmap_vuln.txt"
%NMAP_PATH% --script vuln %TARGET% -oN "%OUTPUT_DIR%\nmap_vuln.txt"
if %errorlevel% neq 0 (
    echo WARNING: Vulnerability scan failed or had errors
) else (
    echo ✓ Vulnerability scan complete
)
echo.

echo [5/6] Running Gobuster directory enumeration...
if not exist "%WORDLIST%" (
    echo WARNING: Wordlist not found at %WORDLIST%
    echo Skipping Gobuster scan
    echo Download SecLists from: https://github.com/danielmiessler/SecLists
) else (
    echo Command: gobuster dir -u http://%TARGET%:%PORT% -w "%WORDLIST%" -o "%OUTPUT_DIR%\gobuster.txt"
    echo This may take several minutes...
    %GOBUSTER_PATH% dir -u http://%TARGET%:%PORT% -w "%WORDLIST%" -o "%OUTPUT_DIR%\gobuster.txt" -q
    if %errorlevel% neq 0 (
        echo WARNING: Gobuster scan failed
    ) else (
        echo ✓ Directory enumeration complete
    )
)
echo.

echo [6/6] Generating summary report...
(
    echo ========================================
    echo Reconnaissance Summary
    echo ========================================
    echo.
    echo Target: %TARGET%
    echo Port: %PORT%
    echo Scan Date: %DATE% %TIME%
    echo Output Directory: %OUTPUT_DIR%
    echo.
    echo ========================================
    echo Files Generated:
    echo ========================================
    dir /B "%OUTPUT_DIR%"
    echo.
    echo ========================================
    echo Quick Nmap Results Preview:
    echo ========================================
    type "%OUTPUT_DIR%\nmap_quick.txt" 2>nul | findstr /C:"open" /C:"PORT"
    echo.
) > "%OUTPUT_DIR%\summary.txt"

type "%OUTPUT_DIR%\summary.txt"

echo ========================================
echo Recon Complete!
echo ========================================
echo.
echo All results saved to: %OUTPUT_DIR%
echo.
echo Generated Files:
dir /B "%OUTPUT_DIR%"
echo.
echo Open the directory to review detailed results.
echo ========================================

REM Optional: Open the directory
set /p OPEN="Open results folder? (Y/N): "
if /i "%OPEN%"=="Y" explorer "%OUTPUT_DIR%"

endlocal