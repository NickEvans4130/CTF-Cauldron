@echo off
setlocal enabledelayedexpansion

echo ========================================
echo The Seeder - Database Population
echo ========================================
echo.

REM Configuration - Customize these settings
set API_BASE_URL=http://localhost:3000/api
set NUM_USERS=10
set NUM_POSTS=25
set NUM_COMMENTS=50
set AUTH_TOKEN=
REM Optional: Set if your API requires authentication

echo API Base URL: %API_BASE_URL%
echo Target: %NUM_USERS% users, %NUM_POSTS% posts, %NUM_COMMENTS% comments
echo.

set SUCCESS_COUNT=0
set FAIL_COUNT=0

REM Check if API is reachable
echo [0/4] Checking API availability...
curl -s -o nul -w "%%{http_code}" %API_BASE_URL:~0,-4%/health 2>nul | findstr "200" >nul
if %errorlevel% neq 0 (
    echo WARNING: API might not be reachable. Continuing anyway...
)
echo.

echo [1/4] Creating users...
for /L %%i in (1,1,%NUM_USERS%) do (
    set /a USER_NUM=%%i
    
    REM Generate user data
    set USERNAME=user%%i
    set EMAIL=user%%i@example.com
    set FIRSTNAME=User
    set LASTNAME=Number%%i
    
    REM Create JSON payload
    set JSON={"username":"!USERNAME!","email":"!EMAIL!","firstName":"!FIRSTNAME!","lastName":"!LASTNAME!","password":"Demo123!"}
    
    REM Send POST request
    if "!AUTH_TOKEN!"=="" (
        curl -s -X POST %API_BASE_URL%/users -H "Content-Type: application/json" -d "!JSON!" -o temp_response.txt
    ) else (
        curl -s -X POST %API_BASE_URL%/users -H "Content-Type: application/json" -H "Authorization: Bearer !AUTH_TOKEN!" -d "!JSON!" -o temp_response.txt
    )
    
    if !errorlevel! equ 0 (
        set /a SUCCESS_COUNT+=1
        echo   ✓ Created user: !USERNAME!
    ) else (
        set /a FAIL_COUNT+=1
        echo   ✗ Failed to create user: !USERNAME!
    )
    
    REM Small delay to avoid overwhelming the API
    timeout /t 0 /nobreak >nul
)
echo   Users created: !SUCCESS_COUNT!/!NUM_USERS!
echo.

echo [2/4] Creating posts...
set POST_SUCCESS=0
for /L %%i in (1,1,%NUM_POSTS%) do (
    set /a POST_NUM=%%i
    set /a USER_ID=!random! %% %NUM_USERS% + 1
    
    REM Generate post data
    set TITLE=Demo Post %%i: Sample Title
    set CONTENT=This is demo content for post %%i. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
    
    REM Create JSON payload
    set JSON={"title":"!TITLE!","content":"!CONTENT!","userId":!USER_ID!}
    
    REM Send POST request
    if "!AUTH_TOKEN!"=="" (
        curl -s -X POST %API_BASE_URL%/posts -H "Content-Type: application/json" -d "!JSON!" -o temp_response.txt
    ) else (
        curl -s -X POST %API_BASE_URL%/posts -H "Content-Type: application/json" -H "Authorization: Bearer !AUTH_TOKEN!" -d "!JSON!" -o temp_response.txt
    )
    
    if !errorlevel! equ 0 (
        set /a POST_SUCCESS+=1
        echo   ✓ Created post %%i
    ) else (
        echo   ✗ Failed to create post %%i
    )
    
    timeout /t 0 /nobreak >nul
)
echo   Posts created: !POST_SUCCESS!/!NUM_POSTS!
echo.

echo [3/4] Creating comments...
set COMMENT_SUCCESS=0
for /L %%i in (1,1,%NUM_COMMENTS%) do (
    set /a COMMENT_NUM=%%i
    set /a POST_ID=!random! %% %NUM_POSTS% + 1
    set /a USER_ID=!random! %% %NUM_USERS% + 1
    
    REM Generate comment data
    set TEXT=This is a sample comment %%i on the post. Great content!
    
    REM Create JSON payload
    set JSON={"text":"!TEXT!","postId":!POST_ID!,"userId":!USER_ID!}
    
    REM Send POST request
    if "!AUTH_TOKEN!"=="" (
        curl -s -X POST %API_BASE_URL%/comments -H "Content-Type: application/json" -d "!JSON!" -o temp_response.txt
    ) else (
        curl -s -X POST %API_BASE_URL%/comments -H "Content-Type: application/json" -H "Authorization: Bearer !AUTH_TOKEN!" -d "!JSON!" -o temp_response.txt
    )
    
    if !errorlevel! equ 0 (
        set /a COMMENT_SUCCESS+=1
        echo   ✓ Created comment %%i
    ) else (
        echo   ✗ Failed to create comment %%i
    )
    
    timeout /t 0 /nobreak >nul
)
echo   Comments created: !COMMENT_SUCCESS!/!NUM_COMMENTS!
echo.

echo [4/4] Cleanup...
if exist temp_response.txt del temp_response.txt
echo Temporary files removed.
echo.

echo ========================================
echo Seeding Complete!
echo ========================================
echo.
echo Summary:
echo   Users: !SUCCESS_COUNT!/!NUM_USERS!
echo   Posts: !POST_SUCCESS!/!NUM_POSTS!
echo   Comments: !COMMENT_SUCCESS!/!NUM_COMMENTS!
echo.

set /a TOTAL_CREATED=!SUCCESS_COUNT! + !POST_SUCCESS! + !COMMENT_SUCCESS!
set /a TOTAL_EXPECTED=!NUM_USERS! + !NUM_POSTS! + !NUM_COMMENTS!

echo Total Records: !TOTAL_CREATED!/!TOTAL_EXPECTED!
echo.

if !TOTAL_CREATED! equ !TOTAL_EXPECTED! (
    echo Status: ✓ All records created successfully!
) else (
    echo Status: ⚠ Some records failed to create
    echo Check your API logs for details
)

echo.
echo Your database is ready for demos! 🎉
echo ========================================

pause
endlocal