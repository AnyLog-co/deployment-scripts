#----------------------------------------------------------------------------------------------------------------------#
# Declare a policy specific for different types of node monitoring
#   -> generic: cpu, disk, file i/o, event count, etc.
#   -> store syslog into Operator database(s)
#   -> docker insights
#:params:
#   operator_monitoring_ip - IP and Port (TCP) for sending data from non-Operator node(s) into Operator node(s)
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/monitoring_policy.al


on error ignore

if !debug_mode == true then set debug on

:set-params:
if !debug_mode == true then print "Setting env params"
config_id = config-monitoring
set create_policy = false

on error ignore
if !debug_mode == true then set debug on

:check-policy:
if !debug_mode == true then print "check if policy exists"
is_policy = blockchain get config where id=!config_id

# just created the policy + exists
if !is_policy then goto config-policy

# failure show created policy
if not !is_policy and !create_policy == true then goto declare-policy-error

:schedule-policy:
if !debug_mode == true then print "create policy"
new_policy=""
<new_policy = {
    "config": {
        "id": !config_id,
        "name": "Node Monitoring Schedule",
        "script": [
            "process !anylog_path/deployment-scripts/southbound-monitoring/prepare_monitoring.al",
            "if !monitor_nodes == true then process !anylog_path/deployment-scripts/southbound-monitoring/node_monitoring.al",
            "if !syslog_monitoring == true and (!node_type == operator or !node_type == publisher) then process !anylog_path/deployment-scripts/southbound-monitoring/syslog_monitoring.al",
            "if !docker_monitoring == true and (!node_type == operator or !node_type == publisher) then process !anylog_path/deployment-scripts/southbound-monitoring/docker_monitoring.al"
        ]
    }
}>

:publish-policy:
on error ignore
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy

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

