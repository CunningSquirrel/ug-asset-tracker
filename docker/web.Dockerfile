# Web image: nginx + the app. Built by GitHub Actions → ghcr.io/<owner>/ug-asset-tracker-web
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY html/index.html /usr/share/nginx/html/index.html
EXPOSE 80
