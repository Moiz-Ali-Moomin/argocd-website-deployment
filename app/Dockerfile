FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

COPY index.html /var/www/html/index.html

RUN chown -R nginx:nginx /var/cache/nginx /var/run /var/log/nginx

USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
