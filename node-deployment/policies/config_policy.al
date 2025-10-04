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
#                   'run blockchain sync where source=!blockchain_source and time=!blockchain_sync and dest=!blockchain_source != master and connection=!ledger_conn',
#                   'process !local_scripts/policies/monitoring_policy.al',
#                   'if !deploy_local_script == true then process !local_scripts/loca'l_script.al'
#               ],
#              'id' : 'fd547a557d63e18d10335d8df59c2cfb',
#              'date' : '2024-02-05T01:14:22.204991Z',
#              'ledger' : 'global'}}]
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/policies/config_policy.al

reset error log
reset echo queue
reset event log

on error ignore
set create_config = false
if !debug_mode == true then set debug on

:check-policy:
if !debug_mode == true then print "Check whether config policy exists - if exists then goes to declare policy"

config_id = blockchain get config where company=!company_name and name=!config_name and node_type=!node_type bring.first [*][id]
if !config_id then goto config-policy
if not !config_id and !create_config == true then goto declare-policy-error

if !configure_dns == true then
do process !local_scripts/policies/config_policy_network_dns.al
do goto scripts

:prepare-new-policy:
if !debug_mode == true then print "Create base for new config policy"

new_policy = ""
set policy new_policy [config] = {}
set policy new_policy [config][name] = !config_name
set policy new_policy [config][company] = !company_name
set policy new_policy [config][node_type] = !node_type

:network-configs:
if !debug_mode.int == 2 then
do set debug interactive
do print "Add networking configurations for policy"
do set debug on

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
if !rest_bind == true and  not !overlay_ip then set policy new_policy [config][rest_ip] = '!ip'
if !rest_bind == true and !overlay_ip      then set policy new_policy [config][rest_ip] = '!overlay_ip'

if !anylog_broker_port then
do set policy new_policy [config][broker_threads] = '!broker_threads.int'
do set policy new_policy [config][broker_bind] = '!broker_bind'

if !broker_bind == true and  not !overlay_ip then set new_policy [config][broker_ip] == '!ip'
if !broker_bind == true and !overlay_ip      then set policy new_policy [config][broker_ip] = '!overlay_ip'

:scripts:
if !debug_mode == true then print "Add script for deploying policy - each node type has a unique policy"

if !node_type == publisher then goto publisher-scripts
if !node_type == operator then goto operator-scripts

:generic-node:
if !node_type == generic then
<do set policy new_policy [config][script] = [
    "if !system_query == true then process !local_scripts/database/configure_dbms_system_query.al",
    "run scheduler 1",
    "if !deploy_local_script == true then process !local_scripts/local_script.al",
    "if !is_edgelake == false then process !local_scripts/policies/license_policy.al"
]>
do goto publish-policy

:master-query:
if !node_type == master or !node_type == query then
<do set policy new_policy [config][script] = [
    "process !local_scripts/database/deploy_database.al",
    "if !blockchain_source == master then blockchain seed from !ledger_conn",
    "process !local_scripts/connect_blockchain.al",
    "process !local_scripts/policies/node_policy.al",
    "run scheduler 1",
    "process !anylog_path/deployment-scripts/southbound-monitoring/config_monitoring_policy.al",
    "if !deploy_local_script == true then process !local_scripts/local_script.al",
    "if !is_edgelake == false then process !local_scripts/policies/license_policy.al"
]>
do goto publish-policy

:publisher-scripts:

<set policy new_policy [config][script] = [
    "process !local_scripts/connect_blockchain.al",
    "process !local_scripts/policies/node_policy.al",
    "process !local_scripts/database/deploy_database.al",
    "run scheduler 1",
    "set buffer threshold where time=!threshold_time and volume=!threshold_volume and write_immediate=false",
    "run streamer",
    "run publisher where archive_json=true and compress_json=!compress_file and compress_sql=!compress_file and dbms_name=!dbms_file_location and table_name=!table_file_location",
    "schedule name=remove_archive and time=1 day and task delete archive where days = !archive_delete",
    "process !anylog_path/deployment-scripts/southbound-monitoring/config_monitoring_policy.al",
    "if !enable_mqtt == true then process !anylog_path/deployment-scripts/sample-scripts/basic_msg_client.al",
    "if !deploy_local_script == true then process !local_scripts/local_script.al",
    "if !is_edgelake == false then process !local_scripts/policies/license_policy.al"
]>
goto publish-policy

:operator-scripts:
<set policy new_policy [config][script] = [
    "process !local_scripts/connect_blockchain.al",
    "process !local_scripts/policies/cluster_policy.al",
    "process !local_scripts/policies/node_policy.al",
    "process !local_scripts/database/deploy_database.al",
    "run scheduler 1",
    "set buffer threshold where time=!threshold_time and volume=!threshold_volume and write_immediate=!write_immediate",
    "run streamer",
    "if !enable_ha == true then run data distributor",
    "if !enable_ha == true then run data consumer where start_date=!start_data",
    "if !operator_id and !blockchain_source != master then run operator where create_table=!create_table and update_tsd_info=!update_tsd_info and compress_json=!compress_file and compress_sql=!compress_sql and archive_json=!archive and archive_sql=!archive_sql and blockchain=!blockchain_source and policy=!operator_id and threads=!operator_threads",
    "if !operator_id and !blockchain_source == master then run operator where create_table=!create_table and update_tsd_info=!update_tsd_info and compress_json=!compress_file and compress_sql=!compress_sql and archive_json=!archive and archive_sql=!archive_sql and master_node=!ledger_conn and policy=!operator_id and threads=!operator_threads",
    "if !enable_mqtt == true then process !anylog_path/deployment-scripts/sample-scripts/basic_msg_client.al",
    "process !anylog_path/deployment-scripts/southbound-monitoring/config_monitoring_policy.al",
    "if !deploy_local_script == true then process !local_scripts/local_script.al",
    "if !is_edgelake == false then process !local_scripts/policies/license_policy.al"
]>

:publish-policy:
if !debug_mode == true then print "Declare policy on blockchain"

set is_config = true
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_config = true
wait 5
blockchain reload metadata
set is_config = false
goto check-policy

:config-policy:
if !debug_mode == true then print "Deploy Policy"

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
