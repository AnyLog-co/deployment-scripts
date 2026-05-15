#----------------------------------------------------------------------------------------------------------------------#
# Policy specifically used to act as a monitoring node                                                                         #
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/southbound-monitoring/monitoring_node.al

on error ignore

set create_policy = false

:check-policy:
is_policy = blockchain get monitoring-node where name = !node_name and port = !anylog_server_port
if !is_policy then goto end-script
else if not !is_policy and !create_policy == true then goto declare-policy-error

:define-policy:
set new_policy = ""
set policy new_policy [monitoring-node] = {}
set policy new_policy [monitoring-node][name] = !node_name

:ip-config:
if $DNS_DOMAIN or $DNS then
do set policy new_policy [monitoring-node][host] = !dns
do goto port-config
else if !tcp_bind == true and !overlay_ip then
do set policy new_policy [monitoring-node][host] = !overlay_ip
do goto port-config
else if !tcp_bind == true then
do set policy new_policy [monitoring-node][host] = !ip
do goto port-config
else set policy new_policy [monitoring-node][host] = !external_ip

:port-config:
set policy new_policy [monitoring-node][port] = !anylog_server_port

:publish-policy:
on error ignore
process !local_scripts/node-deployment/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-policy

else if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error

:config-policy:
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