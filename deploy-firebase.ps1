# Firebase Hosting Deployment Script
# Quick deployment for SprawdzAI Chat to GCP

Write-Host "================================================" -ForegroundColor Magenta
Write-Host "   SprawdzAI Chat - Firebase Deployment" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta
Write-Host ""

# Check if Firebase CLI is installed
Write-Host "Checking Firebase CLI..." -ForegroundColor Yellow
$firebaseInstalled = Get-Command firebase -ErrorAction SilentlyContinue

if (-not $firebaseInstalled) {
    Write-Host "Firebase CLI not found. Installing..." -ForegroundColor Red
    Write-Host "Running: npm install -g firebase-tools" -ForegroundColor Cyan
    npm install -g firebase-tools
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install Firebase CLI. Please install Node.js first:" -ForegroundColor Red
        Write-Host "https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Firebase CLI installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Firebase CLI found!" -ForegroundColor Green
}

Write-Host ""

# Login to Firebase
Write-Host "Logging in to Firebase..." -ForegroundColor Yellow
Write-Host "A browser window will open for authentication." -ForegroundColor Cyan
firebase login

if ($LASTEXITCODE -ne 0) {
    Write-Host "Login failed. Please try again." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Login successful!" -ForegroundColor Green
Write-Host ""

# Check if firebase.json exists
if (-not (Test-Path "firebase.json")) {
    Write-Host "firebase.json not found. Initializing Firebase..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Follow these steps:" -ForegroundColor Cyan
    Write-Host "1. Select or create a Firebase project" -ForegroundColor White
    Write-Host "2. Public directory: . (dot)" -ForegroundColor White
    Write-Host "3. Single-page app: N (No)" -ForegroundColor White
    Write-Host "4. Overwrite files: N (No)" -ForegroundColor White
    Write-Host ""
    
    firebase init hosting
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Initialization failed." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "firebase.json found!" -ForegroundColor Green
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Magenta
Write-Host "   Deploying to Firebase Hosting..." -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta
Write-Host ""

firebase deploy --only hosting

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "   DEPLOYMENT SUCCESSFUL! 🎉" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your SprawdzAI Chat is now live!" -ForegroundColor Yellow
    Write-Host "Check the Hosting URL above to access your site." -ForegroundColor White
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Test your website using the provided URL" -ForegroundColor White
    Write-Host "2. (Optional) Add a custom domain in Firebase Console" -ForegroundColor White
    Write-Host "3. (Optional) Set up authentication for T-Mobile employees" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Deployment failed. Please check the errors above." -ForegroundColor Red
    Write-Host ""
    exit 1
}
