@echo off
echo ========================================
echo War Room Launcher
echo ========================================
echo.

REM Configuration - Customize these paths for your environment
set BURP_PATH="C:\Program Files\BurpSuiteCommunity\BurpSuiteCommunity.exe"
set BROWSER_PATH="C:\Program Files\Google\Chrome\Application\chrome.exe"
set TARGET_URL=http://localhost:3000

echo [1/4] Launching Burp Suite...
start "" %BURP_PATH%
timeout /t 2 /nobreak >nul
echo Burp Suite launched.
echo.

echo [2/4] Opening browser with target URL...
start "" %BROWSER_PATH% %TARGET_URL% --new-window
timeout /t 1 /nobreak >nul
echo Browser launched.
echo.

echo [3/4] Launching Windows Terminal with split panes...
REM Check if Windows Terminal is available
where wt >nul 2>nul
if %errorlevel% equ 0 (
    start wt -w 0 new-tab --title "Recon" -d "%CD%" ^; split-pane -V --title "Exploit Dev" -d "%CD%" ^; split-pane -H --title "Logs" -d "%CD%" ^; new-tab --title "NetCat Listener" -d "%CD%"
    echo Windows Terminal launched with split panes.
) else (
    echo Windows Terminal not found. Launching standard CMD windows...
    start "Recon" cmd /k "cd /d %CD%"
    start "Exploit Dev" cmd /k "cd /d %CD%"
    start "Logs" cmd /k "cd /d %CD%"
    start "NetCat Listener" cmd /k "cd /d %CD%"
    echo Fallback: 4 separate CMD windows launched.
)
echo.

echo [4/4] Setting up tool environment...
REM Optional: Start common services or tools
REM Uncomment and customize as needed:
REM start "" "C:\Tools\Wireshark\Wireshark.exe"
REM docker-compose up -d
echo Environment ready.
echo.

echo ========================================
echo War Room is LIVE!
echo ========================================
echo.
echo Active Components:
echo   - Burp Suite (Proxy/Scanner)
echo   - Browser (%TARGET_URL%)
echo   - 4 Terminal Panes (Recon/Exploit/Logs/Listener)
echo.
echo Happy Hunting!
echo ========================================

pause