# Test nginx deployment locally before pushing to GCP

Write-Host "================================================" -ForegroundColor Magenta
Write-Host "   Local nginx Test" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta
Write-Host ""

# Check if Docker is installed
Write-Host "Checking Docker..." -ForegroundColor Yellow
$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue

if (-not $dockerInstalled) {
    Write-Host "ERROR: Docker not found!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can skip local testing and deploy directly to GCP using:" -ForegroundColor Cyan
    Write-Host ".\deploy-nginx.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "Docker found!" -ForegroundColor Green
Write-Host ""

# Build Docker image
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -t sprawdzai-chat-test .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed. Please check the errors above." -ForegroundColor Red
    exit 1
}

Write-Host "Build successful!" -ForegroundColor Green
Write-Host ""

# Run container
Write-Host "Starting container on port 8080..." -ForegroundColor Yellow
Write-Host ""

# Stop any existing container
docker stop sprawdzai-test 2>$null
docker rm sprawdzai-test 2>$null

# Run new container
docker run -d -p 8080:8080 --name sprawdzai-test sprawdzai-chat-test

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to start container." -ForegroundColor Red
    exit 1
}

Write-Host "Container started successfully!" -ForegroundColor Green
Write-Host ""

# Wait for nginx to start
Write-Host "Waiting for nginx to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

# Test health endpoint
Write-Host "Testing health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "Health check: OK" -ForegroundColor Green
    }
} catch {
    Write-Host "Health check failed, but the site might still work" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "   nginx is running!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is available at:" -ForegroundColor Yellow
Write-Host "http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "Opening in browser..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
Start-Process "http://localhost:8080"

Write-Host ""
Write-Host "Press any key to stop the container..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "Stopping container..." -ForegroundColor Yellow
docker stop sprawdzai-test
docker rm sprawdzai-test

Write-Host "Container stopped and removed." -ForegroundColor Green
Write-Host ""
Write-Host "If everything worked, you can now deploy to GCP using:" -ForegroundColor Cyan
Write-Host ".\deploy-nginx.ps1" -ForegroundColor White
Write-Host ""
