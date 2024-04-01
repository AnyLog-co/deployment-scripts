#----------------------------------------------------------------------------------------------------------------------#
# Create configuration policy based on variables
# :sample-master-policy:
# [{'config' : {'name' : 'master-anylog_co.-configs',
#              'company' : 'AnyLog Co.',
#              'ip' : '!external_ip',
#              'local_ip' : '!ip',
#              'port' : '!anylog_server_port.int',
#              'rest_port' : '!anylog_rest_port.int',
#              'threads' : '!tcp_threads.int',
#              'rest_threads' : '!rest_threads.int',
#              'rest_timeout' : '!rest_timeout.int',
#              'script' : [
#                   'process !local_scripts/policies/master_policy.al',
#                   'process !local_scripts/database/deploy_database.al',
#                   'run scheduler 1',
#                   'run blockchain sync where source=!blockchain_source and time=!blockchain_sync and dest=!blockchain_destination and connection=!ledger_conn',
#                   'process !local_scripts/policies/monitoring_policy.al',
#                   'if !deploy_local_script == true then process !local_scripts/loca'l_script.al'
#               ],
#              'id' : 'fd547a557d63e18d10335d8df59c2cfb',
#              'date' : '2024-02-05T01:14:22.204991Z',
#              'ledger' : 'global'}}]
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/policies/config_policy.al

on error ignore
:check-policy:
config_id = blockchain get config where company=!company_name and name=!config_name and node_type=!node_type bring [*][id]
if !config_id then goto config-policy
if not !config_id and !create_config == true then goto declare-policy-error

:preapare-new-policy:
new_policy = ""
set policy new_policy [config] = {}
set policy new_policy [config][name] = !config_name
set policy new_policy [config][company] = !company_name
set policy new_policy [config][node_type] = !node_type

:network-configs:
set policy new_policy [config][ip] = '!external_ip'
set policy new_policy [config][local_ip] = '!ip'
if !overlay_ip then set policy new_policy [config][local_ip] = '!overlay_ip'

set policy new_policy [config][port] = '!anylog_server_port.int'
set policy new_policy [config][rest_port] = '!anylog_rest_port.int'
if !anylog_broker_port then set policy new_policy [config][broker_port] = '!anylog_broker_port.int'

set policy new_policy [config][threads] = '!tcp_threads.int'
set policy new_policy [config][tcp_bind] = '!tcp_bind'

set policy new_policy [config][rest_threads] = '!rest_threads.int'
set policy new_policy [config][rest_timeout] = '!rest_timeout.int'
set policy new_policy [config][rest_bind] = '!rest_bind'

if !anylog_broker_port then
do set policy new_policy [config][broker_threads] = '!broker_threads.int'
do set policy new_policy [config][broker_bind] = '!broker_bind'


:scripts:
<if !node_type == generic then set policy new_policy [config][script] = [
    "run scheduler 1",
    "if !deploy_local_script == true then process !local_scripts/local_script.al"
]>

<if !node_type == master then set policy new_policy [config][script] = [
    "process !local_scripts/database/deploy_database.al",
    "process !local_scripts/policies/master_policy.al",
    "run scheduler 1",
    "if !deploy_local_script == true then process !local_scripts/local_script.al"
]>

<if !node_type == query then set policy new_policy [config][script] = [
    "process !local_scripts/database/deploy_database.al",
    "process !local_scripts/policies/query_policy.al",
    "run scheduler 1",
    "if !deploy_local_script == true then process !local_scripts/local_script.al"
]>

<if !node_type == publisher then set policy new_policy [config][script] = [
    "process !local_scripts/policies/publisher_policy.al",
    "process !local_scripts/database/deploy_database.al",
    "run scheduler 1",
    "run blockchain sync where source=!blockchain_source and time=!blockchain_sync and dest=!blockchain_destination and connection=!ledger_conn",
    "set buffer threshold where time=!threshold_time and volume=!threshold_volume and write_immediate=false",
    "run streamer",
    "run publisher where compress_json=!compress_file and compress_sql=!compress_file and master_node=!ledger_conn and dbms_name=!dbms_file_location and table_name=!table_file_location",
    "if !monitor_nodes == true then process $ANYLOG_PATH/deployment-scripts/demo-scripts/monitoring_policy.al",
    "if !enable_mqtt == true then process $ANYLOG_PATH/deployment-scripts/demo-scripts/basic_msg_client.al",
    "if !deploy_local_script == true then process !local_scripts/local_script.al"
]>

<if !node_type == operator then set policy new_policy [config][script] = [
    "process !local_scripts/database/deploy_database.al",
    "process !local_scripts/policies/cluster_policy.al",
    "process !local_scripts/policies/operator_policy.al",
    "run scheduler 1",
    "run streamer",
    "if !enable_ha == true then run data distributor",
    "if !enable_ha == true then run data consumer where start_date=!start_data",
    "if !operator_id then run operator where create_table=!create_table and update_tsd_info=!update_tsd_info and compress_json=!compress_file and compress_sql=!compress_file and archive_json=!archive and archive_sql=!archive and master_node=!ledger_conn and policy=!operator_id and threads=!operator_threads",
    "schedule name=remove_archive and time=1 day and task delete archive where days = !archive_delete",
    "if !monitor_nodes == true then process $ANYLOG_PATH/deployment-scripts/demo-scripts/monitoring_policy.al",
    "if !enable_mqtt == true then process $ANYLOG_PATH/deployment-scripts/demo-scripts/basic_msg_client.al",
    "if !deploy_local_script == true then process !local_scripts/local_script.al"
]>

:publish-policy:
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_config = true
goto check-policy

:config-policy:
on error goto config-policy-error
config from policy where id = !config_id

:end-script:
end script

:sign-policy-error:
print "Failed to sign config policy"
goto end-script

:prepare-policy-error:
print "Failed to prepare member config policy for publishing on blockchain"
goto end-script

:declare-policy-error:
print "Failed to declare config policy on blockchain"
goto end-script

:config-policy-error: 
print "Failed to execute config policy"
goto end-script
