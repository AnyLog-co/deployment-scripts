#-----------------------------------------------------------------------------------------------------------------------
# Validate if policy exists
# - dns not bind      -> ip = !external_dns
# - dns bound         -> local_ip = !dns
# - overlay not bound -> local_ip = !overlay_ip
# - overlay bound     -> ip = !overlay_ip
# - not bound         -> ip = !external_ip
# - bound             -> ip = !ip
#
# for operator validate ID if policy exists
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/policies/validate_node_policy.al

on error ignore


if !enable_dns == false and not !overlay_ip then goto generic-check
if !enable_dns == false and !overlay_ip then goto overlay-check

:dns-check:
if !external_dns then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !external_dns and
    port = !anylog_server_port bring.first>
do goto check-operator
else if !tcp_bind == true and !dns then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !dns and
    port = !anylog_server_port bring.first>
do goto check-operator
else goto mismatch-error

:overlay-check:
if !tcp_bind == false and !overlay_ip then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    local_ip = !overlay_ip and
    port = !anylog_server_port bring.first>
do goto check-operator
else if !tcp_bind == true and !overlay_ip then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !overlay_ip and
    port = !anylog_server_port bring.first>
do goto check-operator
else goto mismatch-error

:generic-check:
if !tcp_bind == false then
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    local_ip = !ip and
    port = !anylog_server_port bring.first>
do goto check-operator
else if !tcp_bind == true
<do is_policy = blockchain get !node_type where
    company=!company_name and
    name=!node_name and
    ip = !ip and
    port = !anylog_server_port bring.first>
do goto check-operator
else goto network-config-error

:check-operator:
if !node_type == operator and !is_policy then operator_id = from !is_policy bring [*][id]

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
