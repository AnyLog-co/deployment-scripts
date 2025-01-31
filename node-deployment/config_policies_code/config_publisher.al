#-----------------------------------------------------------------------------------------------------------------------
# Replication of scripts in config for Publisher node - used when node set in debug mode
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/config_policies_code/config_operator.al

on error ignore
if !debug_mode == true then set debug on

:declare-database:
if !debug_mode == true then print "Connect to database(s)"
process !local_scripts/database/deploy_database.al

:declare-node:
if !dbug_mode.int > 0 then print "Declare Node policy"
process !local_scripts/policies/node_policy.al

:general-configs;
if !debug_mode == true then print "Set scheduler 1"
on error goto scheduler-error
run scheduler 1

on error ignore
process !local_scripts/policies/config_threshold.al

if !debug_mode == true then print "Enable streamer"
on error goto enable-streamer-error
run streamer

:run-publisher:
on error goto run-publisher-error
if !debug_mode == true then print "start publisher service"

<if !blockchain_source != master then run publisher where
    compress_json=!compress_file and
    compress_sql=!compress_file and
    blockchain=!blockchain_source and
    dbms_name=!dbms_file_location and
    table_name=!table_file_location>
<else run publisher where
    compress_json=!compress_file and
    compress_sql=!compress_file and
    master=!ledger_conn and
    dbms_name=!dbms_file_location and
    table_name=!table_file_location>

:clean-archive:
on error call clean-archive-error
if !debug_mode == true then print "Set schedule to clean archive"
schedule name=remove_archive and time=1 day and task delete archive where days = !archive_delete

:monitoring-and-local-scripts:
on error ignore
if !debug_mode == true then print "Declare Monitoring & other local scripts"
if !monitor_nodes == true then process !anylog_path/deployment-scripts/demo-scripts/monitoring_policy.al,
if !enable_mqtt == true then process !anylog_path/deployment-scripts/demo-scripts/basic_msg_client.al
if !syslog_monitoring == true then process !anylog_path/deployment-scripts/demo-scripts/syslog.al
if !deploy_local_script == true then process !local_scripts/local_script.al

:end-script:
end script

:terminate-scripts:
exit scripts

:scheduler-error:
print "Failed to set scheduler 1"
goto end-script

:enable-streamer-error:
print "Failed to enable streamer service"
goto end-script

:clean-archive-error:
print "Failed to set schedule process for cleaning archives"
return

:run-publisher-error:
print "Failed to start publisher service"
goto terminate-scripts
