@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Deep Inspector
echo Comprehensive File Analysis Tool
echo ========================================
echo.

REM Check if file was provided
if "%~1"=="" (
    echo ERROR: No file specified!
    echo.
    echo Usage: inspect.bat [filename]
    echo Example: inspect.bat suspicious.jpg
    echo Example: inspect.bat malware.exe
    pause
    exit /b 1
)

set TARGET_FILE=%~1

REM Check if file exists
if not exist "%TARGET_FILE%" (
    echo ERROR: File not found: %TARGET_FILE%
    pause
    exit /b 1
)

REM Get file information
for %%A in ("%TARGET_FILE%") do (
    set FILENAME=%%~nxA
    set FILESIZE=%%~zA
    set FILEPATH=%%~fA
)

echo Target File: %FILENAME%
echo Full Path: %FILEPATH%
echo File Size: %FILESIZE% bytes
echo.

REM Create output directory
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set DATE=%%c%%a%%b
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME=%%a%%b
set TIMESTAMP=%DATE%_%TIME: =0%
set OUTPUT_DIR=inspect_%FILENAME%_%TIMESTAMP%

mkdir "%OUTPUT_DIR%" 2>nul
echo Results will be saved to: %OUTPUT_DIR%
echo.

REM Create summary file
set SUMMARY=%OUTPUT_DIR%\summary.txt
echo ======================================== > %SUMMARY%
echo Deep Inspector Analysis Report >> %SUMMARY%
echo ======================================== >> %SUMMARY%
echo File: %FILENAME% >> %SUMMARY%
echo Path: %FILEPATH% >> %SUMMARY%
echo Size: %FILESIZE% bytes >> %SUMMARY%
echo Date: %DATE% %TIME% >> %SUMMARY%
echo. >> %SUMMARY%

set TOOLS_AVAILABLE=0
set TOOLS_RAN=0

echo Starting analysis...
echo.

REM ===== FILE TYPE DETECTION =====
echo [1/6] Detecting file type...
echo ======================================== >> %SUMMARY%
echo [1] FILE TYPE DETECTION >> %SUMMARY%
echo ======================================== >> %SUMMARY%

where file >nul 2>&1
if %errorlevel% equ 0 (
    set /a TOOLS_AVAILABLE+=1
    echo Running 'file' command...
    file "%TARGET_FILE%" > %OUTPUT_DIR%\file_output.txt 2>&1
    type %OUTPUT_DIR%\file_output.txt
    type %OUTPUT_DIR%\file_output.txt >> %SUMMARY%
    set /a TOOLS_RAN+=1
) else (
    echo [SKIP] 'file' command not found
    echo [SKIP] 'file' command not found >> %SUMMARY%
)
echo. >> %SUMMARY%
echo.

REM ===== STRINGS EXTRACTION =====
echo [2/6] Extracting readable strings...
echo ======================================== >> %SUMMARY%
echo [2] STRINGS EXTRACTION >> %SUMMARY%
echo ======================================== >> %SUMMARY%

where strings >nul 2>&1
if %errorlevel% equ 0 (
    set /a TOOLS_AVAILABLE+=1
    echo Running 'strings' analysis...
    strings "%TARGET_FILE%" > %OUTPUT_DIR%\strings_output.txt 2>&1
    echo Extracted !errorlevel! strings
    echo First 20 interesting strings: >> %SUMMARY%
    strings "%TARGET_FILE%" | findstr /R /C:"http" /C:"ftp" /C:"password" /C:"key" /C:"admin" /C:".exe" /C:".dll" /C:"cmd" /C:"powershell" /C:"flag" 2>nul | findstr /N "^" | findstr "^[1-9]: ^1[0-9]: ^20:" >> %SUMMARY%
    if !errorlevel! neq 0 (
        echo No interesting strings found. >> %SUMMARY%
    )
    set /a TOOLS_RAN+=1
) else (
    echo [SKIP] 'strings' command not found
    echo [SKIP] 'strings' command not found >> %SUMMARY%
)
echo. >> %SUMMARY%
echo.

REM ===== BINWALK ANALYSIS =====
echo [3/6] Analyzing embedded files and firmware...
echo ======================================== >> %SUMMARY%
echo [3] BINWALK ANALYSIS >> %SUMMARY%
echo ======================================== >> %SUMMARY%

where binwalk >nul 2>&1
if %errorlevel% equ 0 (
    set /a TOOLS_AVAILABLE+=1
    echo Running 'binwalk' analysis...
    binwalk "%TARGET_FILE%" > %OUTPUT_DIR%\binwalk_output.txt 2>&1
    type %OUTPUT_DIR%\binwalk_output.txt
    type %OUTPUT_DIR%\binwalk_output.txt >> %SUMMARY%
    
    REM Extract embedded files
    echo Attempting to extract embedded files...
    binwalk -e "%TARGET_FILE%" -C "%OUTPUT_DIR%" >nul 2>&1
    if exist "%OUTPUT_DIR%\_%FILENAME%.extracted" (
        echo ✓ Embedded files extracted to: _%FILENAME%.extracted
        echo ✓ Embedded files extracted >> %SUMMARY%
    )
    set /a TOOLS_RAN+=1
) else (
    echo [SKIP] 'binwalk' not found - Install: pip install binwalk
    echo [SKIP] 'binwalk' not found >> %SUMMARY%
)
echo. >> %SUMMARY%
echo.

REM ===== EXIFTOOL METADATA =====
echo [4/6] Extracting metadata...
echo ======================================== >> %SUMMARY%
echo [4] METADATA EXTRACTION (ExifTool) >> %SUMMARY%
echo ======================================== >> %SUMMARY%

where exiftool >nul 2>&1
if %errorlevel% equ 0 (
    set /a TOOLS_AVAILABLE+=1
    echo Running 'exiftool' metadata extraction...
    exiftool "%TARGET_FILE%" > %OUTPUT_DIR%\exiftool_output.txt 2>&1
    type %OUTPUT_DIR%\exiftool_output.txt | findstr /V "ExifTool Version Number"
    type %OUTPUT_DIR%\exiftool_output.txt >> %SUMMARY%
    set /a TOOLS_RAN+=1
) else (
    echo [SKIP] 'exiftool' not found - Download from: https://exiftool.org/
    echo [SKIP] 'exiftool' not found >> %SUMMARY%
)
echo. >> %SUMMARY%
echo.

REM ===== ZSTEG (PNG/BMP Steganography) =====
echo [5/6] Checking for steganography (images only)...
echo ======================================== >> %SUMMARY%
echo [5] STEGANOGRAPHY ANALYSIS (zsteg) >> %SUMMARY%
echo ======================================== >> %SUMMARY%

REM Check if file is an image
echo %FILENAME% | findstr /I ".png .bmp .jpg .jpeg .gif" >nul
if %errorlevel% equ 0 (
    where zsteg >nul 2>&1
    if !errorlevel! equ 0 (
        set /a TOOLS_AVAILABLE+=1
        echo Running 'zsteg' steganography analysis...
        zsteg "%TARGET_FILE%" > %OUTPUT_DIR%\zsteg_output.txt 2>&1
        type %OUTPUT_DIR%\zsteg_output.txt
        type %OUTPUT_DIR%\zsteg_output.txt >> %SUMMARY%
        set /a TOOLS_RAN+=1
    ) else (
        echo [SKIP] 'zsteg' not found - Install: gem install zsteg
        echo [SKIP] 'zsteg' not found >> %SUMMARY%
    )
) else (
    echo [SKIP] Not an image file - zsteg only works on PNG/BMP
    echo [SKIP] Not an image file >> %SUMMARY%
)
echo. >> %SUMMARY%
echo.

REM ===== HASH CALCULATION =====
echo [6/6] Calculating file hashes...
echo ======================================== >> %SUMMARY%
echo [6] FILE HASHES >> %SUMMARY%
echo ======================================== >> %SUMMARY%

echo Calculating MD5, SHA1, and SHA256...
certutil -hashfile "%TARGET_FILE%" MD5 2>nul | findstr /V ":" > %OUTPUT_DIR%\hash_md5.txt
certutil -hashfile "%TARGET_FILE%" SHA1 2>nul | findstr /V ":" > %OUTPUT_DIR%\hash_sha1.txt
certutil -hashfile "%TARGET_FILE%" SHA256 2>nul | findstr /V ":" > %OUTPUT_DIR%\hash_sha256.txt

echo MD5:    
type %OUTPUT_DIR%\hash_md5.txt
echo SHA1:   
type %OUTPUT_DIR%\hash_sha1.txt
echo SHA256: 
type %OUTPUT_DIR%\hash_sha256.txt

echo MD5:     >> %SUMMARY%
type %OUTPUT_DIR%\hash_md5.txt >> %SUMMARY%
echo SHA1:    >> %SUMMARY%
type %OUTPUT_DIR%\hash_sha1.txt >> %SUMMARY%
echo SHA256:  >> %SUMMARY%
type %OUTPUT_DIR%\hash_sha256.txt >> %SUMMARY%

REM VirusTotal lookup suggestion
echo. >> %SUMMARY%
echo VirusTotal Lookup: >> %SUMMARY%
for /f "delims=" %%h in (%OUTPUT_DIR%\hash_sha256.txt) do (
    echo https://www.virustotal.com/gui/file/%%h >> %SUMMARY%
    echo Check on VirusTotal: https://www.virustotal.com/gui/file/%%h
)

echo. >> %SUMMARY%
echo.

REM ===== GENERATE SUMMARY =====
echo ========================================
echo Analysis Complete!
echo ========================================
echo.

echo ======================================== >> %SUMMARY%
echo ANALYSIS SUMMARY >> %SUMMARY%
echo ======================================== >> %SUMMARY%
echo Tools Available: !TOOLS_AVAILABLE! >> %SUMMARY%
echo Tools Executed: !TOOLS_RAN! >> %SUMMARY%
echo. >> %SUMMARY%

REM Check for interesting findings
echo Checking for interesting findings...
echo INTERESTING FINDINGS: >> %SUMMARY%

findstr /I /C:"password" /C:"secret" /C:"key" /C:"flag" /C:"admin" %OUTPUT_DIR%\strings_output.txt >nul 2>&1
if !errorlevel! equ 0 (
    echo ⚠ Suspicious strings detected ^(password, secret, key, etc.^) >> %SUMMARY%
    echo ⚠ Suspicious strings detected
)

type %OUTPUT_DIR%\binwalk_output.txt 2>nul | findstr /I "compressed" >nul 2>&1
if !errorlevel! equ 0 (
    echo ⚠ Embedded compressed data detected >> %SUMMARY%
    echo ⚠ Embedded compressed data detected
)

type %OUTPUT_DIR%\binwalk_output.txt 2>nul | findstr /I "encrypted" >nul 2>&1
if !errorlevel! equ 0 (
    echo ⚠ Encrypted data detected >> %SUMMARY%
    echo ⚠ Encrypted data detected
)

type %OUTPUT_DIR%\zsteg_output.txt 2>nul | findstr /I "text" >nul 2>&1
if !errorlevel! equ 0 (
    echo ⚠ Possible steganography detected >> %SUMMARY%
    echo ⚠ Possible steganography detected
)

echo. >> %SUMMARY%

echo ======================================== >> %SUMMARY%
echo END OF REPORT >> %SUMMARY%
echo ======================================== >> %SUMMARY%

echo Results Directory: %OUTPUT_DIR%
echo Summary Report: %SUMMARY%
echo.
echo Generated Files:
dir /B "%OUTPUT_DIR%"
echo.

REM Show summary
echo ========================================
echo KEY FINDINGS SUMMARY
echo ========================================
type %SUMMARY% | findstr /C:"⚠" /C:"✓"
echo.

echo Full report available at: %SUMMARY%
echo ========================================

REM Optional: Open results
set /p OPEN="Open results folder? (Y/N): "
if /i "%OPEN%"=="Y" explorer "%OUTPUT_DIR%"

endlocal