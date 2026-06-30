#----------------------------------------------------------------------------------------------------------------------#
# Data Generator - MQTT Topic Router
#
# Routes by MSG_TOPIC / !msg_topic to a topic-specific script. Each script owns its own msg client setup.
# Mapping topics (rig-data, wind-turbine, vessel-data) use mapping policies — not bring [table].
# rand-data uses data-generator/rand_data.al (generic bring [table] client — self-contained).
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/data-generator/data_generator.al

on error ignore

# Caller (mqtt_post_config.al) tears down stale clients before routing here.
# Quoted topic names — unquoted rig-data is not a string literal in AnyLog.
if      !msg_topic == "rig-data"      or $MSG_TOPIC == "rig-data"      then process !local_scripts/data-generator/oil_rig_data.al
else if !msg_topic == "wind-turbine"  or $MSG_TOPIC == "wind-turbine"  then process !local_scripts/data-generator/wind_turbine_data.al
else if !msg_topic == "vessel-data"   or $MSG_TOPIC == "vessel-data"   then process !local_scripts/data-generator/vessel_data.al
else if !msg_topic == "power-plant"   or $MSG_TOPIC == "power-plant"   then process !local_scripts/smart-city/power_plant.al
else if !msg_topic == "waste-water"   or $MSG_TOPIC == "waste-water"   then process !local_scripts/smart-city/waste_water_plant.al
else if !msg_topic == "water-plant"   or $MSG_TOPIC == "water-plant"   then process !local_scripts/smart-city/water_plant.al
else if !msg_topic == "rand-data"     or $MSG_TOPIC == "rand-data"     then process !local_scripts/data-generator/rand_data.al
else echo "Support for topic: " + !msg_topic + " not found"


:end-script:
end script
