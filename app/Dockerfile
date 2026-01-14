FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -u 101 -U -d /var/www/html -s /bin/false nginx

COPY index.html /var/www/html/index.html

RUN mkdir -p /var/cache/nginx /var/log/nginx /var/lib/nginx /var/tmp/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /var/lib/nginx /var/tmp/nginx /var/run

USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
