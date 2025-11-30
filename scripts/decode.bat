@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Magic Decoder
echo Multi-Format String Decoder
echo ========================================
echo.

REM Check if input was provided
if "%~1"=="" (
    echo ERROR: No input string specified!
    echo.
    echo Usage: decode.bat [encoded_string]
    echo Example: decode.bat SGVsbG8gV29ybGQh
    echo Example: decode.bat "48656c6c6f20576f726c6421"
    echo.
    echo Or use interactive mode:
    set /p INPUT="Enter string to decode: "
    if "!INPUT!"=="" (
        pause
        exit /b 1
    )
) else (
    set INPUT=%~1
)

echo Input: %INPUT%
echo Length: 
echo %INPUT%> temp_len.txt
for %%A in (temp_len.txt) do set INPUT_LEN=%%~zA
del temp_len.txt
set /a INPUT_LEN=%INPUT_LEN%-2
echo %INPUT_LEN% characters
echo.

REM Create output file
set OUTPUT=decoded_results.txt
echo ======================================== > %OUTPUT%
echo Magic Decoder Results >> %OUTPUT%
echo ======================================== >> %OUTPUT%
echo Input: %INPUT% >> %OUTPUT%
echo Length: %INPUT_LEN% characters >> %OUTPUT%
echo. >> %OUTPUT%

set FOUND_COUNT=0

echo Starting multi-format decoding...
echo.

REM ===== BASE64 DECODING =====
echo [1/10] Attempting Base64 decode...
echo ======================================== >> %OUTPUT%
echo [1] BASE64 DECODING >> %OUTPUT%
echo ======================================== >> %OUTPUT%

echo %INPUT% > temp_b64.txt
certutil -decode temp_b64.txt temp_b64_out.txt >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Base64 decoded successfully!
    set /a FOUND_COUNT+=1
    type temp_b64_out.txt
    type temp_b64_out.txt >> %OUTPUT%
) else (
    echo [FAIL] Not valid Base64
    echo [FAIL] Not valid Base64 >> %OUTPUT%
)
del temp_b64.txt temp_b64_out.txt 2>nul
echo. >> %OUTPUT%
echo.

REM ===== HEX DECODING =====
echo [2/10] Attempting Hex decode...
echo ======================================== >> %OUTPUT%
echo [2] HEX DECODING >> %OUTPUT%
echo ======================================== >> %OUTPUT%

powershell -Command "$hex='%INPUT%'; try { $bytes=[byte[]]::new($hex.Length/2); for($i=0; $i -lt $hex.Length; $i+=2) { $bytes[$i/2]=[Convert]::ToByte($hex.Substring($i,2),16) }; [System.Text.Encoding]::UTF8.GetString($bytes) } catch { 'Invalid Hex' }" > temp_hex_out.txt 2>nul
type temp_hex_out.txt | findstr /V "Invalid" >nul 2>&1
if !errorlevel! equ 0 (
    echo ✓ Hex decoded successfully!
    set /a FOUND_COUNT+=1
    type temp_hex_out.txt
    type temp_hex_out.txt >> %OUTPUT%
) else (
    echo [FAIL] Not valid Hex
    echo [FAIL] Not valid Hex >> %OUTPUT%
)
del temp_hex_out.txt 2>nul
echo. >> %OUTPUT%
echo.

REM ===== URL DECODING =====
echo [3/10] Attempting URL decode...
echo ======================================== >> %OUTPUT%
echo [3] URL DECODING >> %OUTPUT%
echo ======================================== >> %OUTPUT%

powershell -Command "Add-Type -AssemblyName System.Web; [System.Web.HttpUtility]::UrlDecode('%INPUT%')" > temp_url_out.txt 2>nul
type temp_url_out.txt | findstr /R "[a-zA-Z]" >nul 2>&1
if !errorlevel! equ 0 (
    set URL_RESULT=
    for /f "delims=" %%i in (temp_url_out.txt) do set URL_RESULT=%%i
    if not "!URL_RESULT!"=="%INPUT%" (
        echo ✓ URL decoded successfully!
        set /a FOUND_COUNT+=1
        type temp_url_out.txt
        type temp_url_out.txt >> %OUTPUT%
    ) else (
        echo [INFO] No URL encoding detected
        echo [INFO] No URL encoding detected >> %OUTPUT%
    )
) else (
    echo [FAIL] Not URL encoded
    echo [FAIL] Not URL encoded >> %OUTPUT%
)
del temp_url_out.txt 2>nul
echo. >> %OUTPUT%
echo.

REM ===== ROT13 DECODING =====
echo [4/10] Attempting ROT13 decode...
echo ======================================== >> %OUTPUT%
echo [4] ROT13 DECODING >> %OUTPUT%
echo ======================================== >> %OUTPUT%

powershell -Command "$text='%INPUT%'; $result=''; foreach($c in $text.ToCharArray()) { if($c -match '[a-zA-Z]') { $base = if($c -match '[a-z]') { [int][char]'a' } else { [int][char]'A' }; $result += [char](($base + (([int]$c - $base + 13) %% 26))) } else { $result += $c } }; $result" > temp_rot13_out.txt 2>nul
echo ✓ ROT13 applied:
set /a FOUND_COUNT+=1
type temp_rot13_out.txt
type temp_rot13_out.txt >> %OUTPUT%
del temp_rot13_out.txt 2>nul
echo. >> %OUTPUT%
echo.

REM ===== BINARY DECODING =====
echo [5/10] Attempting Binary decode...
echo ======================================== >> %OUTPUT%
echo [5] BINARY DECODING >> %OUTPUT%
echo ======================================== >> %OUTPUT%

echo %INPUT% | findstr /R "^[01 ]*$" >nul 2>&1
if !errorlevel! equ 0 (
    powershell -Command "$binary='%INPUT%'.Replace(' ',''); $result=''; for($i=0; $i -lt $binary.Length; $i+=8) { if($i+8 -le $binary.Length) { $byte=$binary.Substring($i,8); $result+=[char][Convert]::ToInt32($byte,2) } }; $result" > temp_bin_out.txt 2>nul
    type temp_bin_out.txt | findstr /R "[a-zA-Z]" >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✓ Binary decoded successfully!
        set /a FOUND_COUNT+=1
        type temp_bin_out.txt
        type temp_bin_out.txt >> %OUTPUT%
    ) else (
        echo [FAIL] Not valid Binary
        echo [FAIL] Not valid Binary >> %OUTPUT%
    )
    del temp_bin_out.txt 2>nul
) else (
    echo [SKIP] Not binary format
    echo [SKIP] Not binary format >> %OUTPUT%
)
echo. >> %OUTPUT%
echo.

REM ===== ASCII DECIMAL DECODING =====
echo [6/10] Attempting ASCII decimal decode...
echo ======================================== >> %OUTPUT%
echo [6] ASCII DECIMAL DECODING >> %OUTPUT%
echo ======================================== >> %OUTPUT%

echo %INPUT% | findstr /R "^[0-9 ]*$" >nul 2>&1
if !errorlevel! equ 0 (
    powershell -Command "$decimals='%INPUT%'.Split(' '); $result=''; foreach($d in $decimals) { if($d -match '^\d+$' -and [int]$d -lt 256) { $result+=[char][int]$d } }; $result" > temp_dec_out.txt 2>nul
    type temp_dec_out.txt | findstr /R "[a-zA-Z]" >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✓ ASCII decimal decoded successfully!
        set /a FOUND_COUNT+=1
        type temp_dec_out.txt
        type temp_dec_out.txt >> %OUTPUT%
    ) else (
        echo [FAIL] Not valid ASCII decimal
        echo [FAIL] Not valid ASCII decimal >> %OUTPUT%
    )
    del temp_dec_out.txt 2>nul
) else (
    echo [SKIP] Not decimal format
    echo [SKIP] Not decimal format >> %OUTPUT%
)
echo. >> %OUTPUT%
echo.

REM ===== BASE32 DECODING =====
echo [7/10] Attempting Base32 decode...
echo ======================================== >> %OUTPUT%
echo [7] BASE32 DECODING >> %OUTPUT%
echo ======================================== >> %OUTPUT%

echo %INPUT% | findstr /R "^[A-Z2-7=]*$" >nul 2>&1
if !errorlevel! equ 0 (
    python -c "import base64; print(base64.b32decode('%INPUT%').decode('utf-8', errors='ignore'))" > temp_b32_out.txt 2>nul
    if !errorlevel! equ 0 (
        type temp_b32_out.txt | findstr /R "[a-zA-Z]" >nul 2>&1
        if !errorlevel! equ 0 (
            echo ✓ Base32 decoded successfully!
            set /a FOUND_COUNT+=1
            type temp_b32_out.txt
            type temp_b32_out.txt >> %OUTPUT%
        ) else (
            echo [FAIL] Not valid Base32
            echo [FAIL] Not valid Base32 >> %OUTPUT%
        )
    ) else (
        echo [FAIL] Python not available for Base32
        echo [FAIL] Python required >> %OUTPUT%
    )
    del temp_b32_out.txt 2>nul
) else (
    echo [SKIP] Not Base32 format
    echo [SKIP] Not Base32 format >> %OUTPUT%
)
echo. >> %OUTPUT%
echo.

REM ===== MORSE CODE DECODING =====
echo [8/10] Attempting Morse code decode...
echo ======================================== >> %OUTPUT%
echo [8] MORSE CODE DECODING >> %OUTPUT%
echo ======================================== >> %OUTPUT%

echo %INPUT% | findstr /R "^[\.\- /]*$" >nul 2>&1
if !errorlevel! equ 0 (
    powershell -File decode_morse.ps1 "%INPUT%" > temp_morse_out.txt 2>nul
    if exist temp_morse_out.txt (
        echo ✓ Morse code decoded!
        set /a FOUND_COUNT+=1
        type temp_morse_out.txt
        type temp_morse_out.txt >> %OUTPUT%
        del temp_morse_out.txt
    ) else (
        echo [SKIP] Morse decoder unavailable
        echo [SKIP] Morse decoder unavailable >> %OUTPUT%
    )
) else (
    echo [SKIP] Not Morse code format
    echo [SKIP] Not Morse code format >> %OUTPUT%
)
echo. >> %OUTPUT%
echo.

REM ===== REVERSE STRING =====
echo [9/10] Attempting reverse string...
echo ======================================== >> %OUTPUT%
echo [9] REVERSE STRING >> %OUTPUT%
echo ======================================== >> %OUTPUT%

powershell -Command "$text='%INPUT%'; -join ($text.ToCharArray() | Sort-Object {$text.Length - $text.IndexOf($_)} -Descending)" > temp_rev_out.txt 2>nul
echo ✓ Reversed string:
type temp_rev_out.txt
type temp_rev_out.txt >> %OUTPUT%
del temp_rev_out.txt 2>nul
echo. >> %OUTPUT%
echo.

REM ===== CAESAR CIPHER (All Shifts) =====
echo [10/10] Attempting Caesar cipher (all shifts)...
echo ======================================== >> %OUTPUT%
echo [10] CAESAR CIPHER (ALL SHIFTS) >> %OUTPUT%
echo ======================================== >> %OUTPUT%

echo Testing all 25 possible shifts...
for /L %%s in (1,1,25) do (
    powershell -Command "$text='%INPUT%'; $shift=%%s; $result=''; foreach($c in $text.ToCharArray()) { if($c -match '[a-zA-Z]') { $base = if($c -match '[a-z]') { [int][char]'a' } else { [int][char]'A' }; $result += [char](($base + (([int]$c - $base + $shift) %% 26))) } else { $result += $c } }; 'Shift %%s: ' + $result" >> %OUTPUT%
)
echo [INFO] All 25 shifts saved to output file
echo [INFO] Check output file for readable results >> %OUTPUT%
echo. >> %OUTPUT%
echo.

REM ===== SUMMARY =====
echo ========================================
echo Decoding Complete!
echo ========================================
echo.
echo ======================================== >> %OUTPUT%
echo SUMMARY >> %OUTPUT%
echo ======================================== >> %OUTPUT%
echo Successful decodings: !FOUND_COUNT! >> %OUTPUT%
echo. >> %OUTPUT%

echo Successful decodings: !FOUND_COUNT!
echo Results saved to: %OUTPUT%
echo.

echo ========================================
echo READABLE RESULTS
echo ========================================
echo.
type %OUTPUT% | findstr /C:"✓"
echo.
echo Full results available in: %OUTPUT%
echo ========================================

pause
endlocal