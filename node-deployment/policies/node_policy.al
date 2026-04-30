#----------------------------------------------------------------------------------------------------------------------#
# Create policy for operator
#   --> check if policy exists
#   --> prepare policy
#   --> declare policy
#   --> recheck
# :sample-policy:
#   {"NODE_TYPE": {
#       "name": "anylog-operator",
#       "company": "AnyLog Co.",
#       "ip": "136.23.47.189",
#       "local_ip": "136.23.47.189",
#       "port": 32248,
#       "rest_port": 32249,
#       "cluster": "",
#       "loc": "37.425423, -122.078360",
#       "country": "US",
#       "state": "CA",
#       "city": "Mountain View",
#   }}
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/node-deployment/policies/node_policy.al

on error ignore
set create_policy = false
if !is_relay == true then set node_type = relay

:check-policy:

# checks nodes based on name, company and networking configurations
process !local_scripts/node-deployment/policies/validate_node_policy.al

if not !is_policy and !create_policy == false then goto create-policy
if not !is_policy and !create_policy == true then goto config-policy-error
else goto node-info

:create-policy:

set new_policy = ""
set policy new_policy [!node_type] = {}
set policy new_policy [!node_type][name] = !node_name
set policy new_policy [!node_type][company] = !company_name

set policy new_policy [!node_type][hostname] = !hostname
if $HZN_DEVICE_ID then set policy new_policy [!node_type][hzn_device_id] = $HZN_DEVICE_ID

:network-node_type:

set policy new_policy [!node_type][ip] = !external_ip
if !enable_dns == true and !external_dns   then set policy new_policy [!node_type][ip] = !external_dns
else if !tcp_bind == true and !overlay_ip  then set policy new_policy [!node_type][ip] = !overlay_ip
else if !tcp_bind == true                  then set policy new_policy [!node_type][ip] = !ip

if !enable_dns == true and ($DNS_DOMAIN or $DNS) then set policy new_policy [!node_type][local_ip] = !dns
else if !tcp_bind == false and !overlay_ip       then set policy new_policy [!node_type][local_ip] = !overlay_ip
else if !tcp_bind == false                        then set policy new_policy [!node_type][local_ip] = !ip

set policy new_policy [!node_type][port] = !anylog_server_port.int
set policy new_policy [!node_type][rest_port] = !anylog_rest_port.int
if !anylog_broker_port then set policy new_policy [!node_type][broker_port] = !anylog_broker_port.int

:cluster-info:
if !node_type != operator then goto set-location
if !node_type == operator and not !cluster_id then goto operator-cluster-error

set policy new_policy [!node_type][cluster] = !cluster_id
if !member then set policy new_policy [!node_type][member] = !member.int


if not !is_main then is_primary = blockchain get operator where cluster = !cluster_id
if not !is_main and !is_primary then set is_main = false
else if not !is_main and not !is_primary then set is_main = true
set policy new_policy [!node_type][main] = !is_main.bool


:set-location:

if !loc then set policy new_policy [!node_type][loc] = !loc
if !country then set policy new_policy [!node_type][country] = !country
if !state then set policy new_policy [!node_type][state] = !state
if !city then set policy new_policy [!node_type][city] = !city

if !node_type == operator and !branch then set policy new_policy [!node_type][branch]
if !node_type == operator and !dept then set policy new_policy [!node_type][dept]

:set-hzn-info:

if $HZN_DEVICE_ID then set policy new_policy [!node_type][hzn_node_id] = $HZN_DEVICE_ID
else if $HZN_NODE_ID then set policy new_policy [!node_type][hzn_node_id] = $HZN_NODE_ID
if $HZN_ORGANIZATION then set policy new_policy [!node_type][hzn_org] = $HZN_ORGANIZATION

:publish-policy:

process !local_scripts/node-deployment/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy

:node-info:
on error ignore

:declare-hzn:
if ($HZN_DEVICE_ID or $HZN_NODE_ID) and $HZN_ORGANIZATION then process !local_scripts/node-deployment/policies/hzn_policy.al


:end-script:
if !is_relay == true then set node_type = master
end script

:terminate-scripts:
if !is_relay == true then set node_type = master
exit scripts

:config-policy-error:
print "Failed to configure node based on !node_type ID"
goto terminate-scripts

:ip-error:
print "An !node_type node policy with the same company and node name already exists under a different IP address: " !ip_address
goto terminate-scripts

:operator-cluster-error:
print "Missing cluster policy ID for operator node, cannot continue..."
goto terminate-scripts

:sign-policy-error:
print "Failed to sign !node_type policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member !node_type policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare !node_type policy on blockchain"
goto terminate-scripts
