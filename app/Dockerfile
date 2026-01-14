FROM ubuntu:22.04

RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/conf.d/default.conf

RUN useradd -u 101 -U -d /var/www/html -s /sbin/nologin nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /var/www/html/index.html

RUN chown -R nginx:nginx /var/www/html

USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
