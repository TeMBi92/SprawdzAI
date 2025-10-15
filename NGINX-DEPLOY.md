# Deploy SprawdzAI Chat with nginx on Google Cloud Run

## Quick Deployment

### Option 1: Automated Script (Easiest)

```powershell
.\deploy-nginx.ps1
```

This script will:
- Check if Google Cloud SDK is installed
- Enable required APIs
- Build Docker container with nginx
- Deploy to Cloud Run
- Give you the live URL

---

### Option 2: Manual Deployment

#### Step 1: Prerequisites

1. **Install Google Cloud SDK**
   ```powershell
   # Download from: https://cloud.google.com/sdk/docs/install
   ```

2. **Login and set project**
   ```powershell
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Enable required APIs**
   ```powershell
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable run.googleapis.com
   ```

#### Step 2: Build Docker Image

```powershell
# Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/sprawdzai-chat
```

#### Step 3: Deploy to Cloud Run

```powershell
gcloud run deploy sprawdzai-chat `
  --image gcr.io/YOUR_PROJECT_ID/sprawdzai-chat `
  --platform managed `
  --region europe-central2 `
  --allow-unauthenticated `
  --port 8080 `
  --memory 256Mi `
  --max-instances 10
```

#### Step 4: Get Your URL

```powershell
gcloud run services describe sprawdzai-chat `
  --platform managed `
  --region europe-central2 `
  --format 'value(status.url)'
```

---

## What's Included

### Dockerfile
- Based on `nginx:alpine` (lightweight)
- Copies all static files (HTML, CSS, JS)
- Custom nginx configuration
- Runs on port 8080 (Cloud Run standard)

### nginx.conf
- Serves static files
- Gzip compression enabled
- Security headers configured
- 1-year caching for static assets
- Health check endpoint at `/health`

---

## Testing Locally with Docker

### Build locally:
```powershell
docker build -t sprawdzai-chat .
```

### Run locally:
```powershell
docker run -p 8080:8080 sprawdzai-chat
```

### Open in browser:
```
http://localhost:8080
```

---

## Configuration Options

### Change region:
```powershell
--region us-central1      # USA
--region europe-west1     # Belgium
--region europe-central2  # Warsaw (default)
--region asia-east1       # Taiwan
```

### Adjust resources:
```powershell
--memory 128Mi    # Minimum (may be slow)
--memory 256Mi    # Default (recommended)
--memory 512Mi    # More memory

--cpu 1           # Default
--cpu 2           # More CPU power
```

### Set scaling:
```powershell
--min-instances 0           # Scale to zero (cost-effective)
--max-instances 10          # Maximum containers
--concurrency 80            # Requests per container
```

---

## Cost Estimate

**Cloud Run Pricing (europe-central2):**
- First 2 million requests/month: FREE
- After that: ~$0.40 per million requests
- Memory: ~$0.0000025 per GB-second
- CPU: ~$0.00002 per vCPU-second

**Expected cost for this app:** ~$1-5/month (depending on traffic)

**Cost optimization:**
- Use `--min-instances 0` to scale to zero when not in use
- 256Mi memory is sufficient for this static site
- 1 CPU is enough

---

## Restrict Access to T-Mobile Employees

### Option 1: Remove public access
```powershell
gcloud run services update sprawdzai-chat `
  --no-allow-unauthenticated `
  --region europe-central2
```

### Option 2: Add Identity-Aware Proxy (IAP)
```powershell
# Grant access to specific domain
gcloud run services add-iam-policy-binding sprawdzai-chat `
  --region europe-central2 `
  --member='domain:t-mobile.pl' `
  --role='roles/run.invoker'
```

### Option 3: Grant access to specific users
```powershell
gcloud run services add-iam-policy-binding sprawdzai-chat `
  --region europe-central2 `
  --member='user:email@t-mobile.pl' `
  --role='roles/run.invoker'
```

---

## Add Custom Domain

### Step 1: Map domain
```powershell
gcloud beta run domain-mappings create `
  --service sprawdzai-chat `
  --domain sprawdzai.t-mobile.pl `
  --region europe-central2
```

### Step 2: Configure DNS
Follow the instructions provided by the command above to add DNS records.

---

## Monitoring & Logs

### View logs:
```powershell
gcloud run services logs read sprawdzai-chat --region europe-central2
```

### View logs in real-time:
```powershell
gcloud run services logs tail sprawdzai-chat --region europe-central2
```

### View in Cloud Console:
```
https://console.cloud.google.com/run
```

---

## Update Deployment

### After making changes to your code:

1. **Build new image:**
   ```powershell
   gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/sprawdzai-chat
   ```

2. **Deploy update:**
   ```powershell
   gcloud run deploy sprawdzai-chat `
     --image gcr.io/YOUR_PROJECT_ID/sprawdzai-chat `
     --region europe-central2
   ```

Or simply run:
```powershell
.\deploy-nginx.ps1
```

---

## Rollback

### List revisions:
```powershell
gcloud run revisions list --service sprawdzai-chat --region europe-central2
```

### Rollback to previous version:
```powershell
gcloud run services update-traffic sprawdzai-chat `
  --to-revisions REVISION_NAME=100 `
  --region europe-central2
```

---

## Delete Service

```powershell
gcloud run services delete sprawdzai-chat --region europe-central2
```

---

## Troubleshooting

### Issue: "gcloud: command not found"
**Solution:** Install Google Cloud SDK from https://cloud.google.com/sdk/docs/install

### Issue: "Permission denied"
**Solution:** 
```powershell
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Issue: "API not enabled"
**Solution:**
```powershell
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
```

### Issue: Container fails to start
**Solution:** Check logs:
```powershell
gcloud run services logs read sprawdzai-chat --region europe-central2 --limit 50
```

### Issue: 404 errors for static files
**Solution:** Check that files are copied correctly in Dockerfile and nginx.conf path is correct

---

## Health Check

Test the health endpoint:
```powershell
curl https://YOUR_SERVICE_URL/health
```

Should return: `healthy`

---

## Summary

**To deploy now:**
```powershell
.\deploy-nginx.ps1
```

**Your app will be:**
- ✅ Running on nginx (fast, lightweight)
- ✅ Hosted on Google Cloud Run
- ✅ Auto-scaling (0 to 10 instances)
- ✅ HTTPS enabled automatically
- ✅ Global CDN
- ✅ Available in ~5 minutes

**Cost:** ~$1-5/month with normal traffic (first 2M requests free!)
