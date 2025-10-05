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
# process !local_scripts/policies/node_policy.al

if !debug_mode == true then set debug on

on error ignore
set create_policy = false
if !is_relay == true then set node_type = relay

:check-policy:
if !debug_mode == true then print "Check whether policy already exists based on params"

# checks nodes based on name, company and networking configurations
process !local_scripts/policies/validate_node_policy.al

# checks nodes without networking configurations - this will also update the node name on the interface
node_count = blockchain get !node_type where name=!node_name bring.count

if not !is_policy and !node_count then
do node_count =  python !node_count.int  + 1
do node_name = !node_name + !node_count
do set node name !node_name

if not !is_policy and !create_policy == false then goto create-policy
if not !is_policy and !create_policy == true then goto config-policy-error
else goto node-info

:create-policy:
if !debug_mode == true then print "Declare new policy variables"

set new_policy = ""
set policy new_policy [!node_type] = {}
set policy new_policy [!node_type][name] = !node_name
set policy new_policy [!node_type][company] = !company_name

if !node_type == operator and !branch then set policy new_policy [!node_type][branch]
if !node_type == operator and !dept then set policy new_policy [!node_type][dept]

:network-!node_type:
if !debug_mode == true then print "Declare network configuration in new policy variables"

set policy new_policy [!node_type][hostname] = !hostname
if $HZN_DEVICE_ID then set policy new_policy [!node_type][hzn_device_id] = $HZN_DEVICE_ID
set policy new_policy [!node_type][ip] = !external_ip
if !tcp_bind == true and !overlay_ip then set policy new_policy [!node_type][ip] = !overlay_ip
if !tcp_bind == true and not !overlay_ip then set policy new_policy [!node_type][ip] = !ip
if !tcp_bind == false and !overlay_ip then set policy new_policy [!node_type][local_ip] = !overlay_ip
if !tcp_bind == false and not !overlay_ip then set policy new_policy [!node_type][local_ip] = !ip

set policy new_policy [!node_type][port] = !anylog_server_port.int
set policy new_policy [!node_type][rest_port] = !anylog_rest_port.int
if !anylog_broker_port then set policy new_policy [!node_type][broker_port] = !anylog_broker_port.int

:cluster-info:
if !node_type != operator then goto set-location
if !debug_mode == true then print "For an operator node add cluster ID new policy variables"
if !node_type == operator and not !cluster_id then goto operator-cluster-error

set policy new_policy [!node_type][cluster] = !cluster_id
if !member then set policy new_policy [!node_type][member] = !member.int

set is_main = true
is_primary = blockchain get operator where cluster = !cluster_id
if !is_primary  then set is_main = false
set policy new_policy [!node_type][main] = !is_main.bool


:set-location:
if !debug_mode == true then print "Declare location of node"

if !loc then set policy new_policy [!node_type][loc] = !loc
if !country then set policy new_policy [!node_type][country] = !country
if !state then set policy new_policy [!node_type][state] = !state
if !city then set policy new_policy [!node_type][city] = !city

:publish-policy:
if !debug_mode == true then print "Publish policy"

process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy

:node-info:
on error ignore
if !debug_mode == true then print "For operator node  get policy ID for `run operator`"

if !node_type != operator then goto end-script
operator_id = from !is_policy bring.last [*][id]
if not !operator_id then goto config-policy-error

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
