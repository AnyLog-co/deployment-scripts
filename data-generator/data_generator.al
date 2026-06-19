#----------------------------------------------------------------------------------------------------------------------#
# Data Generator - MQTT Topic Router
#
# Routes incoming data to the appropriate data generator script based on the value of !msg_topic.
# All topics source data from the public MQTT broker:
#   broker=172.104.228.251, port=1883, user=anyloguser, password=mqtt4AnyLog!
#
# Supported topics and their MQTT subscriptions:
#   rand-data     --> rand-data
#   power-plant   --> power-plant and power-plant-pv
#   water-plant   --> wp-digital  (boolean values) and wp-analog (sensor values)
#   waste-water   --> wwp-digital (boolean values) and wwp-analog (sensor values)
#   wind-turbine  --> wind-turbine/#
#   rig-data      --> rig-data/#
#   vessel-data   --> vessel-data/#
#
# Note: Each sub-topic is subscribed to explicitly, since AnyLog does not support `if X in Y` conditionals.
#       For example, wind-turbine subscribes to wind-turbine/turbine-1, wind-turbine/turbine-2, ... individually,
#       and rig-data subscribes to rig-data/rig-1, rig-data/rig-7, rig-data/rig-12, rig-data/rig-23,
#       rig-data/rig-31, and rig-data/rig-44. Similarly, vessel-data covers vessel-data/DLT and vessel-data/DLB.
#       The router script selects the correct handler, which in turn registers all relevant sub-topics.
#
# Usage:
#   set msg_topic = [topic]
#   process !local_scripts/data-generator/data_generator.al
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/data-generator/data_generator.al

on error ignore

if      !msg_topic == rand-data    then process !local_scripts/data-generator/rand_data.al
else if !msg_topic == power-plant  then process !local_scripts/smart-city/power_plant.al
else if !msg_topic == waste-water  then process !local_scripts/smart-city/waste_water_plant.al
else if !msg_topic == water-pant   then process !local_scripts/smart-city/water_plant.al
else if !msg_topic == wind-turbine then process !local_scripts/data-generator/wind_turbine_data.al
else if !msg_topic == rig-data     then process !local_scripts/data-generator/oil_rig_data.al
else if !msg_topic == wind-turbine then process !local_scripts/data-generator/wind_turbine_data.al
else if !msg_topic == vessel-data  then process !local_scripts/data-generator/vessel_aggregation_demo.al
else if !msg_topic == vessel-data  then process !local_scripts/data-generator/vessel_data.al
else echo "Support for topic: " + !msg_topic + " not found"


:end-script:
end script

