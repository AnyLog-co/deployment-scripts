#-----------------------------------------------------------------------------------------------------------------------
# The following file is intended as a placeholder for user implemented code. The file is automatically called by master,
# operator, publisher, query or single_node (operator / publisher) files. If not is written then nothing runs.
#
# Sample commands could include things like;
#   * complicated MQTT calls
#   * Kafka requests
#   * non-standard schedule processes, such as recording disk usage and automated queries
#
# Documentation: https://github.com/AnyLog-co/documentation
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/local_script.al
on error ignore

<new_policy={
  "mapping": {
    "id": "weather-station-heartbeat",
    "dbms": "env_sensor",
    "table": "",
    "group_by_attributes": ["station_id"],
    "readings": "",
    "schema": {
      "timestamp": {"type": "timestamp", "default": "now()", "bring": "[ts]"},
      "station_id": {"type": "string", "default": null, "bring": "[station_id]"},
      "location": {"type": "string", "default": null, "bring": "[location]"},
      "source": {"type": "string", "default": null, "bring": "[source]"},
      "temperature": {"type": "float", "default": null, "bring": "[temperature]"},
      "temperature_unit": {"type": "string", "default": null, "bring": "[temperature_unit]"},
      "humidity": {"type": "float", "default": null, "bring": "[humidity]"},
      "humidity_unit": {"type": "string", "default": null, "bring": "[humidity_unit]"},
      "pressure": {"type": "float", "default": null, "bring": "[pressure]"},
      "pressure_unit": {"type": "string", "default": null, "bring": "[pressure_unit]"},
      "wind_speed": {"type": "float", "default": null, "bring": "[wind_speed]"},
      "wind_speed_unit": {"type": "string", "default": null, "bring": "[wind_speed_unit]"},
      "wind_direction": {"type": "float", "default": null, "bring": "[wind_direction]"},
      "wind_direction_unit": {"type": "string", "default": null, "bring": "[wind_direction_unit]"},
      "rain": {"type": "float", "default": null, "bring": "[rain]"},
      "rain_unit": {"type": "string", "default": null, "bring": "[rain_unit]"},
      "heartbeat": {"type": "float", "default": null, "bring": "[heartbeat]"}
    }
  }
}>

blockchain insert where policy=!new_policy and local=true and master_node=!ledger_conn


<run msg client where
    broker = local and
    master_node = !ledger_conn and
    log = false and
    topic = (
        name = "ws/WS-001/#" and
        table = mqtt_weather_stations and
        policy = weather-station-heartbeat and
        auto_uns = true and
        dbms = !default_dbms and
        table_per_value = true and
        generated_tables = (
            temperature + temperature_unit + station_id,
            humidity + humidity_unit + station_id,
            pressure + pressure_unit + station_id,
            wind_speed + wind_speed_unit + station_id,
            wind_direction + wind_direction_unit + station_id,
            rain + rain_unit + station_id,
            heartbeat + station_id + source + location
        )
    )>