docker run -it -d \
   -e CLIENT_TYPE=sparkplugb \
   -e MQTT_URL=mqtt://host.docker.internal \
   -e MQTT_PORT=32150 \
   -e SITE=Site -e AREA=Area -e LINE=Line \
   -e START=true \
   -e TICK=1000 \
--name sparkplug ghcr.io/libremfg/packml-simulator