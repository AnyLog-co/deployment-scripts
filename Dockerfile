FROM busybox

COPY . deployment-scripts/

CMD ["sh", "-c", "mkdir -p /target && cp -a /deployment-scripts/. /target/ && echo 'deployment-scripts copied to volume'"]
