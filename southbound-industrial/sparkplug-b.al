#----------------------------------------------------------------------------------------------------------------------#
# The following provides automated script of the Sparkplug-B with data being sent directly into AnyLog broker
#
# :docker simulator:
#   docker run -it -d \
#       -e CLIENT_TYPE=sparkplugb \
#       -e MQTT_URL=mqtt://host.docker.internal \
#       -e MQTT_PORT=32150 \
#       -e SITE=Site -e AREA=Area -e LINE=Line \
#       -e START=true \
#       -e TICK=1000 \
#   --name sparkplug --rm ghcr.io/libremfg/packml-simulator
#
# :sample data:
# 2026-08-18T16:41:49.198Z | info: Site/Area/Line/Admin/MachDesignSpeed : 100
# 2026-08-18T16:41:49.199Z | info: Site/Area/Line/Status/MachSpeed : 100
# 2026-08-18T16:41:49.199Z | info: Site/Area/Line/Status/CurMachSpeed : 0
# 2026-08-18T16:41:49.199Z | info: Site/Area/Line/Admin/ProdConsumedCount/0/ID : 1
# 2026-08-18T16:41:49.200Z | info: Site/Area/Line/Admin/ProdConsumedCount/0/Name : Raw Material
# 2026-08-18T16:41:49.200Z | info: Site/Area/Line/Admin/ProdConsumedCount/0/Unit : Each
# 2026-08-18T16:41:49.200Z | info: Site/Area/Line/Admin/ProdConsumedCount/0/Count : 0
# 2026-08-18T16:41:49.200Z | info: Site/Area/Line/Admin/ProdConsumedCount/0/AccCount : 0
# 2026-08-18T16:41:49.200Z | info: Site/Area/Line/Admin/ProdDefectiveCount/0/ID : 2
# 2026-08-18T16:41:49.201Z | info: Site/Area/Line/Admin/ProdDefectiveCount/0/Name : Scrap
# 2026-08-18T16:41:49.201Z | info: Site/Area/Line/Admin/ProdDefectiveCount/0/Unit : Each
# 2026-08-18T16:41:49.201Z | info: Site/Area/Line/Admin/ProdDefectiveCount/0/Count : 0
# 2026-08-18T16:41:49.201Z | info: Site/Area/Line/Admin/ProdDefectiveCount/0/AccCount : 0
# 2026-08-18T16:41:49.202Z | info: Site/Area/Line/Admin/ProdProcessedCount/0/ID : 3
# 2026-08-18T16:41:49.202Z | info: Site/Area/Line/Admin/ProdProcessedCount/0/Name : Finished Goods
# 2026-08-18T16:41:49.202Z | info: Site/Area/Line/Admin/ProdProcessedCount/0/Unit : Each
# 2026-08-18T16:41:49.202Z | info: Site/Area/Line/Admin/ProdProcessedCount/0/Count : 0
# 2026-08-18T16:41:49.203Z | info: Site/Area/Line/Admin/ProdProcessedCount/0/AccCount : 0
#
# :generated json:
#   {"timestamp":"2026-08-18 18:22:42.000000","group_id":"Site","edge":"Area","device":"Line","msg_type":"DDATA","mach_speed":100}
#   {"timestamp":"2026-08-18 18:22:42.000000","group_id":"Site","edge":"Area","device":"Line","msg_type":"DDATA","cur_mach_speed":0}
#   {"timestamp":"2026-08-18 18:22:42.000000","group_id":"Site","edge":"Area","device":"Line","msg_type":"DDATA","consumed_id":1}
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/southbound-industrial/sparkplug-b.al

on error ignore

sparkplug_topic="spBv1.0/#"


:set-mapping:
process !local_scripts/southbound-industrial/sparkplug-b_mapping.al

:set-msg-client:
on error call msg-client-err

<run msg client where broker=local and decode = sparkplugb and log=false  and topic=(
  name = !sparkplug_topic and
  policy=!sparkplug_mapping_id
)>

:end-script:
end script

:msg-client-err:
echo "Failed to define msg client for sparkplug-b"
goto end-script
