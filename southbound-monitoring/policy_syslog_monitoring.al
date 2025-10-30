#----------------------------------------------------------------------------------------------------------------------#
# Configure syslog monitoring
# To run with remote syslog(s):
#   1. On the destination (operator) node create a new file
#   2. set variables `syslog_name` and `syslog_ip`
#   3. execute - `config from policy where id=syslog-monitoring`
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/southbound-monitoring/node_monitoring_policy.al

# enable_monitoring
# store_monitoring
# monitoring_storage_dest
# view_monitoring_dest

:set-params:
schedule_id = syslog-monitoring
set create_policy = false

if !overlay_ip then set syslog_ip = !overlay_ip
else set syslog_ip = !ip
set syslog_name = !node_name


:check-policy:
is_policy = blockchain get schedule where id=!schedule_id

# just created the policy + exists
if !is_policy then goto config-policy

# failure show created policy
if not !is_policy and !create_policy == true then goto declare-policy-error

:create-policy
<new_policy = {
    "schedule": {
        "id": !schedule_id,
        "name": "Syslog Monitoring Schedule",
        "scripts": [
            # create database + table policy
            "if !node_type == operator then process !anylog_path/deployment-scripts/node-deployment/configure_dbms_monitoring.al",
            "if !node_type == operator then process !anylog_path/deployment-scripts/southbound-monitoring/create_syslog_monitoring_table.al",
            # connect message broker (if not set)
            "process !anylog_path/deployment-scripts/southbound-monitoring/configure_message_broker.al",
            "set msg rule !syslog_name where ip = !syslog_ip and dbms = monitoring and table = syslog and extend = ip and syslog = true"
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
config from policy where id=!schedule_id

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

