# Quick Start Guide: Deploy to GCP

## Method 1: Firebase Hosting (RECOMMENDED)

### Prerequisites:
- Google account
- Node.js installed (for Firebase CLI)

### Steps:

1. **Install Firebase CLI**
   ```powershell
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```powershell
   firebase login
   ```

3. **Initialize Firebase in your project**
   ```powershell
   # Navigate to your project folder (if not already there)
   cd C:\ptc\dev\Projects\szkolenia\Hackaton\FE
   
   # Initialize Firebase
   firebase init hosting
   ```
   
   **When prompted:**
   - "Please select an option": Choose "Use an existing project" or "Create a new project"
   - "What do you want to use as your public directory?": Type `.` (dot - current directory)
   - "Configure as a single-page app?": Type `n` (No)
   - "Set up automatic builds...?": Type `n` (No)
   - "File index.html already exists. Overwrite?": Type `N` (No)

4. **Deploy your website**
   ```powershell
   firebase deploy --only hosting
   ```

5. **Access your website**
   - After deployment completes, you'll see a URL like:
   - `https://your-project-id.web.app`
   - `https://your-project-id.firebaseapp.com`

### That's it! Your website is now live! 🎉

---

## Method 2: Google Cloud Storage (Simple Static Hosting)

### Steps:

1. **Install Google Cloud SDK**
   - Download from: https://cloud.google.com/sdk/docs/install
   - Or use PowerShell:
   ```powershell
   (New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
   & $env:Temp\GoogleCloudSDKInstaller.exe
   ```

2. **Initialize gcloud and login**
   ```powershell
   gcloud init
   gcloud auth login
   ```

3. **Create a GCS bucket (choose a globally unique name)**
   ```powershell
   # Set your project
   gcloud config set project YOUR_PROJECT_ID
   
   # Create bucket with unique name
   gsutil mb gs://tmobile-sprawdzai-chat
   ```

4. **Upload your files**
   ```powershell
   # Upload all files
   gsutil -m cp index.html styles.css script.js gs://tmobile-sprawdzai-chat/
   gsutil -m cp -r assets gs://tmobile-sprawdzai-chat/
   ```

5. **Make bucket publicly accessible**
   ```powershell
   gsutil iam ch allUsers:objectViewer gs://tmobile-sprawdzai-chat
   ```

6. **Configure as website**
   ```powershell
   gsutil web set -m index.html -e index.html gs://tmobile-sprawdzai-chat
   ```

7. **Access your website**
   - URL: `https://storage.googleapis.com/tmobile-sprawdzai-chat/index.html`

---

## Method 3: Cloud Run (With Docker - Most Flexible)

### Steps:

1. **Make sure Docker is installed locally** (optional - GCP can build for you)

2. **Set your project**
   ```powershell
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Enable required APIs**
   ```powershell
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable run.googleapis.com
   ```

4. **Build and deploy in one command**
   ```powershell
   gcloud run deploy sprawdzai-chat \
     --source . \
     --platform managed \
     --region europe-central2 \
     --allow-unauthenticated
   ```
   
   Or build container first, then deploy:
   ```powershell
   # Build container image
   gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/sprawdzai-chat
   
   # Deploy to Cloud Run
   gcloud run deploy sprawdzai-chat `
     --image gcr.io/YOUR_PROJECT_ID/sprawdzai-chat `
     --platform managed `
     --region europe-central2 `
     --allow-unauthenticated `
     --port 8080
   ```

5. **Access your website**
   - GCP will provide a URL like: `https://sprawdzai-chat-xxxxx-ez.a.run.app`

---

## Method 4: App Engine

### Steps:

1. **Create App Engine app (first time only)**
   ```powershell
   gcloud app create --region=europe-central2
   ```

2. **Deploy**
   ```powershell
   gcloud app deploy app.yaml
   ```

3. **Access your website**
   ```powershell
   gcloud app browse
   ```

---

## 🔒 Restricting Access to T-Mobile Employees Only

### For Firebase:
Use Firebase Authentication + custom security rules

### For Cloud Run/App Engine:
Use Identity-Aware Proxy (IAP):

```powershell
# Enable IAP
gcloud iap web enable

# Add users (example for Cloud Run)
gcloud run services add-iam-policy-binding sprawdzai-chat \
  --region=europe-central2 \
  --member='domain:t-mobile.pl' \
  --role='roles/run.invoker'
```

---

## 📊 Cost Comparison

| Service | Free Tier | Expected Cost |
|---------|-----------|---------------|
| **Firebase Hosting** | 10GB storage, 360MB/day transfer | **FREE** for this app |
| Cloud Storage | 5GB storage | ~$0.50/month |
| Cloud Run | 2M requests/month | ~$1-5/month |
| App Engine | 28 instance hours/day | ~$5-10/month |

**💡 Recommendation: Use Firebase Hosting - it's free and perfect for this use case!**

---

## 🌐 Adding Custom Domain (Optional)

### For Firebase:
1. Go to Firebase Console → Hosting → Add custom domain
2. Follow DNS configuration steps
3. Example: `sprawdzai.t-mobile.pl`

### For Cloud Run:
```powershell
gcloud beta run domain-mappings create \
  --service sprawdzai-chat \
  --domain sprawdzai.t-mobile.pl \
  --region europe-central2
```

---

## 🔧 Troubleshooting

### "Command not found: firebase"
```powershell
npm install -g firebase-tools
```

### "Command not found: gcloud"
Install Google Cloud SDK from: https://cloud.google.com/sdk/docs/install

### "Permission denied"
```powershell
gcloud auth login
```

### Firebase deployment fails
Make sure firebase.json exists in your directory and points to the correct files.

---

## 📝 Quick Deploy Checklist

- [ ] Install Firebase CLI: `npm install -g firebase-tools`
- [ ] Login: `firebase login`
- [ ] Initialize: `firebase init hosting`
- [ ] Deploy: `firebase deploy --only hosting`
- [ ] Test your URL
- [ ] (Optional) Add custom domain
- [ ] (Optional) Set up authentication for T-Mobile employees

---

Need help? Check the detailed DEPLOYMENT.md file in your project!
