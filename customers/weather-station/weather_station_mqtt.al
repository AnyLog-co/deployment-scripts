#--------------------------------------------------------------------------------------------------------------#
# :Sample Data:
# temperature = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":76.0,"unit":"degF","source":"forecast"}
# humidity = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":36.42,"unit":"pct","source":"forecast"}
# pressure = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":1009.28,"unit":"hPa","source":"forecast"}
# wind_speed = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":3.54,"unit":"m/s","source":"forecast"}
# wind_direction = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":13.17,"unit":"deg","source":"forecast"}
# rain = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":0.0,"unit":"mm","source":"forecast"}
#--------------------------------------------------------------------------------------------------------------#
# process !local_scripts/customers/weather_station_demo/weather_station_mqtt.al


# temperature = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":76.0,"unit":"degF","source":"forecast"}
# humidity = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":36.42,"unit":"pct","source":"forecast"}
# pressure = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":1009.28,"unit":"hPa","source":"forecast"}
# wind_speed = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":3.54,"unit":"m/s","source":"forecast"}
# wind_direction = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":13.17,"unit":"deg","source":"forecast"}
# rain = {"station_id":"WS-001","location":"Fresno, CA","ts":"2026-11-17T19:33:52Z","value":0.0,"unit":"mm","source":"forecast"}

policy_id = weather-stations
set create_policy = false

:check-policy:
is_policy = blockchain get (mapping, transform) where id = !policy_id
if not !is_policy and !create_policy == false then goto declare-policy
else if !is_policy then goto run-msg-client
else if not !is_policy and !create_policy == true then goto declare-policy-error

:declare-policy:
set new_policy = ""
<new_policy = {
    "mapping": {
        "id": !policy_id,
        "dbms": !default_dbms,
        "table": "",
        "group_by_attributes": ["station_id"],
        "readings": "",
        "schema": {
          "timestamp": {
            "type": "timestamp",
            "default": "now()",
            "bring": "[ts]"
          },
          "station_id": {
            "type": "string",
            "default": null,
            "bring": "[station_id]"
          },
          "location": {
            "type": "string",
            "default": null,
            "bring": "[location]"
          },
          "unit": {
            "type": "string",
            "default": null,
            "bring": "[unit]"
          },
          "source": {
            "type": "string",
            "default": null,
            "bring": "[source]"
          },
          "value": {
            "type": "float",
            "default": null,
            "bring": "[value]"
          }
        }
    }
}>

:publish-policy:
process !local_scripts/node-deployment/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-policy

if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error


:run-msg-client:
on error ignore
# run msg client where broker = 172.104.228.251 and port = 1883 and user=anyloguser and password=mqtt4AnyLog! and
<run msg client where broker = local and
    master_node=!ledger_conn and log=false and topic=(
        name=ws/WS-001/heartbeat and
        dbms=!default_dbms and
        table=heartbeat and
        column.timestamp.timestamp="now()" and
       column.station_id.str="bring [station_id]" and
       column.heartbeat.float="bring [heartbeat]"
    ) and topic = (
        name="ws/WS-001/#" and
        policy=!policy_id and
        dynamic=true and
        table=weather_stations
)>



:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts
