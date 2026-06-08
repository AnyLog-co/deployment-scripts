#----------------------------------------------------------------------------------------------------------------------#
# The following is an active "main" to different topic(s) automatically based on user input.
# We do not currently support `if X in Y`, thus the topic being processed ends up being [topic]/#
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/data-generator/data_generator.al

on error ignore

if      !msg_topic == rand_data    then process !local_scripts/data-generator/rand_data.al
else if !msg_topic == power_plant  then process !local_scripts/data-generator/power_plant.al
else if !msg_topic == wind-turbine then process !local_scripts/data-generator/wind_turbine_data.al
else if !msg_topic == rig-data     then process !local_scripts/data-generator/oil_rig_data.al
else if !msg_topic == wind-turbine then process !local_scripts/data-generator/wind_turbine_data.al
else if !msg_topic == vessel-data then
do process !local_scripts/data-generator/vessel_aggregation_demo.al
do process !local_scripts/data-generator/vessel_data.al
else echo "Support for topic: " + !msg_topic + " not found"


:end-script:
end script

