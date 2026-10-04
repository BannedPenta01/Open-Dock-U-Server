@echo off
REM ========================================
REM  Pretendo Network Server - Windows Batch
REM  Build & Start Script
REM  (Splatoon, Smash Wii U, Pokken, Mario Kart 8)
REM  (Mario Kart 7 DISABLED)
REM ========================================
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   Pretendo Network Server - Quick Start
echo   (Mario Kart 7 DISABLED)
echo.
echo   Enabled games:
echo     - Splatoon
echo     - Super Smash Bros. Wii U
echo     - Pokken Tournament
echo     - Mario Kart 8
echo ========================================
echo.

cd /d "%~dp0"

REM --------------------------------------------------
REM Step 1: Check Docker
REM --------------------------------------------------
echo [i] Checking Docker...

where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [x] Docker is not installed or not in PATH.
    echo    Download: https://docs.docker.com/desktop/setup/install/windows-install/
    pause
    exit /b 1
)

docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [!] Docker Desktop is not running.
    echo    Start Docker Desktop from the Start Menu and try again.
    pause
    exit /b 1
)

echo [^] Docker is running.

REM --------------------------------------------------
REM Step 2: Check Git
REM --------------------------------------------------
echo [i] Checking Git...

where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [!] Git is not installed or not in PATH.
    echo    Using existing submodules if available...
) else (
    echo [^] Git found.
)

REM --------------------------------------------------
REM Step 3: Update submodules (if git is available)
REM --------------------------------------------------
where git >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [i] Resetting submodules...
    git submodule foreach --recursive "git reset --hard" 2>nul
    git submodule foreach --recursive "git clean -fd" 2>nul
    
    echo [i] Updating submodules...
    git submodule update --init --checkout 2>nul
    if !ERRORLEVEL! NEQ 0 (
        echo [!] Submodule update had issues, continuing anyway...
    ) else (
        echo [^] Submodules ready.
    )
)

REM --------------------------------------------------
REM Step 4: Build only the needed images
REM --------------------------------------------------
echo.
echo [i] Building Docker images (this may take a while)...
echo    Target services: splatoon, super-smash-bros-wiiu, pokken-tournament, mario-kart-8
echo    (Mario Kart 7 is disabled)
echo.

docker compose build splatoon super-smash-bros-wiiu pokken-tournament mario-kart-8
if %ERRORLEVEL% NEQ 0 (
    echo [!] Build had some issues, continuing...
)

REM --------------------------------------------------
REM Step 5: Start containers (infrastructure + target games)
REM --------------------------------------------------
echo [i] Starting Docker containers...

docker compose up -d splatoon super-smash-bros-wiiu pokken-tournament mario-kart-8
if %ERRORLEVEL% NEQ 0 (
    echo [x] Failed to start containers.
    echo    Check logs: docker compose logs
    pause
    exit /b 1
)

echo [^] Docker containers started successfully!

REM --------------------------------------------------
REM Step 6: Show running containers
REM --------------------------------------------------
echo.
echo [i] Running containers:
docker compose ps

echo.
echo ========================================
echo   Server is running!
echo.
echo   Access the web interface at:
echo     http://localhost
echo.
echo   Enabled games:
echo     - Splatoon
echo     - Super Smash Bros. Wii U
echo     - Pokken Tournament
echo     - Mario Kart 8
echo.
echo   Useful commands:
echo     View logs:       docker compose logs -f
echo     Stop server:     docker compose down
echo     Restart server:  docker compose restart
echo     Start more:      docker compose up -d [service-name]
echo ========================================

pause