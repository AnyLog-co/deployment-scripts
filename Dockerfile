FROM busybox
WORKDIR /app
COPY . /app/deployment-scripts/

CMD ["sh", "-c", "mkdir -p /target && cp -a /app/deployment-scripts/. /target/ && echo 'deployment-scripts copied to volume'"]