@echo off
echo ========================================
echo Docker Workspace Nuke ^& Pave
echo ========================================
echo.

echo [1/5] Stopping all running containers...
docker stop $(docker ps -aq) 2>nul
if %errorlevel% neq 0 (
    echo No containers to stop.
) else (
    echo Containers stopped successfully.
)
echo.

echo [2/5] Removing all containers...
docker rm $(docker ps -aq) 2>nul
if %errorlevel% neq 0 (
    echo No containers to remove.
) else (
    echo Containers removed successfully.
)
echo.

echo [3/5] Pruning Docker system (removing unused data)...
docker system prune -af --volumes
echo System pruned successfully.
echo.

echo [4/5] Pruning Docker builder cache...
docker builder prune -af
echo Builder cache pruned successfully.
echo.

echo [5/5] Rebuilding project with docker-compose...
docker-compose up --build -d
echo.

if %errorlevel% equ 0 (
    echo ========================================
    echo Nuke ^& Pave completed successfully!
    echo ========================================
) else (
    echo ========================================
    echo Warning: docker-compose build encountered errors
    echo ========================================
)

pause