#----------------------------------------------------------------------------------------------------------------------#
# Create policy for operator
#   --> check if policy exists
#   --> prepare policy
#   --> declare policy
#   --> recheck
# :sample-policy:
#   {"operator": {
#       "name": "anylog-operator",
#       "company": "AnyLog Co.",
#       "ip": "136.23.47.189",
#       "internal_ip": "136.23.47.189",
#       "port": 32248,
#       "rest_port": 32249,
#       "cluster": "",
#       "loc": "37.425423, -122.078360",
#       "country": "US",
#       "state": "CA",
#       "city": "Mountain View",
#       "script": [ // validate only if data partitioning is initially enabled
#           "partition !default_dbms !table_name using !partition_column by !partition_interval",
#           "schedule time=!partition_sync and name="Drop Partitions" task drop partition where dbms=!default_dbms and table =!table_name and keep=!partition_keep"
#       ]
#   }}
#----------------------------------------------------------------------------------------------------------------------#

:check-policy:
is_policy = blockchain get operator where company=!company_name and name=!node_name
if not !is_policy then goto create-policy
if !is_policy and not !create_policy  then
do ip_address = from !is_policy bring [*][ip]
do if !ip_address != !external_ip and !ip_address != !ip and !ip_address != !overlay_ip then goto ip-error

operator_id = from !is_policy bring [*][id]
if !operator_id then goto config-policy
if not !operator_id and !create_policy == true then goto declare-policy-error

:create-policy:
set new_policy = ""
set policy new_policy [operator] = {}
set policy new_policy [operator][name] = !node_name
set policy new_policy [operator][company] = !company_name

:network-operators:
if !overlay_ip and !tcp_bind == true then set policy new_policy [operator][ip] = !overlay_ip
if not !overlay_ip and !tcp_bind == true then set policy new_policy [operator][ip] = !ip
if !overlay_ip and !tcp_bind == false then
do set policy new_policy [operator][ip] = !external_ip
do set policy new_policy [operator][internal_ip] = !overlay_ip
if not !overlay_ip and !tcp_bind == false then
do set policy new_policy [operator][ip] = !external_ip
do set policy new_policy [operator][internal_ip] = !ip

set policy new_policy [operator][port] = !anylog_server_port.int
set policy new_policy [operator][rest_port] = !anylog_rest_port.int
if !anylog_broker_port then set policy new_policy [operator][rest_port] = !anylog_broker_port.int

if !cluster_id then set policy new_policy [operator][cluster] = !cluster_id

:location:
if !loc then set policy new_policy [operator][loc] = !loc
if !country then set policy new_policy [operator][country] = !country
if !state then set policy new_policy [operator][state] = !state
if !city then set policy new_policy [operator][city] = !city

:partitions:
# for operator node, extend to have partitioning is initially enabled
if !enable_partitions == true then
<do set policy new_policy [operator][script] = [
    "partition !default_dbms !table_name using !partition_column by !partition_interval",
    "schedule time=!partition_sync and name="Drop Partitions" task drop partition where dbms=!default_dbms and table =!table_name and keep=!partition_keep"
]>

:publish-policy:
process !local_scripts/policies/publish_policy.al
if error_code == 1 then goto sign-policy-error
if error_code == 2 then goto prepare-policy-error
if error_code == 3 then declare-policy-error
set create_policy = true
goto check-policy

:config-policy:
on error goto config-policy-error
config from policy where id=!operator_id

:end-script:
end script

:terminate-scripts:
exit scripts

:ip-error:
print "An Operator node policy with the same company and node name already exists under a different IP address: " !ip_address
goto terminate scripts

:sign-policy-error:
print "Failed to sign operator policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member operator policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare operator policy on blockchain"
goto terminate-scripts