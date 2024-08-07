#----------------------------------------------------------------------------------------------------------------------#
# Create policy for master, query or publisher
#   --> check if policy exists
#   --> prepare policy
#   --> declare policy
#   --> recheck
# :sample-policy:
#   {"master": {
#       "name": "anylog-master",
#       "company": "AnyLog Co.",
#       "ip": "136.23.47.189",
#       "local_ip": "136.23.47.189",
#       "port": 32048,
#       "rest_port": 32049,
#       "loc": "37.425423, -122.078360",
#       "country": "US",
#       "state": "CA",
#       "city": "Mountain View"
#   }}
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/policies/master_policy.al
on error ignore
set create_policy = false

:check-policy:
process !local_scripts/policies/validate_policy.al

# just created the policy + exists
if !is_policy then goto end-script

# policy pre-exists - validate IP addresses
if !is_policy and not !create_policy == false  then
do ip_address = from !is_policy bring [*][ip]
do if !ip_address != !external_ip and !ip_address != !ip and !ip_address != !overlay_ip then goto ip-error
do goto end-script

# failure show created policy
if not !is_policy and !create_policy == true then goto declare-policy-error

:create-policy:
set new_policy = ""
set policy new_policy [master] = {}
set policy new_policy [master][name] = !node_name
set policy new_policy [master][company] = !company_name

:network-master:
set policy new_policy [master][ip] = !external_ip
else if !tcp_bind == true  and !overlay_ip then set policy new_policy [master][ip] = !overlay_ip
else if !tcp_bind == false and !overlay_ip then set policy new_policy [master][local_ip] = !overlay_ip
else set policy new_policy [master][local_ip] = !ip

if !rest_bind == true and !overlay_ip then set policy new_policy [master][rest_ip] = !overlay_ip
if !rest_bind == true and not !overlay_ip then set policy new_policy [master][rest_ip] = !ip

if !broker_bind == true and !overlay_ip then set policy new_policy [master][broker_ip] = !overlay_ip
else if !broker_bind == true and not !overlay_ip then set policy new_policy [master][broker_ip] = !ip

set policy new_policy [master][port] = !anylog_server_port.int
set policy new_policy [master][rest_port] = !anylog_rest_port.int
if !anylog_broker_port then set policy new_policy [master][broker_port] = !anylog_broker_port.int

:license:
if !license_key then set policy new_policy [master][license] = !license_key

:location:
if !loc then set policy new_policy [master][loc] = !loc
if !country then set policy new_policy [master][country] = !country
if !state then set policy new_policy [master][state] = !state
if !city then set policy new_policy [master][city] = !city

:publish-policy:
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy

:end-script:
end script

:terminate-scripts:
exit scripts

:ip-error:
print "A Master node policy with the same company and node name already exists under a different IP address: " !ip_address
goto terminate-scripts

:sign-policy-error:
print "Failed to sign master policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member master policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare master policy on blockchain"
goto terminate-scripts
