# SuperMaze - Deployment Guide

## 🚀 Single File Deployment

SuperMaze is a **single-file PWA** - everything needed to run the app is in `index.html`.

### What's Embedded

✅ **Manifest.json** - PWA metadata (data URI in `<head>`)
✅ **Service Worker** - Offline support (JavaScript Blob)
✅ **All styles** - Bootstrap + custom CSS
✅ **All JavaScript** - Game logic + utilities
✅ **All icons** - Via Bootstrap Icons CDN

### Deploy Anywhere

```bash
# Copy just one file
cp index.html /var/www/supermaze/
```

**Supported platforms:**
- GitHub Pages (static hosting)
- Netlify (drag & drop)
- Vercel (git push)
- AWS S3 + CloudFront
- Firebase Hosting
- Any HTTP server (nginx, Apache, Node, etc.)

## 📦 File Size Breakdown

| Component | Size | Notes |
|-----------|------|-------|
| `index.html` | ~220KB | Uncompressed |
| Gzip'd | ~55KB | Typical compression |
| Bootstrap CDN | ~32KB | Loaded on first run |
| Bootstrap Icons CDN | ~110KB | Loaded on first run |
| **Total First Load** | **~200KB** | Over network |
| **Repeat Visits** | **~55KB** | Cached by Service Worker |

## 🌐 Server Configuration

### Apache (.htaccess)
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  
  # Cache busting - revalidate index.html
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
  
  # Cache static assets long-term
  <FilesMatch "\.(js|css|gif|jpg|png|svg)$">
    Header set Cache-Control "max-age=31536000, public"
  </FilesMatch>
</IfModule>
```

### Nginx
```nginx
server {
    listen 80;
    server_name supermaze.com;

    # Service Worker requires proper MIME type
    location ~ \.js$ {
        add_header Content-Type application/javascript;
        expires 1y;
    }

    # Always serve fresh index.html
    location = /index.html {
        expires 0;
        add_header Cache-Control "must-revalidate, no-cache";
    }

    # Cache other assets
    location ~* \.(css|gif|jpg|png|svg)$ {
        expires 1y;
    }

    # SPA routing - fallback to index.html
    location / {
        try_files $uri /index.html;
    }
}
```

### Node.js (Express)
```javascript
const express = require('express');
const app = express();

// Serve index.html with no-cache headers
app.get('/index.html', (req, res) => {
  res.set('Cache-Control', 'no-cache, must-revalidate');
  res.sendFile(__dirname + '/index.html');
});

// Cache other assets long-term
app.use(express.static(__dirname, {
  maxAge: '1y'
}));

// SPA fallback
app.get('*', (req, res) => {
  res.set('Cache-Control', 'no-cache, must-revalidate');
  res.sendFile(__dirname + '/index.html');
});

app.listen(3000);
```

### Python (HTTP Server)
```bash
# Simple testing server
python -m http.server 8000

# With HTTPS for Service Worker
python3 << 'EOF'
import http.server
import ssl

server = http.server.HTTPServer(('localhost', 8443), http.server.SimpleHTTPRequestHandler)
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain('cert.pem', 'key.pem')
server.socket = context.wrap_socket(server.socket, server_side=True)
server.serve_forever()
EOF
```

## 📱 HTTPS Requirement

**⚠️ Service Workers require HTTPS** (except localhost)

- ✅ Works on `http://localhost:*`
- ✅ Works on `https://yourdomain.com`
- ❌ Fails on `http://yourdomain.com` (not secure)

Get free SSL from:
- [Let's Encrypt](https://letsencrypt.org/)
- [Certbot](https://certbot.eff.org/)
- [CloudFlare](https://www.cloudflare.com/) (free tier)

## 🔍 Testing Deployment

### Check Service Worker
1. Open DevTools (F12)
2. Go to "Application" tab
3. Click "Service Workers"
4. Should show "active" status

### Check Offline Mode
1. Open DevTools
2. Go to "Network" tab
3. Check "Offline" checkbox
4. Reload page - should still work!
5. Click buttons - everything works offline

### Check PWA Install
1. Address bar shows install icon (💾)
2. Click install
3. App appears on home screen
4. Open from home screen - should be fullscreen

## 🚨 Common Issues

### Service Worker not registering
**Causes:**
- Not on HTTPS (except localhost)
- Service Worker script has JavaScript errors
- Browser caching old version

**Fix:**
- Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
- Clear site data in DevTools
- Check browser console for errors

### Manifest not found
**Cause:** Data URI was corrupted during encoding

**Fix:**
- Check that manifest data URI is properly escaped
- Validate JSON inside data URI at [jsonlint.com](https://www.jsonlint.com/)

### Cache too aggressive
**Cause:** Offline cache preventing updates

**Fix:**
- Service Worker automatically updates daily
- Manual: Clear cache in DevTools → Application → Storage → Clear
- Increment `CACHE_VERSION` in Service Worker code

## 📊 Performance Tips

1. **HTTP/2** - Enable on server for faster parallel downloads
2. **Gzip** - Server should compress responses
3. **CDN** - Use CDN for bootstrap and bootstrap-icons
4. **Cache Headers** - Follow config above
5. **Minification** - HTML is already compact

## 🔐 Security Headers

Add these to your server config:

```
Content-Security-Policy: default-src 'self' https://cdn.jsdelivr.net; script-src 'self'; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; font-src https://cdn.jsdelivr.net;
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

## 📈 Analytics

Service Worker is registered - you can track PWA installs:

```javascript
// Add to index.html for tracking
window.addEventListener('beforeinstallprompt', (e) => {
  // Track when install prompt appears
  console.log('Install prompt triggered');
});

window.addEventListener('appinstalled', () => {
  // Track when user installs app
  console.log('App installed');
});
```

## 🎯 Deployment Checklist

- [ ] HTML file copied to server
- [ ] HTTPS enabled (except localhost)
- [ ] Service Worker caching tested (offline mode)
- [ ] Manifest loading (check DevTools)
- [ ] App installable (address bar icon)
- [ ] Cache headers configured
- [ ] Hard refresh works (no stale cache)
- [ ] Mobile installation tested
- [ ] Offline gameplay verified
- [ ] Console clear of errors

## 📞 Troubleshooting

### Getting 404 errors
**Check:**
- Server returns 200 for `/index.html` on all routes
- Not returning `index.html` for CDN URLs

### Slow initial load
**Check:**
- Is gzip enabled? (`Content-Encoding: gzip`)
- Are CDN files cached? (should be < 100ms after first)
- Network waterfall in DevTools

### Install button missing
**Check:**
- HTTPS is enabled
- Manifest data URI is valid
- Chrome/Edge/Android (Safari differs)

## 🚀 Example Deployments

### GitHub Pages
```bash
git add index.html
git commit -m "Deploy SuperMaze"
git push origin main
# https://username.github.io/supermaze-main/
```

### Netlify (Drag & Drop)
1. Go to [netlify.com](https://netlify.com)
2. Drag `index.html` onto drop zone
3. Gets automatic HTTPS + CDN
4. Done!

### Vercel (Git)
```bash
git push  # Vercel auto-deploys
# https://supermaze.vercel.app
```

---

**Deploy once, update anytime - it's just one HTML file!** 🎉
