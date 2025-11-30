@echo off
setlocal enabledelayedexpansion

echo ========================================
echo WIP Saver - Git Panic Save
echo ========================================
echo.

REM Check if we're in a git repository
git rev-parse --git-dir >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Not a git repository!
    echo Please run this script from within a git repository.
    pause
    exit /b 1
)

REM Get current branch name
for /f "delims=" %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i

REM Generate timestamp
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
    set DATE=%%c-%%a-%%b
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set TIME=%%a:%%b
)
set TIMESTAMP=%DATE% %TIME%

REM Allow custom message or use default
set CUSTOM_MSG=%*
if "%CUSTOM_MSG%"=="" (
    set COMMIT_MSG=WIP: %TIMESTAMP%
) else (
    set COMMIT_MSG=WIP: %CUSTOM_MSG% - %TIMESTAMP%
)

echo Current Branch: %CURRENT_BRANCH%
echo Commit Message: %COMMIT_MSG%
echo.

echo [1/4] Checking for changes...
git status --short
echo.

echo [2/4] Adding all changes...
git add -A
if %errorlevel% neq 0 (
    echo ERROR: Git add failed!
    pause
    exit /b 1
)
echo ✓ All changes staged
echo.

echo [3/4] Creating commit...
git commit -m "%COMMIT_MSG%"
if %errorlevel% neq 0 (
    echo ERROR: Git commit failed!
    echo This might mean there are no changes to commit.
    pause
    exit /b 1
)
echo ✓ Commit created
echo.

echo [4/4] Pushing to remote...
git push origin %CURRENT_BRANCH%
if %errorlevel% neq 0 (
    echo.
    echo WARNING: Push failed!
    echo This might mean:
    echo   - No remote is configured
    echo   - You need to set upstream: git push --set-upstream origin %CURRENT_BRANCH%
    echo   - Network issues or authentication problems
    echo.
    echo Your changes are committed locally but not pushed.
    pause
    exit /b 1
)
echo ✓ Changes pushed to remote
echo.

echo ========================================
echo ✓ WIP SAVED SUCCESSFULLY!
echo ========================================
echo.
echo Branch: %CURRENT_BRANCH%
echo Commit: %COMMIT_MSG%
echo Status: Pushed to remote
echo.
echo Your work is safe! 🎉
echo ========================================

pause
endlocal