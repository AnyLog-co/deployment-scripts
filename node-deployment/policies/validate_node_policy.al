#-----------------------------------------------------------------------------------------------------------------------
# Validate if policy exists
# - dns not bind      -> ip = !external_dns
# - dns bound         -> local_ip = !dns
# - overlay, neither TCP nor policy bound -> local_ip = !overlay_ip
# - overlay, TCP or policy bound          -> ip = !overlay_ip
# - neither TCP nor policy bound          -> local_ip = !ip
# - TCP or policy bound                   -> ip = !ip
#
# If no policy matches this node's connection, but a policy of the same type + name already exists
# (i.e. same name, different connection), the script rejects the node and stops.
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

:check-policy:
on error ignore

if not !is_policy and not !node_name then process !local_scripts/node-deployment/policies/node_name.al
# do goto set-node-name

:check-name-conflict:
# No policy matched this node's connection - make sure the name isn't already taken by another node of the same type
set name_policy = ""
if not !is_policy and !node_name then name_policy = blockchain get !node_type where name = !node_name bring.first
if !name_policy then goto name-conflict-error

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

:name-conflict-error:
conflict_company = from !name_policy bring [*][company]
conflict_ip = from !name_policy bring [*][ip]
conflict_local_ip = from !name_policy bring [*][local_ip]
conflict_port = from !name_policy bring [*][port]
echo "Error: a " !node_type " policy named " !node_name " already exists with a different connection (company: " !conflict_company ", ip: " !conflict_ip ", local_ip: " !conflict_local_ip ", port: " !conflict_port "). Set a unique NODE_NAME or remove the existing policy - cannot continue."
goto terminate-scripts
