@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Robots ^& Git Hunter
echo Low Hanging Fruit Finder
echo ========================================
echo.

REM Check if target was provided
if "%~1"=="" (
    echo ERROR: No target URL specified!
    echo.
    echo Usage: hunt.bat [URL]
    echo Example: hunt.bat https://example.com
    echo Example: hunt.bat http://192.168.1.100:8080
    pause
    exit /b 1
)

set TARGET=%~1
REM Ensure URL has protocol
echo %TARGET% | findstr /C:"http://" /C:"https://" >nul
if %errorlevel% neq 0 (
    echo Adding https:// prefix to URL...
    set TARGET=https://%TARGET%
)

echo Target: %TARGET%
echo.

REM Create output directory
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set DATE=%%c%%a%%b
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME=%%a%%b
set TIMESTAMP=%DATE%_%TIME: =0%

REM Extract domain for folder name
for /f "tokens=3 delims=:/" %%a in ("%TARGET%") do set DOMAIN=%%a
set OUTPUT_DIR=hunt_%DOMAIN%_%TIMESTAMP%

mkdir "%OUTPUT_DIR%" 2>nul
echo Results will be saved to: %OUTPUT_DIR%
echo.

set FOUND_COUNT=0
set CHECKED_COUNT=0

REM Define targets to check
set "TARGETS[0]=robots.txt"
set "TARGETS[1]=sitemap.xml"
set "TARGETS[2]=.env"
set "TARGETS[3]=.env.local"
set "TARGETS[4]=.env.production"
set "TARGETS[5]=.env.backup"
set "TARGETS[6]=.git/HEAD"
set "TARGETS[7]=.git/config"
set "TARGETS[8]=.gitignore"
set "TARGETS[9]=.DS_Store"
set "TARGETS[10]=backup.zip"
set "TARGETS[11]=backup.sql"
set "TARGETS[12]=database.sql"
set "TARGETS[13]=db_backup.sql"
set "TARGETS[14]=config.php"
set "TARGETS[15]=wp-config.php"
set "TARGETS[16]=phpinfo.php"
set "TARGETS[17]=admin"
set "TARGETS[18]=administrator"
set "TARGETS[19]=backup"
set "TARGETS[20]=.svn/entries"
set "TARGETS[21]=web.config"
set "TARGETS[22]=composer.json"
set "TARGETS[23]=package.json"
set "TARGETS[24]=README.md"
set "TARGETS[25]=CHANGELOG.md"
set "TARGETS[26]=.htaccess"
set "TARGETS[27]=server-status"
set "TARGETS[28]=server-info"

echo Starting scan...
echo.

REM Create summary file
echo ======================================== > "%OUTPUT_DIR%\summary.txt"
echo Robots ^& Git Hunter Results >> "%OUTPUT_DIR%\summary.txt"
echo ======================================== >> "%OUTPUT_DIR%\summary.txt"
echo Target: %TARGET% >> "%OUTPUT_DIR%\summary.txt"
echo Scan Date: %DATE% %TIME% >> "%OUTPUT_DIR%\summary.txt"
echo. >> "%OUTPUT_DIR%\summary.txt"
echo ======================================== >> "%OUTPUT_DIR%\summary.txt"
echo FOUND FILES: >> "%OUTPUT_DIR%\summary.txt"
echo ======================================== >> "%OUTPUT_DIR%\summary.txt"

REM Check each target
for /L %%i in (0,1,28) do (
    if defined TARGETS[%%i] (
        set /a CHECKED_COUNT+=1
        set "FILE=!TARGETS[%%i]!"
        set "URL=%TARGET%/!FILE!"
        
        REM Check if file exists
        for /f %%s in ('curl -s -o nul -w "%%{http_code}" "!URL!" 2^>nul') do set STATUS=%%s
        
        if "!STATUS!"=="200" (
            set /a FOUND_COUNT+=1
            echo [✓] FOUND: !FILE! ^(!STATUS!^)
            echo [✓] !URL! ^(!STATUS!^) >> "%OUTPUT_DIR%\summary.txt"
            
            REM Download the file
            set "SAFE_FILENAME=!FILE:/=_!"
            set "SAFE_FILENAME=!SAFE_FILENAME:.=_!"
            curl -s "!URL!" -o "%OUTPUT_DIR%\!SAFE_FILENAME!.txt" 2>nul
            
            REM Special handling for interesting files
            if "!FILE!"=="robots.txt" (
                echo   ^> robots.txt found - checking for interesting entries...
                type "%OUTPUT_DIR%\!SAFE_FILENAME!.txt" | findstr /C:"Disallow" /C:"Allow" 2>nul
            )
            
            if "!FILE!"==".git/HEAD" (
                echo   ^> .git directory exposed! Potential for git dumping.
                echo   ^> .git directory is EXPOSED! >> "%OUTPUT_DIR%\summary.txt"
            )
            
            if "!FILE!"==".env" (
                echo   ^> .env file exposed! Check for credentials.
                echo   ^> .env file contains potential credentials! >> "%OUTPUT_DIR%\summary.txt"
            )
            
        ) else if "!STATUS!"=="403" (
            echo [~] FORBIDDEN: !FILE! ^(exists but access denied^)
            echo [~] !URL! ^(403 - Forbidden^) >> "%OUTPUT_DIR%\summary.txt"
        ) else if "!STATUS!"=="401" (
            echo [~] AUTH REQUIRED: !FILE! ^(requires authentication^)
            echo [~] !URL! ^(401 - Auth Required^) >> "%OUTPUT_DIR%\summary.txt"
        ) else (
            echo [ ] Not found: !FILE!
        )
    )
)

echo.
echo ========================================
echo Scan Complete!
echo ========================================
echo.
echo Checked: !CHECKED_COUNT! targets
echo Found: !FOUND_COUNT! accessible files
echo.

REM Add summary to file
echo. >> "%OUTPUT_DIR%\summary.txt"
echo ======================================== >> "%OUTPUT_DIR%\summary.txt"
echo SUMMARY: >> "%OUTPUT_DIR%\summary.txt"
echo ======================================== >> "%OUTPUT_DIR%\summary.txt"
echo Checked: !CHECKED_COUNT! targets >> "%OUTPUT_DIR%\summary.txt"
echo Found: !FOUND_COUNT! accessible files >> "%OUTPUT_DIR%\summary.txt"
echo. >> "%OUTPUT_DIR%\summary.txt"

if !FOUND_COUNT! gtr 0 (
    echo Results saved to: %OUTPUT_DIR%
    echo.
    echo FINDINGS SUMMARY:
    type "%OUTPUT_DIR%\summary.txt" | findstr /C:"[✓]" /C:"[~]"
    echo.
    echo Review downloaded files in the output directory.
    
    REM Check for high-risk findings
    type "%OUTPUT_DIR%\summary.txt" | findstr /C:".git" /C:".env" /C:"backup" /C:"config" >nul
    if !errorlevel! equ 0 (
        echo.
        echo ⚠ WARNING: High-risk files found!
        echo   Check .git, .env, or config files for sensitive data.
    )
) else (
    echo No accessible files found.
    echo Target may be properly secured or not responding.
)

echo.
echo ========================================

REM Optional: Open results
set /p OPEN="Open results folder? (Y/N): "
if /i "%OPEN%"=="Y" explorer "%OUTPUT_DIR%"

endlocal