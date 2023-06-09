:set-params:
on error ignore
if not !mqtt_log and $MQTT_LOG then set mqtt_log = $MQTT_LOG
else if not !mqtt_log then set mqtt_log = false

topic_name = trig-datas

:mqtt-client:
on error goto mqtt-client-error
if !anylog_broker_port then
<do run mqtt client where broker=local and port=!anylog_broker_port and log=!mqtt_log and topic=(
    name=!topic_name and
    dbms="bring [dbms]" and
    table="bring [table]" and
    column.timestamp.timestamp="bring [timestamp]" and
    column.value.float="bring [value]" and
    column.sin.float="bring [sin]" and
    column.cos.float="bring [cos]" and
    column.tan.float="bring [tan]"
)>
<else run mqtt client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=!mqtt_log and topic=(
    name=!topic_name and
    dbms="bring [dbms]" and
    table="bring [table]" and
    column.timestamp.timestamp="bring [timestamp]" and
    column.value.float="bring [value]" and
    column.sin.float="bring [sin]" and
    column.cos.float="bring [cos]" and
    column.tan.float="bring [tan]"
)>

:end-script:
end script

:json-policy-error:
echo "Invalid JSON format, cannot declare policy"
goto end-script

:declare-policy-error:
echo "Failed to declare policy on blockchain"
return