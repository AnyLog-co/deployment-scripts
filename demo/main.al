:debug-mode:
on error ignore
if $DEBUG_MODE.int > 0 and $DEBUG_MODE < 3 then print "Set Script defined configs"
set debug_mode = 0
if $DEBUG_MODE then set debug_mode=$DEBUG_MODE
if !debug_mode.int == 1 then set debug on
else if !debug_mode.int == 2 then set debug interactive
else if !debug_mode.int > 2 then debug_mode=0


set anylog_path = $ANYLOG_PATH

set local_scripts = $LOCAL_SCRIPTS
set test_dir = $TEST_DIR

#if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
#else if $EDGELAKE_PATH then set anylog_path = $EDGELAKE_PATH
#if $LOCAL_SCRIPTS then set local_scripts = $LOCAL_SCRIPTS
#if $TEST_DIR then set test_dir = $TEST_DIR

:set-params:
if !debug_mode.int > 0 then print "Set params"
if !debug_mode.int == 2 then thread !local_scripts/demo/set_params.al
else process !local_scripts/demo/set_params.al

:networking:
if !debug_mode.int == 2 then thread !local_scripts/demo/connect_networking.al
else thread !local_scripts/demo/connect_networking.al


:blockchain-seed:
if !debug_mode.int > 0 then print "run blockchain seed"
on error call blockchain-seed-error
if !node_type != master then blockchain seed from !ledger_conn

:declare-cluster:
if !debug_mode.int == 2 then thread !local_scripts/demo/cluster_policy.al
else thread !local_scripts/demo/cluster_policy.al

:declare-operator:
if !node_type != master then if !debug_mode.int == 2 then thread !local_scripts/demo/node_policy.al
else thread !local_scripts/demo/node_policy.al

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
<if !node_type != master then run blockchain sync where
    source=!blockchain_source and
    time=!blockchain_sync and
    dest=!blockchain_destination and
    connection=!ledger_conn>

:operator-processes:
if node_type != master then if !debug_mode.int == 2 then thread !local_scripts/demo/config_threshold.al
else thread !local_scripts/demo/config_threshold.al

on error call run-streamer-error
run streamer

on error goto operator-error
if not !operator_id and !node_type != master then goto operator-id-error
<if !operator_id then run operator where
    create_table=!create_table and update_tsd_info=!update_tsd_info and compress_json=!compress_file and
    compress_sql=!compress_sql and archive_json=!archive and archive_sql=!archive_sql and
    master_node=!ledger_conn and policy=!operator_id and threads=!operator_threads>

:enable-mqtt:
on error ignore
if !enable_mqtt == true and !debug_mode == 2 then thread !anylog_path/deployment-scripts/demo-scripts/basic_msg_client.al
else thread !anylog_path/deployment-scripts/demo-scripts/basic_msg_client.al

:end-script:
if !debug_mode.int > 0 then print "Validate everything is running as expected"
get processes
if !enable_mqtt == true then get msg client
end script

:terminate-scripts:
exit scripts

:blockchain-seed-error:
print "Failed to run blockchain seed"
return

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





