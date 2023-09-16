#----------------------------------------------------------------------------------------------------------------------#
# Main for generic scripts
#   -> set directory structure
#   -> set configs
#   -> declare policies
#   -> deploy based on node type
#----------------------------------------------------------------------------------------------------------------------#
# python3 /app/AnyLog-Network/anylog.py process $ANYLOG_PATH/deployment-scripts/scripts/training/main.al

on error ignore
set debug off
set authentication off
set echo queue on

:directories:
if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
set anylog home !anylog_path
if $LOCAL_SCRIPTS then set local_scripts = $LOCAL_SCRIPTS
if $TEST_DIR then set test_dir = $TEST_DIR

on error call work-dirs-error
create work directories

:set-params:
on error ignore
process !local_scripts/training/set_params.al
if !node_type != master then
do process !local_scripts/training/run_tcp_server.aldo process !local_scripts/training/run_tcp_server.al
do on error goto blockchain-seed-error
do blockchain seed from !ledger_conn
do on error ignore
do process !local_scripts/training/set_params_blockchain.al

:call-process:
process !local_scripts/training/generic_policies/generic_monitoring_policy.al
if !node_type == master then process !local_scripts/training/generic_policies/generic_master_policy.al
if !node_type == query then process !local_scripts/training/generic_policies/generic_query_policy.al
if !node_type == operator then process !local_scripts/training/generic_policies/generic_operator_policy.al

:execute-policy:
policy_id = blockchain get config where node_type = !node_type bring [*][id]
on error call config-from-policy-error
if !policy_id then config from policy where id = !policy_id

:execute-license:
on error call license-error
set license where activation_key=!license_key

:end-script:
end script

:missing-node-name:
print "Missing node name, cannot continue..."
goto end-script

:config-from-policy-error:
print "Failed to configure from policy for node type " !node_type
return

:license-key-error:
print "Failed to enable license key"
return

