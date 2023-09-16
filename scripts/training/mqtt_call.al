#----------------------------------------------------------------------------------------------------------------------#
# Sample MQTT client to get sample data from data generated by EdgeX and published in CloudMQTT
# :sample-data:
# {
#   "apiVersion":"v2",
#   "id":"640dd0e0-935c-448a-af5c-f57e248bbe26",
#   "deviceName":"lighting",
#   "profileName":"LIGHTING_ANYLOG",
#   "sourceName":"LIGHTOUT2",
#   "origin":1694657552500724487,
#   "readings":[{
#       "id":"fce50687-b871-40b1-9970-9cfb92ec5208",
#       "origin":1694657552500724487,
#       "deviceName":"lighting",
#       "resourceName":"LIGHTOUT2",
#       "profileName":"LIGHTING_ANYLOG",
#       "valueType":"Int16",
#       "value":"1"
#   }]
# }
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/training/mqtt_call.al

on  error ignore

:set-params:
mqtt_broker = driver.cloudmqtt.com
mqtt_port = 18785
mqtt_user = ibglowct
mqtt_password = MSY4e009J7ts
mqtt_topic = anylogedgex-demo
set mqtt_log = false
if !default_dbms then set mqtt_dbms = !default_dbms
mqtt_table = "bring [sourceName]"
mqtt_timestamp_column = now
mqtt_value_column_type = float
mqtt_value_column = "bring [readings][][value]"

:run-mqtt-client:
on error call run-mqtt-client-error
<run mqtt client where broker=!mqtt_broker and port=!mqtt_port and user=!mqtt_user and password=!mqtt_passwd
and log=!mqtt_log and topic=(
    name=!mqtt_topic and
    dbms=!company_name.name and
    table=!mqtt_table and
    column.timestamp.timestamp=!mqtt_timestamp_column and
    column.value=(type=!mqtt_value_column_type and value=!mqtt_value_column)
)>

:end-script:
end script

:run-mqtt-client-error:
print "failed to start MQTT client"
goto end-script