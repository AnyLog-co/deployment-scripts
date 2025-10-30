#----------------------------------------------------------------------------------------------------------------------#
# Configure syslog monitoring
# To run with remote syslog(s):
#   1. On the destination (operator) node create a new file
#   2. set variables `syslog_name` and `syslog_ip`
#   3. execute - `config from policy where id=syslog-monitoring`
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/southbound-monitoring/policy_syslog_monitoring.al

on error ignore

:preset-params:
if !overlay_ip then set syslog_ip = !overlay_ip
else set syslog_ip = !ip
set syslog_name = !node_name

:set-config-params:
config_id = syslog-monitoring
set create_policy = false

:check-policy:
is_policy = blockchain get schedule where id=!config_id

# just created the policy + exists
if !is_policy then goto config-policy

# failure show created policy
if not !is_policy and !create_policy == true then goto declare-policy-error

:create-policy
<new_policy = {
    "config": {
        "id": !config_id,
        "name": "Syslog Monitoring",
        "script": [
            "if !node_type == operator then process !anylog_path/deployment-scripts/southbound-monitoring/create_syslog_monitoring_table.al",
            "if !node_type == operator then process !anylog_path/deployment-scripts/southbound-monitoring/configure_message_broker.al",
            "set msg rule !syslog_name if ip = !syslog_ip then dbms = monitoring and table = syslog and extend = ip and syslog = true"
        ]
    }
}>


:publish-policy:
on error ignore
process !local_scripts/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-policy

else if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error

:config-policy:
if !debug_mode == true then print "Config from policy"
on error goto config-policy-error
config from policy where id=!config_id

:end-script:
end script

:terminate-scripts:
exit scripts

:store-monitoring-error:
print "Failed to store "
:config-policy-error:
print "Failed to configure node based on Schedule ID"
goto terminate-scripts

:sign-policy-error:
print "Failed to sign schedule policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member schedule policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare schedule policy on blockchain"
goto terminate-scripts

