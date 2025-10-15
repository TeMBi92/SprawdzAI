@echo off
echo ================================================
echo    SprawdzAI Chat - Firebase Deployment
echo ================================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js is not installed!
    echo Please install Node.js from: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo Node.js found!
echo.

REM Check if Firebase CLI is installed
where firebase >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Firebase CLI not found. Installing...
    call npm install -g firebase-tools
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install Firebase CLI
        pause
        exit /b 1
    )
    echo Firebase CLI installed successfully!
) else (
    echo Firebase CLI found!
)

echo.
echo Logging in to Firebase...
echo A browser window will open for authentication.
echo.

call firebase login
if %ERRORLEVEL% NEQ 0 (
    echo Login failed
    pause
    exit /b 1
)

echo.
echo Login successful!
echo.

REM Check if firebase.json exists
if not exist firebase.json (
    echo firebase.json not found. Initializing Firebase...
    echo.
    echo Follow these steps:
    echo 1. Select or create a Firebase project
    echo 2. Public directory: . (dot)
    echo 3. Single-page app: N (No)
    echo 4. Overwrite files: N (No)
    echo.
    
    call firebase init hosting
    if %ERRORLEVEL% NEQ 0 (
        echo Initialization failed
        pause
        exit /b 1
    )
) else (
    echo firebase.json found!
)

echo.
echo ================================================
echo    Deploying to Firebase Hosting...
echo ================================================
echo.

call firebase deploy --only hosting

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ================================================
    echo    DEPLOYMENT SUCCESSFUL!
    echo ================================================
    echo.
    echo Your SprawdzAI Chat is now live!
    echo Check the Hosting URL above to access your site.
    echo.
) else (
    echo.
    echo Deployment failed. Please check the errors above.
    echo.
)

pause
