@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Am I Up? Pinger
echo ========================================
echo.

REM Configuration - Customize these settings
set ENDPOINT=http://localhost:3000
set CHECK_INTERVAL=5
set PLAY_SOUND=true
set MAX_ATTEMPTS=0
REM Set to 0 for unlimited attempts

echo Target Endpoint: %ENDPOINT%
echo Check Interval: %CHECK_INTERVAL% seconds
echo.

set ATTEMPT=0
set SERVER_UP=false

:check_loop
set /a ATTEMPT+=1

REM Check if max attempts reached (if set)
if %MAX_ATTEMPTS% gtr 0 (
    if !ATTEMPT! gtr %MAX_ATTEMPTS% (
        echo.
        echo Maximum attempts reached. Server did not respond.
        goto end
    )
)

REM Display attempt counter
echo [Attempt !ATTEMPT!] Checking %ENDPOINT%...

REM Curl the endpoint and capture HTTP status code
for /f "delims=" %%i in ('curl -s -o nul -w "%%{http_code}" %ENDPOINT% 2^>nul') do set STATUS_CODE=%%i

REM Check if curl failed (empty response)
if "!STATUS_CODE!"=="" (
    echo   Status: Connection failed - Server not reachable
    echo   Retrying in %CHECK_INTERVAL% seconds...
    echo.
    timeout /t %CHECK_INTERVAL% /nobreak >nul
    goto check_loop
)

REM Check status code
if "!STATUS_CODE!"=="200" (
    set SERVER_UP=true
    echo   Status: !STATUS_CODE! OK
    echo.
    echo ========================================
    echo ✓ SERVER IS UP AND RUNNING!
    echo ========================================
    echo.
    echo Endpoint: %ENDPOINT%
    echo Response: 200 OK
    echo Total attempts: !ATTEMPT!
    echo.
    
    REM Play success sound
    if "%PLAY_SOUND%"=="true" (
        echo Playing alert sound...
        powershell -c "Add-Type -AssemblyName System.Speech; $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer; $synth.Speak('Server is up');"
        REM Alternative: Play Windows system sound
        powershell -c "[System.Media.SystemSounds]::Exclamation.Play()"
    )
    
    goto end
) else (
    echo   Status: !STATUS_CODE! - Server responding but not ready
    echo   Retrying in %CHECK_INTERVAL% seconds...
    echo.
    timeout /t %CHECK_INTERVAL% /nobreak >nul
    goto check_loop
)

:end
echo.
echo Monitoring stopped.
pause
endlocal