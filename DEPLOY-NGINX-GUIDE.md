# 🚀 Deploy SprawdzAI Chat with nginx - Complete Guide

## What You'll Deploy

Your application will run on:
- **nginx** (lightweight, fast web server)
- **Google Cloud Run** (serverless, auto-scaling)
- **Docker container** (portable, reproducible)

---

## 📋 Quick Start (3 Steps)

### Step 1: Install Google Cloud SDK

Download and install from: https://cloud.google.com/sdk/docs/install

Or check if already installed:
```powershell
gcloud --version
```

### Step 2: Login and Set Project

```powershell
# Login to Google Cloud
gcloud auth login

# Set your project (or create a new one at console.cloud.google.com)
gcloud config set project YOUR_PROJECT_ID
```

### Step 3: Deploy!

```powershell
.\deploy-nginx.ps1
```

**That's it!** Your app will be live in ~5 minutes! 🎉

---

## 📁 Files Created for nginx Deployment

1. **Dockerfile** - Container configuration with nginx
2. **nginx.conf** - Web server configuration
3. **.dockerignore** - Excludes unnecessary files from container
4. **deploy-nginx.ps1** - Automated deployment script
5. **test-nginx.ps1** - Test locally before deploying
6. **NGINX-DEPLOY.md** - Detailed deployment documentation

---

## 🧪 Test Locally First (Optional)

Before deploying to GCP, you can test locally with Docker:

```powershell
.\test-nginx.ps1
```

This will:
- Build the Docker container
- Run nginx locally on port 8080
- Open http://localhost:8080 in your browser
- Let you verify everything works

**Don't have Docker?** Skip local testing and deploy directly to GCP!

---

## 🌐 Deploy to Google Cloud Run

### Automated Deployment (Recommended)

```powershell
.\deploy-nginx.ps1
```

The script will:
1. ✅ Check Google Cloud SDK is installed
2. ✅ Enable required APIs
3. ✅ Build Docker container with nginx
4. ✅ Push to Google Container Registry
5. ✅ Deploy to Cloud Run (Warsaw region)
6. ✅ Give you the live URL

### Manual Deployment

If you prefer manual control:

```powershell
# 1. Enable APIs
gcloud services enable cloudbuild.googleapis.com run.googleapis.com

# 2. Build container
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/sprawdzai-chat

# 3. Deploy to Cloud Run
gcloud run deploy sprawdzai-chat `
  --image gcr.io/YOUR_PROJECT_ID/sprawdzai-chat `
  --platform managed `
  --region europe-central2 `
  --allow-unauthenticated `
  --port 8080
```

---

## 🔧 nginx Configuration Highlights

Your nginx setup includes:

### Performance
- ✅ Gzip compression (smaller files, faster loading)
- ✅ 1-year caching for static assets (CSS, JS, images)
- ✅ Optimized for static content delivery

### Security
- ✅ Security headers (X-Frame-Options, X-XSS-Protection)
- ✅ Content type protection
- ✅ HTTPS automatic (via Cloud Run)

### Monitoring
- ✅ Health check endpoint: `/health`
- ✅ Access logs
- ✅ Error logs

---

## 💰 Cost

**Google Cloud Run Pricing:**
- **FREE Tier:** 2 million requests/month
- **After free tier:** ~$0.40 per million requests
- **Expected cost:** $1-5/month for typical usage

**Your app will:**
- Scale to 0 when not used (no cost)
- Auto-scale up when traffic increases
- Never crash from traffic spikes

---

## 🔒 Security Options

### Option 1: Public Access (Current Default)
Anyone with the URL can access the chat.

### Option 2: Restrict to T-Mobile Employees

After deployment, run:

```powershell
# Remove public access
gcloud run services update sprawdzai-chat `
  --no-allow-unauthenticated `
  --region europe-central2

# Grant access to T-Mobile domain
gcloud run services add-iam-policy-binding sprawdzai-chat `
  --region europe-central2 `
  --member='domain:t-mobile.pl' `
  --role='roles/run.invoker'
```

### Option 3: Specific Users Only

```powershell
gcloud run services add-iam-policy-binding sprawdzai-chat `
  --region europe-central2 `
  --member='user:email@t-mobile.pl' `
  --role='roles/run.invoker'
```

---

## 🌍 Custom Domain

Add your own domain (e.g., `sprawdzai.t-mobile.pl`):

```powershell
gcloud beta run domain-mappings create `
  --service sprawdzai-chat `
  --domain sprawdzai.t-mobile.pl `
  --region europe-central2
```

Then configure DNS as instructed by the command output.

---

## 📊 Monitoring

### View logs:
```powershell
gcloud run services logs read sprawdzai-chat --region europe-central2
```

### Real-time logs:
```powershell
gcloud run services logs tail sprawdzai-chat --region europe-central2
```

### Cloud Console:
https://console.cloud.google.com/run

---

## 🔄 Update Deployment

After making changes to your code:

```powershell
# Quick update - just run the deployment script again
.\deploy-nginx.ps1
```

Or manually:
```powershell
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/sprawdzai-chat
gcloud run deploy sprawdzai-chat --image gcr.io/YOUR_PROJECT_ID/sprawdzai-chat --region europe-central2
```

---

## ❌ Rollback

If something goes wrong:

```powershell
# List all revisions
gcloud run revisions list --service sprawdzai-chat --region europe-central2

# Rollback to previous revision
gcloud run services update-traffic sprawdzai-chat `
  --to-revisions REVISION_NAME=100 `
  --region europe-central2
```

---

## 🐛 Troubleshooting

### Problem: "gcloud: command not found"
**Solution:** Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install

### Problem: "Permission denied"
**Solution:** Login again:
```powershell
gcloud auth login
```

### Problem: "API not enabled"
**Solution:** The deployment script enables them automatically, or manually:
```powershell
gcloud services enable cloudbuild.googleapis.com run.googleapis.com
```

### Problem: Can't access deployed site
**Solution:** Check if service is running:
```powershell
gcloud run services describe sprawdzai-chat --region europe-central2
```

### Problem: 404 errors for static files
**Solution:** Check nginx logs:
```powershell
gcloud run services logs read sprawdzai-chat --region europe-central2 --limit 50
```

---

## 🎯 Comparison: nginx vs Other Methods

| Feature | nginx (Cloud Run) | Firebase | Cloud Storage |
|---------|-------------------|----------|---------------|
| **Setup** | ⭐⭐⭐ Medium | ⭐⭐⭐⭐⭐ Easy | ⭐⭐⭐⭐ Easy |
| **Control** | ⭐⭐⭐⭐⭐ Full | ⭐⭐⭐ Limited | ⭐⭐ Limited |
| **Performance** | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐⭐ Excellent | ⭐⭐⭐⭐ Good |
| **Scalability** | ⭐⭐⭐⭐⭐ Auto | ⭐⭐⭐⭐⭐ Auto | ⭐⭐⭐⭐ Manual |
| **Cost** | $1-5/mo | FREE | $0.50/mo |
| **SSL** | ✅ Auto | ✅ Auto | ⚠️ Manual |
| **Backend** | ✅ Easy to add | ⭐ Limited | ❌ No |
| **Docker** | ✅ Yes | ❌ No | ❌ No |

**Choose nginx (Cloud Run) if you:**
- ✅ Want full control over configuration
- ✅ Plan to add backend functionality later
- ✅ Need custom caching/compression rules
- ✅ Want to use Docker/containers
- ✅ Need enterprise-grade infrastructure

---

## ✅ Deployment Checklist

- [ ] Google Cloud SDK installed
- [ ] Logged in: `gcloud auth login`
- [ ] Project set: `gcloud config set project YOUR_PROJECT_ID`
- [ ] Run deployment: `.\deploy-nginx.ps1`
- [ ] Test the provided URL
- [ ] (Optional) Add custom domain
- [ ] (Optional) Restrict access to T-Mobile employees
- [ ] (Optional) Set up monitoring alerts

---

## 🚀 Ready to Deploy?

Run this command now:

```powershell
.\deploy-nginx.ps1
```

Your SprawdzAI Chat will be live in ~5 minutes!

---

## 📚 Additional Resources

- **nginx Documentation:** https://nginx.org/en/docs/
- **Cloud Run Documentation:** https://cloud.google.com/run/docs
- **Docker Documentation:** https://docs.docker.com/
- **Detailed Guide:** See NGINX-DEPLOY.md

---

## 🆘 Need Help?

1. Check NGINX-DEPLOY.md for detailed instructions
2. View logs: `gcloud run services logs read sprawdzai-chat --region europe-central2`
3. Check Cloud Console: https://console.cloud.google.com/run

---

**Questions? Issues?** Check the troubleshooting section above or review the deployment logs.
