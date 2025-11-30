@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Pattern Calculator
echo Buffer Overflow Analysis Tool
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH!
    echo Please install Python to use this tool.
    pause
    exit /b 1
)

REM Show menu
echo Select operation:
echo.
echo [1] Generate cyclic pattern
echo [2] Find offset from pattern value
echo [3] Find offset from crash address
echo [4] Install pwntools (if not installed)
echo.
set /p CHOICE="Enter choice (1-4): "

if "%CHOICE%"=="1" goto generate
if "%CHOICE%"=="2" goto find_offset
if "%CHOICE%"=="3" goto find_address
if "%CHOICE%"=="4" goto install
echo Invalid choice!
pause
exit /b 1

:generate
echo.
echo ========================================
echo Generate Cyclic Pattern
echo ========================================
echo.
set /p LENGTH="Enter pattern length (e.g., 500): "

if "%LENGTH%"=="" (
    echo ERROR: Length required!
    pause
    exit /b 1
)

echo.
echo Generating %LENGTH% byte cyclic pattern...
echo.

REM Generate pattern using pwntools
python -c "from pwn import *; print(cyclic(%LENGTH%).decode())" 2>nul

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to generate pattern!
    echo This might mean pwntools is not installed.
    echo Run option [4] to install pwntools.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Pattern generated successfully!
echo ========================================
echo.

REM Save to file
set OUTPUT_FILE=pattern_%LENGTH%.txt
python -c "from pwn import *; print(cyclic(%LENGTH%).decode())" > %OUTPUT_FILE% 2>nul
echo Pattern saved to: %OUTPUT_FILE%
echo.

REM Also show hex representation
echo Hex representation (first 64 bytes):
python -c "from pwn import *; import binascii; print(binascii.hexlify(cyclic(%LENGTH%)[:64]).decode())" 2>nul
echo.

echo Copy the pattern and use it as input to your vulnerable program.
echo When it crashes, use option [2] or [3] to find the offset.
echo.
pause
goto end

:find_offset
echo.
echo ========================================
echo Find Offset from Pattern Value
echo ========================================
echo.
echo Enter the 4-byte pattern found at EIP/RIP crash
echo (e.g., if EIP = 0x61616161, enter: 61616161)
echo (or as ASCII: aaaa)
echo.
set /p PATTERN="Enter pattern value: "

if "%PATTERN%"=="" (
    echo ERROR: Pattern value required!
    pause
    exit /b 1
)

echo.
echo Calculating offset for pattern: %PATTERN%
echo.

REM Check if input is hex or ASCII
echo %PATTERN% | findstr /R "^[0-9a-fA-F][0-9a-fA-F]*$" >nul
if %errorlevel% equ 0 (
    REM Hex input
    echo Interpreting as hexadecimal...
    python -c "from pwn import *; print('Offset:', cyclic_find(0x%PATTERN%))" 2>nul
) else (
    REM ASCII input
    echo Interpreting as ASCII...
    python -c "from pwn import *; print('Offset:', cyclic_find(b'%PATTERN%'))" 2>nul
)

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to calculate offset!
    echo Make sure pwntools is installed (option 4).
    pause
    exit /b 1
)

echo.
echo ========================================
echo This is the exact offset to control EIP/RIP
echo ========================================
echo.
pause
goto end

:find_address
echo.
echo ========================================
echo Find Offset from Crash Address
echo ========================================
echo.
echo Enter the crash address from your debugger
echo (e.g., EIP = 0x61616161 or RIP = 0x6161616161616161)
echo Enter in format: 61616161 (without 0x prefix)
echo.
set /p ADDRESS="Enter crash address: "

if "%ADDRESS%"=="" (
    echo ERROR: Address required!
    pause
    exit /b 1
)

echo.
echo Calculating offset for address: 0x%ADDRESS%
echo.

REM Convert to proper format and find offset
python -c "from pwn import *; addr = int('%ADDRESS%', 16); print('Address:', hex(addr)); print('Offset:', cyclic_find(addr, n=8 if len('%ADDRESS%') > 8 else 4))" 2>nul

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to calculate offset!
    pause
    exit /b 1
)

echo.
echo ========================================
echo This is the exact offset to control EIP/RIP
echo ========================================
echo.
pause
goto end

:install
echo.
echo ========================================
echo Install Pwntools
echo ========================================
echo.
echo Installing pwntools via pip...
echo This may take a few minutes...
echo.

python -m pip install --upgrade pip
python -m pip install pwntools

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Pwntools installed successfully!
    echo ========================================
) else (
    echo.
    echo ========================================
    echo Installation failed!
    echo ========================================
    echo.
    echo Try manual installation:
    echo   pip install pwntools
    echo.
    echo Or with admin privileges:
    echo   python -m pip install pwntools --user
)

echo.
pause
goto end

:end
echo.
echo ========================================
echo Pattern Calculator
echo ========================================
echo.
echo Quick Reference:
echo.
echo [Generate] Create pattern: pattern.bat
echo [Offset]   From pattern: cyclic_find(pattern)
echo [Usage]    payload = b"A"*offset + EIP + shellcode
echo.
echo For more advanced usage, use pwntools directly:
echo   python -c "from pwn import *; help(cyclic)"
echo.
echo ========================================

endlocal