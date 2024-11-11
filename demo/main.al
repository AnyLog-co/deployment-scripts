:debug-mode:
on error ignore
set authentication off

if $DEBUG_MODE.int > 0 and $DEBUG_MODE < 3 then print "Set Script defined configs"
set debug_mode = 0
if $DEBUG_MODE then set debug_mode=$DEBUG_MODE
if !debug_mode.int == 1 then set debug on
else if !debug_mode.int == 2 then set debug interactive
else if !debug_mode.int > 2 then debug_mode=0

set anylog_path = /app
local_scripts = !anylog_path/deployment-scripts/demo
test_dir = !anylog_path/deployment-scripts/test

if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
else if $EDGELAKE_PATH then set anylog_path = $EDGELAKE_PATH
set anylog home !anylog_path

if $LOCAL_SCRIPTS then set local_scripts = $LOCAL_SCRIPTS
if $TEST_DIR then set test_dir = $TEST_DIR

create work directories

:set-params:
if !debug_mode.int > 0 then print "Set params"
do process !local_scripts/set_params.al
if !debug_mode.int == 2 then thread !local_scripts/set_params.al
else do process !local_scripts/set_params.al

set debug on

:networking:
#if !debug_mode.int == 2 then thread !local_scripts/connect_networking.al
#else do
process !local_scripts/connect_networking.al

:blockchain-seed:
if !debug_mode.int > 0 then print "run blockchain seed"
on error call blockchain-seed-error
blockchain seed from !ledger_conn

:declare-cluster:
if !debug_mode.int == 2 then thread !local_scripts/cluster_policy.al
else do process !local_scripts/cluster_policy.al

cluster_id = blockchain get cluster bring.first [*][id]

:declare-operator:
if !debug_mode.int == 2 then thread !local_scripts/node_policy.al
else do process !local_scripts/node_policy.al
operator_id = blockchain get operator bring.first [*][id]

:connect-database:
if !debug_mode.int > 0 then print "Connecting to databases"
on error goto operator-db-error
connect dbms !default_dbms where type=sqlite

on error goto almgm-dbms-error
connect dbms almgm where type=!db_type
on error goto almgm-table-error
create table tsd_info where dbms=almgm

:schedule-processes:
on error ignore
if !debug_mode.int > 0 then print "Set schedule processes"
run scheduler 1

on error call blockchain-sync-error
<run blockchain sync where
    source=!blockchain_source and
    time=!blockchain_sync and
    dest=!blockchain_destination and
    connection=!ledger_conn>

:operator-processes:
if !debug_mode.int == 2 then thread !local_scripts/config_threshold.al
else do process !local_scripts/config_threshold.al

on error call run-streamer-error
run streamer

on error goto operator-error
if not !operator_id then goto operator-id-error
<if !operator_id then run operator where
    create_table=!create_table and update_tsd_info=!update_tsd_info and compress_json=!compress_file and
    compress_sql=!compress_sql and archive_json=!archive and archive_sql=!archive_sql and
    master_node=!ledger_conn and policy=!operator_id and threads=!operator_threads>


:enable-mqtt:
if !debug_mode.int > 0 then print "run MQTT client"
on error call mqtt-error
<run msg client where broker=!mqtt_broker and port=!mqtt_port and user=!mqtt_user and password=!mqtt_passwd
and log=!msg_log and topic=(
    name=!msg_topic and
    dbms=!msg_dbms and
    table=!msg_table and
    column.timestamp.timestamp=!msg_timestamp_column and
    column.value=(type=!msg_value_column_type and value=!msg_value_column)
)>

:end-script:
if !debug_mode.int > 0 then print "Validate everything is running as expected"
get processes
if !enable_mqtt == true then get msg client
end script

:terminate-scripts:
exit scripts

:blockchain-seed-error:
print "Failed to run blockchain seed"
goto terminate-scripts

:operator-db-error:
print "Error: Unable to connect to almgm database with db type: " !db_type ". Cannot continue"
goto terminate-scripts

:almgm-dbms-error:
print "Error: Unable to connect to almgm database with db type: " !db_type ". Cannot continue"
goto terminate-scripts

:almgm-table-error:
print "Error: Failed to create table almgm.tsd_info. Cannot continue"
goto terminate-scripts

:blockchain-sync-error:
print "failed to to declare blockchain sync process"
goto terminate-scripts

:run-streamer-error:
print "Failed to set streamer for operator"
return

:operator-id-error:
print "Missing Operator ID, cannot start operator node"
goto terminate-scripts

:operator-error:
print "Failed to execute run operator"
goto terminate-scripts

:mqtt-error
print "Failed to run mqtt client"
return





