# SpendWise – Personal Expense Tracker

SpendWise is a modern, responsive, 100% client-side Personal Expense Tracker built with **Flutter Web** and **Dart**, featuring **Material 3 UI** and persistent local storage powered by **SharedPreferences**.

This project is packaged and configured for **zero-configuration Docker Web Service deployment on [Render](https://render.com)**.

---

## Architecture Overview

```text
GitHub Repository (main branch)
       │
       ▼
Render Web Service (Automatic Git push webhook triggers build)
       │
       ▼
Docker Multi-Stage Build
  ├── Stage 1: Build (Flutter SDK compiles app to release WebAssembly / JS)
  └── Stage 2: Runtime (Ultra-lightweight Nginx Alpine container)
       │
       ▼
Nginx Web Server (Port 10000, Gzip, Client-Side Routing fallback to index.html)
       │
       ▼
User's Web Browser (IndexedDB / LocalStorage via SharedPreferences, 100% Offline)
```

---

## 1. Features & Technology Stack

- **Flutter & Dart Only:** Pure Flutter application codebase without heavy backend or third-party server frameworks.
- **Material 3 UI:** Fluid animations, responsive cards, category tags, and dynamic Light/Dark theme switching.
- **Responsive Layout:** Adaptive design that automatically adjusts between mobile phone viewports and widescreen desktop monitors.
- **Client-Side Persistence:** Transactions are stored in the user's browser using `shared_preferences` (HTML5 LocalStorage / IndexedDB). Data remains intact across page refreshes.
- **Offline Capable:** Full offline capabilities with zero external API dependencies.
- **Multi-Stage Docker Architecture:** Multi-stage build isolates the Flutter build environment from runtime, keeping the final production Docker image under 30MB.

---

## 2. Project Structure

```text
spendwise/
│
├── Dockerfile              # Multi-stage Docker build (Flutter SDK -> Nginx Alpine)
├── nginx.conf              # Nginx server configuration (Port 10000 + try_files SPA routing)
├── .dockerignore           # Excludes git, caches, and local dev files from build context
├── render.yaml             # Render Blueprint specification for automated Web Service provisioning
├── README.md               # Complete architecture & deployment guide
├── pubspec.yaml            # Project dependencies (shared_preferences, intl)
├── analysis_options.yaml   # Flutter lint analysis rules
│
├── lib/
│   ├── main.dart                      # App entry point, routing, & dashboard UI
│   ├── models/
│   │   └── transaction_item.dart      # Transaction model, categories, & JSON serialization
│   ├── services/
│   │   └── storage_service.dart       # SharedPreferences persistence & seed data
│   ├── theme/
│   │   └── app_theme.dart             # Material 3 light and dark theme configurations
│   └── widgets/
│       ├── category_breakdown.dart    # Category spend percentages and progress bars
│       ├── responsive_layout.dart     # Mobile & Desktop adaptive layout helper
│       ├── storage_info_banner.dart   # Educational persistence indicator & modal
│       ├── summary_card.dart          # Net balance, income, & expense overview
│       ├── transaction_card.dart      # Transaction list item with edit/delete actions
│       └── transaction_dialog.dart    # Modal dialog for creating and editing records
│
├── web/
│   ├── index.html          # HTML5 web shell with CSS pre-loader
│   ├── manifest.json       # Progressive Web App manifest
│   └── favicon.png         # Web icon
│
├── test/
│   └── widget_test.dart    # Unit & widget test suite
│
├── android/                # Android native wrapper
├── ios/                    # iOS native wrapper
├── linux/                  # Linux desktop wrapper
├── macos/                  # macOS desktop wrapper
└── windows/                # Windows desktop wrapper
```

---

## 3. Local Development & Testing

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.19.0 or higher)
- Google Chrome, Microsoft Edge, or any modern web browser

### Run Locally
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Run unit and widget test suite
flutter test

# 4. Start local development server with Chrome
flutter run -d chrome

# 5. Build production web bundle
flutter build web --release
```

---

## 4. Dockerfile Explanation

The project uses a two-stage `Dockerfile`:

1. **Build Stage (`ghcr.io/cirruslabs/flutter:stable`)**:
   - Copies `pubspec.yaml` and executes `flutter pub get` to leverage Docker layer caching.
   - Enables Flutter Web (`flutter config --enable-web`).
   - Runs `flutter build web --release` to compile Dart code into optimized JavaScript, WebAssembly, and static assets.
2. **Runtime Stage (`nginx:alpine`)**:
   - Inherits from the lightweight `nginx:alpine` image.
   - Copies the compiled `/app/build/web` directory directly into `/usr/share/nginx/html`.
   - Copies `nginx.conf` into `/etc/nginx/conf.d/default.conf`.
   - Exposes port `10000` (Render default web port).
   - Starts Nginx in foreground mode (`nginx -g 'daemon off;'`).
   - **Result:** The final image contains only Nginx and the static assets (~25MB), leaving the 3GB+ Flutter SDK out of production.

---

## 5. Nginx Configuration & SPA Routing

Flutter Web is a Single Page Application (SPA). When users refresh a subroute or deep link (such as `/transactions` or `/dashboard`), a basic static file server returns `404 Not Found`.

The included `nginx.conf` solves this by configuring fallback routing:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```
Key features in `nginx.conf`:
- **Port 10000:** Configured to bind on port `10000`, matching Render's default web service port.
- **Client-Side Routing:** Directs all unmatched URI requests back to `index.html`.
- **Gzip Compression:** Compresses JS, CSS, JSON, and WASM bundles for ultra-fast load times.
- **MIME Types:** Maps `.wasm` to `application/wasm` and `.js` to `application/javascript`.
- **Cache Invalidation:** Prevents caching of `index.html` and `flutter_service_worker.js` so users always receive updates immediately upon deployment.

---

## 6. Step-by-Step Render Deployment Guide

Follow these exact steps to deploy SpendWise on Render:

### Step 1: Push Code to GitHub

Initialize your repository (if not already done) and push all changes to GitHub:

```bash
# Check git status
git status

# Stage all files
git add .

# Commit changes
git commit -m "feat: complete SpendWise Flutter web app with Render Docker deployment"

# Set main branch
git branch -M main

# Verify or add your GitHub remote
# git remote add origin https://github.com/<your-username>/Spend_wise.git

# Push to GitHub
git push -u origin main
```

### Step 2: Render Account Setup
1. Visit [https://render.com](https://render.com) and log in or create a free account.
2. Connect your GitHub account to Render under **Account Settings > Connected Accounts**.

### Step 3: Deploy Method A — Using Render Blueprint (Recommended)
Because the repository includes `render.yaml`, you can deploy automatically:
1. In the Render Dashboard, click **New +** > **Blueprint**.
2. Select your `Spend_wise` repository.
3. Render will read `render.yaml` and configure the Web Service with Docker runtime, port 10000, and health check path `/`.
4. Click **Apply**.

### Step 4: Deploy Method B — Manual Dashboard Setup
If you prefer configuring via the web dashboard:
1. Click **New +** > **Web Service**.
2. Select **Build and deploy from a Git repository** and click **Next**.
3. Choose your `Spend_wise` repository and click **Connect**.
4. Configure the settings:
   - **Name:** `spendwise` (or your preferred service name)
   - **Region:** Choose the region closest to you (e.g., *Oregon (US West)* or *Frankfurt (EU)*)
   - **Branch:** `main`
   - **Root Directory:** Leave empty (defaults to project root `.`)
   - **Runtime:** `Docker`
   - **Dockerfile Path:** `./Dockerfile`
   - **Instance Type:** `Free`
5. Expand **Advanced Settings**:
   - **Health Check Path:** `/`
   - **Environment Variables:**
     - Key: `PORT`
     - Value: `10000`
6. Click **Create Web Service**.

---

## 7. Deployment Process & Accessing Your Live App

1. **Build Log Monitoring:**
   - Render pulls the Git repository and starts the Docker build.
   - Flutter dependencies are downloaded, and `flutter build web --release` compiles the application.
   - The final Nginx image is tagged and deployed.
2. **Health Check:**
   - Render verifies that `http://<your-service>.onrender.com/` returns HTTP 200 OK.
3. **Live URL:**
   - Once the build shows **Live**, open your public URL:
     `https://<your-service-name>.onrender.com`
4. Test functionality:
   - Add, edit, and delete transactions.
   - Refresh the page: notice that all data remains intact due to `SharedPreferences`.
   - Test sub-routes or reload: notice no 404 errors appear.

---

## 8. Data Persistence Architecture & Limitations

- **Browser Storage:** All transaction entries, categories, and balances are stored directly in the user's browser using the HTML5 Web Storage API (`SharedPreferences`).
- **Persistence Across Reloads:** Closing the tab or refreshing the page preserves all records.
- **Cache Clearing Impact:** If the user clears their browser cache, site data, or cookies, or uses Private/Incognito browsing, locally stored data will be cleared.
- **No Cloud Synchronization:** Data is stored locally per browser instance. Records do **not** automatically sync across multiple devices or different browsers.

---

## 9. Troubleshooting Common Deployment Failures

| Issue | Cause | Resolution |
| :--- | :--- | :--- |
| **Port Binding Error / Timed Out Health Check** | Container listening on port 80 instead of Render's expected port. | Verify `nginx.conf` has `listen 10000;`, `Dockerfile` has `EXPOSE 10000`, and `PORT=10000` is set in environment variables. |
| **404 Not Found on Route Refresh** | Missing single-page app fallback routing. | Ensure `nginx.conf` contains `try_files $uri $uri/ /index.html;`. |
| **Flutter Build Out of Memory in Docker** | Free builder RAM exhausted during dart2js compilation. | The multi-stage `Dockerfile` uses standard release mode without debug overhead. If memory is tight on older machines, `--no-source-maps` can be passed to `flutter build web`. |
| **Dubious Ownership in Git** | Container user UID differs from file ownership. | The Dockerfile includes `RUN git config --global --add safe.directory '*'`. |
| **MIME type error for .wasm files** | Nginx serving `.wasm` as `application/octet-stream`. | The included `nginx.conf` explicitly defines `types { application/wasm wasm; }`. |

---

## 10. License

This project is licensed under the MIT License.
