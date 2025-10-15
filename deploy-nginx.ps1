# Deploy SprawdzAI Chat to Google Cloud Run with nginx
# This script builds a Docker container with nginx and deploys it to GCP

Write-Host "================================================" -ForegroundColor Magenta
Write-Host "   SprawdzAI - Cloud Run Deployment (nginx)" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta
Write-Host ""

# Configuration
$SERVICE_NAME = "sprawdzai-chat"
$REGION = "europe-central2"  # Warsaw region

# Check if gcloud is installed
Write-Host "Checking Google Cloud SDK..." -ForegroundColor Yellow
$gcloudInstalled = Get-Command gcloud -ErrorAction SilentlyContinue

if (-not $gcloudInstalled) {
    Write-Host "ERROR: Google Cloud SDK not found!" -ForegroundColor Red
    Write-Host "Please install it from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Google Cloud SDK found!" -ForegroundColor Green
Write-Host ""

# Get current project
Write-Host "Getting current GCP project..." -ForegroundColor Yellow
$PROJECT_ID = gcloud config get-value project 2>$null

if ([string]::IsNullOrEmpty($PROJECT_ID)) {
    Write-Host "No project configured. Please set your project:" -ForegroundColor Red
    Write-Host "gcloud config set project YOUR_PROJECT_ID" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or initialize gcloud:" -ForegroundColor Yellow
    Write-Host "gcloud init" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Current project: $PROJECT_ID" -ForegroundColor Green
Write-Host ""

# Confirm deployment
Write-Host "Deployment Configuration:" -ForegroundColor Cyan
Write-Host "  Project:      $PROJECT_ID" -ForegroundColor White
Write-Host "  Service:      $SERVICE_NAME" -ForegroundColor White
Write-Host "  Region:       $REGION" -ForegroundColor White
Write-Host "  Container:    nginx:alpine" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Continue with deployment? (Y/N)"
if ($continue -ne "Y" -and $continue -ne "y") {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Enable required APIs
Write-Host "Enabling required Google Cloud APIs..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Cyan

gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_ID
gcloud services enable run.googleapis.com --project=$PROJECT_ID
gcloud services enable containerregistry.googleapis.com --project=$PROJECT_ID

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to enable APIs. Please check your permissions." -ForegroundColor Red
    exit 1
}

Write-Host "APIs enabled successfully!" -ForegroundColor Green
Write-Host ""

# Build container image
Write-Host "================================================" -ForegroundColor Magenta
Write-Host "   Building Docker Container..." -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta
Write-Host ""

$IMAGE_NAME = "gcr.io/$PROJECT_ID/$SERVICE_NAME"
Write-Host "Building image: $IMAGE_NAME" -ForegroundColor Cyan

gcloud builds submit --tag $IMAGE_NAME --project=$PROJECT_ID

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Build failed. Please check the errors above." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Container built successfully!" -ForegroundColor Green
Write-Host ""

# Deploy to Cloud Run
Write-Host "================================================" -ForegroundColor Magenta
Write-Host "   Deploying to Cloud Run..." -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta
Write-Host ""

gcloud run deploy $SERVICE_NAME `
    --image $IMAGE_NAME `
    --platform managed `
    --region $REGION `
    --allow-unauthenticated `
    --port 8080 `
    --memory 256Mi `
    --cpu 1 `
    --max-instances 10 `
    --project=$PROJECT_ID

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "   DEPLOYMENT SUCCESSFUL! 🎉" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    
    # Get service URL
    $SERVICE_URL = gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)' --project=$PROJECT_ID
    
    Write-Host "Your SprawdzAI Chat is now live!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "URL: $SERVICE_URL" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Visit the URL above to test your application" -ForegroundColor White
    Write-Host "2. (Optional) Add custom domain:" -ForegroundColor White
    Write-Host "   gcloud run domain-mappings create --service $SERVICE_NAME --domain your-domain.com --region $REGION" -ForegroundColor Gray
    Write-Host "3. (Optional) Restrict access to T-Mobile employees:" -ForegroundColor White
    Write-Host "   gcloud run services update $SERVICE_NAME --no-allow-unauthenticated --region $REGION" -ForegroundColor Gray
    Write-Host ""
    
    # Open in browser
    $openBrowser = Read-Host "Open in browser? (Y/N)"
    if ($openBrowser -eq "Y" -or $openBrowser -eq "y") {
        Start-Process $SERVICE_URL
    }
    
} else {
    Write-Host ""
    Write-Host "Deployment failed. Please check the errors above." -ForegroundColor Red
    Write-Host ""
    exit 1
}
