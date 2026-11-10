# ==========================================
# Stage 1: Build the Flutter Web Application
# ==========================================
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Configure Git safe directory and Flutter Web
RUN git config --global --add safe.directory '*' \
    && flutter config --no-analytics \
    && flutter config --enable-web

# Pre-cache dependencies
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy all project source files
COPY . .

# Build the production Flutter Web release
RUN flutter pub get \
    && flutter build web --release

# ==========================================
# Stage 2: Runtime Web Server using Nginx
# ==========================================
FROM nginx:alpine

# Remove default Nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy Flutter web compiled static bundle
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration supporting client-side routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose Render standard web port
EXPOSE 10000

# Start Nginx in foreground mode
CMD ["nginx", "-g", "daemon off;"]

