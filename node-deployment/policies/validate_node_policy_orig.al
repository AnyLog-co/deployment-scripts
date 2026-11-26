#-----------------------------------------------------------------------------------------------------------------------
# Validate if policy exists
# - dns not bind      -> ip = !external_dns
# - dns bound         -> local_ip = !dns
# - overlay, neither TCP nor policy bound -> local_ip = !overlay_ip
# - overlay, TCP or policy bound          -> ip = !overlay_ip
# - neither TCP nor policy bound          -> local_ip = !ip
# - TCP or policy bound                   -> ip = !ip
#
# for operator validate ID if policy exists
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/policies/validate_node_policy.al

on error ignore

:set-debug:
if !enable_debug == true then set debug on

:sync-blockchain:

if !master_configs != true then
do run blockchain sync
do blockchain reload metadata


:process-select:
set is_policy = ""
if !enable_dns == false and not !overlay_ip then goto generic-check
if !enable_dns == false and !overlay_ip then goto overlay-check

:dns-check:
if !external_dns then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    ip = !external_dns and
    port = !anylog_server_port bring.first>
do goto check-policy
else if !tcp_bind == true and !dns then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    ip = !dns and
    port = !anylog_server_port bring.first>
do goto check-policy
else goto mismatch-error

:overlay-check:
if !tcp_bind == false and !policy_tcp_bind == false and !overlay_ip then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    local_ip = !overlay_ip and
    port = !anylog_server_port bring.first>
do goto check-policy
else if (!tcp_bind == true or !policy_tcp_bind == true) and !overlay_ip then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    ip = !overlay_ip and
    port = !anylog_server_port bring.first>
do goto check-policy
else goto mismatch-error

:generic-check:
if !tcp_bind == false and !policy_tcp_bind == false then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    local_ip = !ip and
    port = !anylog_server_port bring.first>
do goto check-policy
else if (!tcp_bind == true or !policy_tcp_bind == true) then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    ip = !ip and
    port = !anylog_server_port bring.first>
do goto check-policy
else goto network-config-error

:check-name-conflict:
set name_policy = ""
if not !is_policy and !node_name then name_policy = blockchain get !node_type where name = !node_name bring.first
if !name_policy then goto name-conflict-error

:check-policy:
on error ignore

if not !is_policy then
do process !local_scripts/node-deployment/policies/node_name.al
# do goto set-node-name

if !is_policy and !node_type == operator then
do cluster_id = from !is_policy bring [*][cluster]
do operator_id = from !is_policy bring [*][id]

if !cluster_id then cluster_name = blockchain get cluster where id = !cluster_id bring.first [*][name]

if !is_policy then node_name = from !is_policy bring [*][name]
if !node_name and $NODE_NAME and !node_name != $NODE_NAME then
do echo "Warning: NODE_NAME (" $NODE_NAME ") ignored - this node already has a policy named " !node_name ". To rename it, remove the existing node policy first."

:set-node-name:
if !node_name then set node name !node_name

:end-script:
end script

:terminate-scripts:
exit scripts

:mismatch-error:
print "Inconsistency in network configurations - please validate configs"
goto terminate-scripts

:network-config-error:
print "No valid network configurations - cannot continue"
goto terminate-scripts
