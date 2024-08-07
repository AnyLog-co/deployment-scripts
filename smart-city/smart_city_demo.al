#-----------------------------------------------------------------------------------------------------------------------
# Main from smart city demo
# :steps:
#   1. create policies
#   2. declare MQTT client
#-----------------------------------------------------------------------------------------------------------------------
# process $ANYLOG_PATH/deployment-scripts/smart-city/smart_city_demo.al

on error ignore

set is_demo = true

default_dbms = power_plant
process !local_scripts/database/configure_dbms_operator.al
partition !default_dbms !table_name using timestamp by !partition_interval
schedule time=!partition_sync and name="Drop Partitions - PP" task drop partition where dbms=!default_dbms and table=!table_name and keep=!partition_keep
process $ANYLOG_PATH/deployment-scripts/smart-city/power_plant.al

default_dbms = water_plant
process !local_scripts/database/configure_dbms_operator.al
partition !default_dbms !table_name using timestamp by !partition_interval
schedule time=!partition_sync and name="Drop Partitions - WP" task drop partition where dbms=!default_dbms and table=!table_name and keep=!partition_keep
process $ANYLOG_PATH/deployment-scripts/smart-city/water_plant.al

if not !anylog_broker_port and !user_name and !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user=!user_name and password=!user_password and user-agent=anylog and log=false and
    topic=(name=wp-generic and policy=smart-city-wp) and
    topic=(name=pp-generic and policy=smart-city-pp) and
    topic=(name=pp-commsstatus and policy=smart-city-pp-commsstatus) and
    topic=(name=pp-other and policy=smart-city-pp-other)
>
else if !anylog_broker_port then
<do run msg client where broker=local and port=!anylog_broker_port and log=false and
    topic=(name=wp-generic and policy=smart-city-wp) and
    topic=(name=pp-generic and policy=smart-city-pp) and
    topic=(name=pp-commsstatus and policy=smart-city-pp-commsstatus) and
    topic=(name=pp-other and policy=smart-city-pp-other)
>
else if not !anylog_broker_port then
<do run msg client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and
    topic=(name=wp-generic and policy=smart-city-wp) and
    topic=(name=pp-generic and policy=smart-city-pp) and
    topic=(name=pp-commsstatus and policy=smart-city-pp-commsstatus) and
    topic=(name=pp-other and policy=smart-city-pp-others)
>