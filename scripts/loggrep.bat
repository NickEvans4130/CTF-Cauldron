@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Log Grepper
echo Access Log Filter and Analyzer
echo ========================================
echo.

REM Check if log file was provided
if "%~1"=="" (
    echo ERROR: No log file specified!
    echo.
    echo Usage: loggrep.bat [logfile] [optional: mode]
    echo.
    echo Modes:
    echo   errors     - Show only 4xx/5xx errors (default)
    echo   suspicious - Show suspicious keywords
    echo   all        - Show errors + suspicious
    echo   custom     - Custom keyword search
    echo.
    echo Examples:
    echo   loggrep.bat access.log
    echo   loggrep.bat access.log errors
    echo   loggrep.bat access.log suspicious
    echo   loggrep.bat access.log all
    pause
    exit /b 1
)

set LOG_FILE=%~1
set MODE=%~2

REM Check if file exists
if not exist "%LOG_FILE%" (
    echo ERROR: Log file not found: %LOG_FILE%
    pause
    exit /b 1
)

REM Get file info
for %%A in ("%LOG_FILE%") do (
    set FILENAME=%%~nxA
    set FILESIZE=%%~zA
)

echo Log File: %FILENAME%
echo File Size: %FILESIZE% bytes
echo.

REM Set default mode
if "%MODE%"=="" set MODE=errors

echo Mode: %MODE%
echo.

REM Create output directory
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set DATE=%%c%%a%%b
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME=%%a%%b
set TIMESTAMP=%DATE%_%TIME: =0%
set OUTPUT_DIR=loggrep_%FILENAME%_%TIMESTAMP%

mkdir "%OUTPUT_DIR%" 2>nul

REM Output files
set ERRORS_FILE=%OUTPUT_DIR%\errors.txt
set SUSPICIOUS_FILE=%OUTPUT_DIR%\suspicious.txt
set SUMMARY_FILE=%OUTPUT_DIR%\summary.txt
set STATS_FILE=%OUTPUT_DIR%\statistics.txt

echo Analyzing log file...
echo.

REM Initialize counters
set TOTAL_LINES=0
set SUCCESS_200=0
set REDIRECT_300=0
set CLIENT_ERROR_400=0
set SERVER_ERROR_500=0
set SUSPICIOUS_COUNT=0

REM Count total lines
for /f %%a in ('type "%LOG_FILE%" ^| find /c /v ""') do set TOTAL_LINES=%%a

echo Total log entries: %TOTAL_LINES%
echo.

REM ===== FILTER ERRORS =====
if "%MODE%"=="errors" goto filter_errors
if "%MODE%"=="all" goto filter_errors
goto check_suspicious

:filter_errors
echo [1/3] Filtering HTTP errors (4xx, 5xx)...
echo ======================================== > %ERRORS_FILE%
echo HTTP ERRORS (4xx and 5xx) >> %ERRORS_FILE%
echo ======================================== >> %ERRORS_FILE%
echo Log: %FILENAME% >> %ERRORS_FILE%
echo Date: %DATE% %TIME% >> %ERRORS_FILE%
echo. >> %ERRORS_FILE%

REM Extract 4xx errors
echo. >> %ERRORS_FILE%
echo ===== 4xx CLIENT ERRORS ===== >> %ERRORS_FILE%
echo. >> %ERRORS_FILE%
findstr /R " 40[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul
findstr /R " 41[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul
findstr /R " 42[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul
findstr /R " 43[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul
findstr /R " 44[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul
findstr /R " 45[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul

REM Count 4xx errors
for /f %%a in ('findstr /R " 4[0-9][0-9] " "%LOG_FILE%" ^| find /c /v ""') do set CLIENT_ERROR_400=%%a

REM Extract 5xx errors
echo. >> %ERRORS_FILE%
echo ===== 5xx SERVER ERRORS ===== >> %ERRORS_FILE%
echo. >> %ERRORS_FILE%
findstr /R " 50[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul
findstr /R " 51[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul
findstr /R " 52[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul
findstr /R " 53[0-9] " "%LOG_FILE%" >> %ERRORS_FILE% 2>nul

REM Count 5xx errors
for /f %%a in ('findstr /R " 5[0-9][0-9] " "%LOG_FILE%" ^| find /c /v ""') do set SERVER_ERROR_500=%%a

set /a TOTAL_ERRORS=%CLIENT_ERROR_400% + %SERVER_ERROR_500%
echo ✓ Found %TOTAL_ERRORS% HTTP errors
echo   - 4xx Client Errors: %CLIENT_ERROR_400%
echo   - 5xx Server Errors: %SERVER_ERROR_500%
echo.

REM Show preview of errors
echo Preview of errors:
findstr /R " [45][0-9][0-9] " "%LOG_FILE%" 2>nul | findstr /N "^" | findstr "^[1-5]:"
echo.

if "%MODE%"=="errors" goto statistics
goto check_suspicious

REM ===== FILTER SUSPICIOUS KEYWORDS =====
:check_suspicious
if "%MODE%"=="suspicious" goto filter_suspicious
if "%MODE%"=="all" goto filter_suspicious
if "%MODE%"=="custom" goto custom_filter
goto statistics

:filter_suspicious
echo [2/3] Filtering suspicious keywords...
echo ======================================== > %SUSPICIOUS_FILE%
echo SUSPICIOUS ACTIVITY >> %SUSPICIOUS_FILE%
echo ======================================== >> %SUSPICIOUS_FILE%
echo Log: %FILENAME% >> %SUSPICIOUS_FILE%
echo Date: %DATE% %TIME% >> %SUSPICIOUS_FILE%
echo. >> %SUSPICIOUS_FILE%

REM Define suspicious keywords
set KEYWORDS=admin login password authentication administrator root sql inject script xss csrf phpmyadmin wp-admin config env backup database dump

echo Searching for: %KEYWORDS%
echo.

for %%k in (%KEYWORDS%) do (
    echo. >> %SUSPICIOUS_FILE%
    echo ===== Keyword: %%k ===== >> %SUSPICIOUS_FILE%
    echo. >> %SUSPICIOUS_FILE%
    findstr /I "%%k" "%LOG_FILE%" >> %SUSPICIOUS_FILE% 2>nul
    
    for /f %%a in ('findstr /I /C:"%%k" "%LOG_FILE%" ^| find /c /v ""') do (
        if %%a gtr 0 (
            echo   Found %%a entries with "%%k"
            set /a SUSPICIOUS_COUNT+=%%a
        )
    )
)

echo ✓ Found %SUSPICIOUS_COUNT% suspicious entries
echo.

REM Show preview
echo Preview of suspicious activity:
findstr /I "admin login password" "%LOG_FILE%" 2>nul | findstr /N "^" | findstr "^[1-5]:"
echo.

goto statistics

:custom_filter
echo [2/3] Custom keyword search...
set /p CUSTOM_KEYWORDS="Enter keywords to search (space-separated): "

if "%CUSTOM_KEYWORDS%"=="" (
    echo No keywords provided!
    goto statistics
)

echo ======================================== > %SUSPICIOUS_FILE%
echo CUSTOM KEYWORD SEARCH >> %SUSPICIOUS_FILE%
echo ======================================== >> %SUSPICIOUS_FILE%
echo Keywords: %CUSTOM_KEYWORDS% >> %SUSPICIOUS_FILE%
echo. >> %SUSPICIOUS_FILE%

for %%k in (%CUSTOM_KEYWORDS%) do (
    echo. >> %SUSPICIOUS_FILE%
    echo ===== Keyword: %%k ===== >> %SUSPICIOUS_FILE%
    echo. >> %SUSPICIOUS_FILE%
    findstr /I "%%k" "%LOG_FILE%" >> %SUSPICIOUS_FILE% 2>nul
    
    for /f %%a in ('findstr /I /C:"%%k" "%LOG_FILE%" ^| find /c /v ""') do (
        if %%a gtr 0 (
            echo   Found %%a entries with "%%k"
            set /a SUSPICIOUS_COUNT+=%%a
        )
    )
)

echo ✓ Found %SUSPICIOUS_COUNT% matching entries
echo.

REM ===== STATISTICS =====
:statistics
echo [3/3] Generating statistics...

REM Count success responses
for /f %%a in ('findstr /R " 200 " "%LOG_FILE%" ^| find /c /v ""') do set SUCCESS_200=%%a
for /f %%a in ('findstr /R " 3[0-9][0-9] " "%LOG_FILE%" ^| find /c /v ""') do set REDIRECT_300=%%a

REM Generate statistics file
echo ======================================== > %STATS_FILE%
echo LOG STATISTICS >> %STATS_FILE%
echo ======================================== >> %STATS_FILE%
echo Log File: %FILENAME% >> %STATS_FILE%
echo Total Entries: %TOTAL_LINES% >> %STATS_FILE%
echo Analysis Date: %DATE% %TIME% >> %STATS_FILE%
echo. >> %STATS_FILE%
echo ======================================== >> %STATS_FILE%
echo HTTP STATUS CODE BREAKDOWN >> %STATS_FILE%
echo ======================================== >> %STATS_FILE%
echo 2xx Success:       %SUCCESS_200% >> %STATS_FILE%
echo 3xx Redirects:     %REDIRECT_300% >> %STATS_FILE%
echo 4xx Client Errors: %CLIENT_ERROR_400% >> %STATS_FILE%
echo 5xx Server Errors: %SERVER_ERROR_500% >> %STATS_FILE%
echo. >> %STATS_FILE%

REM Calculate percentages
if %TOTAL_LINES% gtr 0 (
    set /a ERROR_PERCENT=(%CLIENT_ERROR_400% + %SERVER_ERROR_500%) * 100 / %TOTAL_LINES%
    echo Error Rate: !ERROR_PERCENT!%% >> %STATS_FILE%
)

echo. >> %STATS_FILE%
echo ======================================== >> %STATS_FILE%
echo TOP ERROR CODES >> %STATS_FILE%
echo ======================================== >> %STATS_FILE%

REM Count specific error codes
for %%c in (400 401 403 404 500 502 503) do (
    for /f %%a in ('findstr /R " %%c " "%LOG_FILE%" ^| find /c /v ""') do (
        if %%a gtr 0 echo %%c: %%a occurrences >> %STATS_FILE%
    )
)

echo. >> %STATS_FILE%
echo ======================================== >> %STATS_FILE%
echo SUSPICIOUS ACTIVITY >> %STATS_FILE%
echo ======================================== >> %STATS_FILE%
echo Total Suspicious Entries: %SUSPICIOUS_COUNT% >> %STATS_FILE%

echo ✓ Statistics generated
echo.

REM ===== GENERATE SUMMARY =====
echo ======================================== > %SUMMARY_FILE%
echo LOG ANALYSIS SUMMARY >> %SUMMARY_FILE%
echo ======================================== >> %SUMMARY_FILE%
echo. >> %SUMMARY_FILE%
type %STATS_FILE% >> %SUMMARY_FILE%
echo. >> %SUMMARY_FILE%

REM Top IP addresses
echo ======================================== >> %SUMMARY_FILE%
echo TOP 10 IP ADDRESSES >> %SUMMARY_FILE%
echo ======================================== >> %SUMMARY_FILE%
powershell -Command "Get-Content '%LOG_FILE%' | ForEach-Object { if($_ -match '^(\S+)') { $matches[1] } } | Group-Object | Sort-Object Count -Descending | Select-Object -First 10 | ForEach-Object { '{0}: {1}' -f $_.Name, $_.Count }" >> %SUMMARY_FILE% 2>nul

echo. >> %SUMMARY_FILE%

REM Most requested URLs
echo ======================================== >> %SUMMARY_FILE%
echo TOP 10 REQUESTED URLS >> %SUMMARY_FILE%
echo ======================================== >> %SUMMARY_FILE%
powershell -Command "Get-Content '%LOG_FILE%' | ForEach-Object { if($_ -match '\"(?:GET|POST|PUT|DELETE) ([^\s\"]+)') { $matches[1] } } | Group-Object | Sort-Object Count -Descending | Select-Object -First 10 | ForEach-Object { '{0}: {1}' -f $_.Name, $_.Count }" >> %SUMMARY_FILE% 2>nul

echo ========================================
echo Analysis Complete!
echo ========================================
echo.
echo Results saved to: %OUTPUT_DIR%
echo.
echo Generated Files:
dir /B "%OUTPUT_DIR%"
echo.
echo ========================================
echo SUMMARY
echo ========================================
type %STATS_FILE%
echo.
echo ========================================

echo Full reports available in: %OUTPUT_DIR%
echo.

REM Optional: Open results
set /p OPEN="Open results folder? (Y/N): "
if /i "%OPEN%"=="Y" (
    explorer "%OUTPUT_DIR%"
    start notepad "%SUMMARY_FILE%"
)

endlocal