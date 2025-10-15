# CORS Fix Guide for SprawdzAI

## What is CORS?

CORS (Cross-Origin Resource Sharing) is a security feature that prevents websites from making requests to a different domain than the one serving the page.

**Your situation:**
- Frontend: Hosted on one domain (e.g., Firebase, Cloud Run, etc.)
- Backend API: `https://sprawdzai-1089571743905.europe-west4.run.app`

## ✅ Frontend Changes (Already Applied)

The `script.js` file has been updated with:
```javascript
fetch(url, {
    method: 'POST',
    mode: 'cors',           // Enable CORS
    credentials: 'omit',    // Don't send credentials
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    },
    body: JSON.stringify(...)
})
```

## 🔧 Backend Changes Required

### The backend server MUST return these headers:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: Content-Type, Accept
Access-Control-Max-Age: 86400
```

### Option 1: Python/Flask Backend

If your backend uses Flask:

```python
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Or more specific:
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Accept')
    response.headers.add('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    return response

@app.route('/run_sse', methods=['POST', 'OPTIONS'])
def run_sse():
    if request.method == 'OPTIONS':
        # Preflight request
        return '', 204
    
    # Your actual logic here
    data = request.json
    # ... process data ...
    return jsonify({
        'text': 'Response text',
        'source': None
    })
```

### Option 2: Python/FastAPI Backend

If your backend uses FastAPI:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=False,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

@app.post("/run_sse")
async def run_sse(request: dict):
    # Your logic here
    return {
        "text": "Response text",
        "source": None
    }
```

### Option 3: Node.js/Express Backend

If your backend uses Express:

```javascript
const express = require('express');
const cors = require('cors');

const app = express();

// Enable CORS for all routes
app.use(cors());

// Or manually:
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Accept');
    
    if (req.method === 'OPTIONS') {
        return res.sendStatus(204);
    }
    next();
});

app.post('/run_sse', (req, res) => {
    // Your logic here
    res.json({
        text: 'Response text',
        source: null
    });
});
```

## 🔐 Production Security (Recommended)

Instead of allowing all origins (`*`), specify your frontend domain:

```python
# Python/Flask
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', 'https://your-frontend-domain.com')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Accept')
    response.headers.add('Access-Control-Allow-Methods', 'POST,OPTIONS')
    response.headers.add('Access-Control-Allow-Credentials', 'true')
    return response
```

## 🌐 Using nginx as Reverse Proxy

If you want to avoid CORS entirely, use nginx as a proxy:

### Update nginx.conf:

```nginx
server {
    listen 8080;
    server_name _;

    # Serve frontend
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }

    # Proxy API requests to backend
    location /api/ {
        # Remove /api prefix and forward to backend
        rewrite ^/api/(.*)$ /$1 break;
        
        proxy_pass https://sprawdzai-1089571743905.europe-west4.run.app;
        proxy_set_header Host sprawdzai-1089571743905.europe-west4.run.app;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS' always;
        add_header Access-Control-Allow-Headers 'Content-Type, Accept' always;
        
        # Handle preflight
        if ($request_method = OPTIONS) {
            return 204;
        }
    }
}
```

### Update frontend to use relative path:

```javascript
// Change from:
const response = await fetch('https://sprawdzai-1089571743905.europe-west4.run.app/run_sse', {

// To:
const response = await fetch('/api/run_sse', {
```

This way, the request goes to the same domain (no CORS needed).

## 📋 Troubleshooting Checklist

### 1. Check if CORS headers are present

Open browser DevTools → Network tab → Check the response headers:

Should see:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

### 2. Check for preflight OPTIONS request

CORS makes a preflight OPTIONS request before POST. Your backend must handle it:

```python
@app.route('/run_sse', methods=['POST', 'OPTIONS'])
def run_sse():
    if request.method == 'OPTIONS':
        return '', 204  # Just return success for OPTIONS
    # ... rest of your code
```

### 3. Check browser console

Look for errors like:
- `Access to fetch at '...' has been blocked by CORS policy`
- `No 'Access-Control-Allow-Origin' header is present`

### 4. Test with curl

```bash
# Test OPTIONS request
curl -X OPTIONS https://sprawdzai-1089571743905.europe-west4.run.app/run_sse \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v

# Should return Access-Control-Allow-* headers
```

## 🔥 Quick Fix for Testing

For Cloud Run backend, you can enable CORS in the app or use Cloud Run's built-in CORS support.

### Update your backend deployment:

```python
# Add to your main.py or app.py
from flask import Flask
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})
```

Then redeploy:
```bash
gcloud run deploy your-service-name --source .
```

## 🎯 Summary

**What you need to do:**

1. ✅ **Frontend updated** (already done)
2. ⚠️ **Backend needs CORS headers** - Add to your backend code
3. 🔄 **Redeploy backend** after adding CORS support
4. ✅ **Test** - Check browser console for CORS errors

**Quick backend fix (Flask example):**
```bash
pip install flask-cors
```

```python
from flask_cors import CORS
CORS(app)
```

**Then redeploy your backend service!**

---

Need help with your specific backend framework? Let me know what you're using (Flask, FastAPI, Express, etc.)!
