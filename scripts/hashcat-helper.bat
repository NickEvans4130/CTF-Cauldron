@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Hashcat Helper
echo Hash Identification and Command Builder
echo ========================================
echo.
echo For Authorized Security Testing Only
echo.

REM Check if hash was provided
if "%~1"=="" (
    echo Usage: hashcat-helper.bat [hash] [optional: wordlist]
    echo.
    echo Examples:
    echo   hashcat-helper.bat 5f4dcc3b5aa765d61d8327deb882cf99
    echo   hashcat-helper.bat "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"
    echo   hashcat-helper.bat hash.txt rockyou.txt
    echo.
    set /p HASH_INPUT="Enter hash to identify: "
    if "!HASH_INPUT!"=="" (
        pause
        exit /b 1
    )
) else (
    set HASH_INPUT=%~1
)

set WORDLIST=%~2

REM Check if input is a file or direct hash
if exist "%HASH_INPUT%" (
    echo Input detected as file: %HASH_INPUT%
    set HASH_FILE=%HASH_INPUT%
    set /p HASH=<%HASH_FILE%
    echo First hash in file: !HASH!
) else (
    set HASH=%HASH_INPUT%
    echo Input hash: %HASH%
    
    REM Create temporary hash file for hashcat
    echo %HASH% > temp_hash.txt
    set HASH_FILE=temp_hash.txt
)

echo.

REM Set default wordlist if not provided
if "%WORDLIST%"=="" (
    set WORDLIST=C:\Tools\wordlists\rockyou.txt
    echo Using default wordlist: !WORDLIST!
    if not exist "!WORDLIST!" (
        echo WARNING: Default wordlist not found!
        echo Please specify wordlist path or download rockyou.txt
        echo Download from: https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
        echo.
        set WORDLIST=wordlist.txt
    )
) else (
    echo Using wordlist: %WORDLIST%
    if not exist "%WORDLIST%" (
        echo WARNING: Wordlist not found: %WORDLIST%
        echo.
    )
)

echo.
echo [1/3] Identifying hash type...
echo.

REM Try to identify hash using hashid (if available)
where hashid >nul 2>&1
if %errorlevel% equ 0 (
    hashid "%HASH%" > temp_hashid.txt 2>&1
    type temp_hashid.txt
    echo.
) else (
    echo [INFO] hashid not found - using manual detection
    echo Install: pip install hashid
    echo.
)

REM Manual hash type detection based on length and format
set HASH_MODE=
set HASH_TYPE=Unknown

REM Get hash length
set HASH_CLEAN=%HASH%
set HASH_CLEAN=%HASH_CLEAN: =%
for /f %%A in ("temp_len.txt") do set LEN=%%~zA
echo %HASH_CLEAN%> temp_len.txt
for %%A in (temp_len.txt) do set /a HASH_LEN=%%~zA-2
del temp_len.txt 2>nul

echo Hash Length: %HASH_LEN% characters
echo.

REM Detect hash type by pattern
echo %HASH% | findstr /R "^\$2[aby]\$" >nul 2>&1
if !errorlevel! equ 0 (
    set HASH_MODE=3200
    set HASH_TYPE=bcrypt
    goto identified
)

echo %HASH% | findstr /R "^\$6\$" >nul 2>&1
if !errorlevel! equ 0 (
    set HASH_MODE=1800
    set HASH_TYPE=SHA-512 Crypt
    goto identified
)

echo %HASH% | findstr /R "^\$5\$" >nul 2>&1
if !errorlevel! equ 0 (
    set HASH_MODE=7400
    set HASH_TYPE=SHA-256 Crypt
    goto identified
)

echo %HASH% | findstr /R "^\$1\$" >nul 2>&1
if !errorlevel! equ 0 (
    set HASH_MODE=500
    set HASH_TYPE=MD5 Crypt
    goto identified
)

REM Check by length for common formats
if %HASH_LEN% equ 32 (
    set HASH_MODE=0
    set HASH_TYPE=MD5
    goto identified
)

if %HASH_LEN% equ 40 (
    set HASH_MODE=100
    set HASH_TYPE=SHA1
    goto identified
)

if %HASH_LEN% equ 64 (
    set HASH_MODE=1400
    set HASH_TYPE=SHA-256
    goto identified
)

if %HASH_LEN% equ 128 (
    set HASH_MODE=1700
    set HASH_TYPE=SHA-512
    goto identified
)

if %HASH_LEN% equ 96 (
    set HASH_MODE=17400
    set HASH_TYPE=SHA3-256
    goto identified
)

if %HASH_LEN% equ 16 (
    set HASH_MODE=900
    set HASH_TYPE=MD4
    goto identified
)

REM NTLM hash detection (also 32 chars but uppercase)
echo %HASH% | findstr /R "^[A-F0-9]*$" >nul 2>&1
if !errorlevel! equ 0 (
    if %HASH_LEN% equ 32 (
        set HASH_MODE=1000
        set HASH_TYPE=NTLM
        goto identified
    )
)

echo Could not automatically identify hash type!
echo Please refer to hashcat help for manual mode selection.
echo.
goto manual_mode

:identified
echo ========================================
echo Hash Identified!
echo ========================================
echo Type: %HASH_TYPE%
echo Hashcat Mode: %HASH_MODE%
echo ========================================
echo.

:build_command
echo [2/3] Building hashcat command...
echo.

REM Build basic hashcat command
set HASHCAT_CMD=hashcat -m %HASH_MODE% -a 0 "%HASH_FILE%" "%WORDLIST%"

echo ========================================
echo BASIC HASHCAT COMMAND
echo ========================================
echo %HASHCAT_CMD%
echo ========================================
echo.

REM Create command file
set CMD_FILE=hashcat_command.bat
echo @echo off > %CMD_FILE%
echo REM Hash Type: %HASH_TYPE% >> %CMD_FILE%
echo REM Hashcat Mode: %HASH_MODE% >> %CMD_FILE%
echo. >> %CMD_FILE%
echo echo Starting hashcat... >> %CMD_FILE%
echo %HASHCAT_CMD% >> %CMD_FILE%
echo. >> %CMD_FILE%
echo pause >> %CMD_FILE%

echo Command saved to: %CMD_FILE%
echo.

echo [3/3] Additional attack options...
echo.

REM Create advanced commands file
set ADVANCED_FILE=hashcat_advanced.txt
echo ======================================== > %ADVANCED_FILE%
echo HASHCAT COMMAND REFERENCE >> %ADVANCED_FILE%
echo ======================================== >> %ADVANCED_FILE%
echo Hash Type: %HASH_TYPE% >> %ADVANCED_FILE%
echo Hashcat Mode: %HASH_MODE% >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%

echo ======================================== >> %ADVANCED_FILE%
echo [1] DICTIONARY ATTACK (Basic) >> %ADVANCED_FILE%
echo ======================================== >> %ADVANCED_FILE%
echo %HASHCAT_CMD% >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%

echo ======================================== >> %ADVANCED_FILE%
echo [2] DICTIONARY + RULES >> %ADVANCED_FILE%
echo ======================================== >> %ADVANCED_FILE%
echo hashcat -m %HASH_MODE% -a 0 "%HASH_FILE%" "%WORDLIST%" -r rules/best64.rule >> %ADVANCED_FILE%
echo hashcat -m %HASH_MODE% -a 0 "%HASH_FILE%" "%WORDLIST%" -r rules/rockyou-30000.rule >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%

echo ======================================== >> %ADVANCED_FILE%
echo [3] COMBINATOR ATTACK >> %ADVANCED_FILE%
echo ======================================== >> %ADVANCED_FILE%
echo hashcat -m %HASH_MODE% -a 1 "%HASH_FILE%" "%WORDLIST%" "%WORDLIST%" >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%

echo ======================================== >> %ADVANCED_FILE%
echo [4] MASK ATTACK (Brute Force) >> %ADVANCED_FILE%
echo ======================================== >> %ADVANCED_FILE%
echo REM 8 lowercase letters >> %ADVANCED_FILE%
echo hashcat -m %HASH_MODE% -a 3 "%HASH_FILE%" ?l?l?l?l?l?l?l?l >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%
echo REM 8 mixed case + digits >> %ADVANCED_FILE%
echo hashcat -m %HASH_MODE% -a 3 "%HASH_FILE%" ?a?a?a?a?a?a?a?a >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%

echo ======================================== >> %ADVANCED_FILE%
echo [5] HYBRID ATTACK >> %ADVANCED_FILE%
echo ======================================== >> %ADVANCED_FILE%
echo REM Dictionary + digits at end >> %ADVANCED_FILE%
echo hashcat -m %HASH_MODE% -a 6 "%HASH_FILE%" "%WORDLIST%" ?d?d?d?d >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%
echo REM Digits + dictionary >> %ADVANCED_FILE%
echo hashcat -m %HASH_MODE% -a 7 "%HASH_FILE%" ?d?d?d?d "%WORDLIST%" >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%

echo ======================================== >> %ADVANCED_FILE%
echo USEFUL OPTIONS >> %ADVANCED_FILE%
echo ======================================== >> %ADVANCED_FILE%
echo --show                 Show cracked passwords >> %ADVANCED_FILE%
echo --username             Ignore usernames in hash file >> %ADVANCED_FILE%
echo --force                Ignore warnings >> %ADVANCED_FILE%
echo -O                     Enable optimized kernels >> %ADVANCED_FILE%
echo -w 3                   Set workload profile (1-4) >> %ADVANCED_FILE%
echo --session mysession    Name the session >> %ADVANCED_FILE%
echo --restore              Restore a session >> %ADVANCED_FILE%
echo --potfile-path file    Custom potfile location >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%

echo ======================================== >> %ADVANCED_FILE%
echo MASK ATTACK CHARSETS >> %ADVANCED_FILE%
echo ======================================== >> %ADVANCED_FILE%
echo ?l = lowercase (abcdefghijklmnopqrstuvwxyz) >> %ADVANCED_FILE%
echo ?u = uppercase (ABCDEFGHIJKLMNOPQRSTUVWXYZ) >> %ADVANCED_FILE%
echo ?d = digits (0123456789) >> %ADVANCED_FILE%
echo ?s = special (!@#$%%^^&*...) >> %ADVANCED_FILE%
echo ?a = all (?l?u?d?s) >> %ADVANCED_FILE%
echo. >> %ADVANCED_FILE%

echo Attack options saved to: %ADVANCED_FILE%
echo.

echo ========================================
echo Ready to Crack!
echo ========================================
echo.
echo Next Steps:
echo 1. Review the generated command
echo 2. Ensure hashcat is installed
echo 3. Run: %CMD_FILE%
echo 4. Check advanced options: %ADVANCED_FILE%
echo.
echo Quick Start:
echo   hashcat --help
echo   hashcat --example-hashes ^| findstr "%HASH_MODE%"
echo.

REM Show common hash types reference
echo Common Hash Types Reference:
echo   0     = MD5
echo   100   = SHA1
echo   1000  = NTLM
echo   1400  = SHA-256
echo   1700  = SHA-512
echo   1800  = SHA-512 Crypt
echo   3200  = bcrypt
echo   5600  = NetNTLMv2
echo   13100 = Kerberos 5 TGS-REP
echo.

echo ⚠ WARNING: Only crack hashes you have authorization to test!
echo ========================================

REM Clean up
if exist temp_hashid.txt del temp_hashid.txt

pause
exit /b 0

:manual_mode
echo.
echo [MANUAL MODE]
echo.
echo Could not identify hash automatically.
echo.
echo Common hash types:
echo   MD5 (32 chars)          : -m 0
echo   SHA1 (40 chars)         : -m 100
echo   NTLM (32 chars)         : -m 1000
echo   SHA-256 (64 chars)      : -m 1400
echo   SHA-512 (128 chars)     : -m 1700
echo   bcrypt ($2a$/$2b$)      : -m 3200
echo   SHA-512 Crypt ($6$)     : -m 1800
echo.
set /p HASH_MODE="Enter hashcat mode number: "

if "%HASH_MODE%"=="" (
    echo No mode provided!
    pause
    exit /b 1
)

set HASH_TYPE=Manual Selection
goto build_command

endlocal