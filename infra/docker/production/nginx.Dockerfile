FROM nginx:1.27-alpine

COPY infra/nginx/agrilink-api.conf /etc/nginx/conf.d/default.conf
COPY apps/api/public /var/www/html/public
