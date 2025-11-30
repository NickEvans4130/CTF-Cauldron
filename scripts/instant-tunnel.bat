@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Instant Tunnel Launcher
echo ========================================
echo.

REM Configuration - Customize these settings
set LOCAL_PORT=3000
set NGROK_PATH=ngrok
set WEBHOOK_URL=
set WEBHOOK_TYPE=slack
REM Options: slack, discord, none

echo [1/4] Starting Ngrok tunnel on port %LOCAL_PORT%...
start /B "" %NGROK_PATH% http %LOCAL_PORT% >nul 2>&1

echo Waiting for tunnel to initialize...
timeout /t 3 /nobreak >nul
echo.

echo [2/4] Querying Ngrok API for public URL...
set TUNNEL_URL=

REM Query Ngrok API (localhost:4040)
for /f "delims=" %%i in ('curl -s http://localhost:4040/api/tunnels') do set RESPONSE=%%i

REM Extract public URL using basic string manipulation
echo !RESPONSE! > temp_ngrok.json

REM Use PowerShell to parse JSON properly
for /f "delims=" %%i in ('powershell -Command "$json = Get-Content temp_ngrok.json | ConvertFrom-Json; $json.tunnels[0].public_url"') do set TUNNEL_URL=%%i

del temp_ngrok.json

if "!TUNNEL_URL!"=="" (
    echo ERROR: Could not retrieve tunnel URL. Is Ngrok running?
    echo Check if Ngrok is installed and the local port %LOCAL_PORT% is correct.
    pause
    exit /b 1
)

echo Tunnel URL retrieved: !TUNNEL_URL!
echo.

echo [3/4] Copying URL to clipboard...
echo !TUNNEL_URL! | clip
echo URL copied to clipboard!
echo.

echo [4/4] Posting to webhook...
if "!WEBHOOK_URL!"=="" (
    echo No webhook configured. Skipping notification.
) else (
    if "!WEBHOOK_TYPE!"=="slack" (
        curl -X POST !WEBHOOK_URL! -H "Content-Type: application/json" -d "{\"text\":\"🚀 New tunnel started: !TUNNEL_URL!\"}"
        echo Notification sent to Slack.
    ) else if "!WEBHOOK_TYPE!"=="discord" (
        curl -X POST !WEBHOOK_URL! -H "Content-Type: application/json" -d "{\"content\":\"🚀 New tunnel started: !TUNNEL_URL!\"}"
        echo Notification sent to Discord.
    )
)
echo.

echo ========================================
echo Tunnel is LIVE!
echo ========================================
echo.
echo Public URL: !TUNNEL_URL!
echo Local Port: %LOCAL_PORT%
echo.
echo The URL has been copied to your clipboard.
echo Press any key to stop the tunnel...
echo ========================================

pause >nul

echo.
echo Stopping Ngrok tunnel...
taskkill /IM ngrok.exe /F >nul 2>&1
echo Tunnel stopped.

endlocal