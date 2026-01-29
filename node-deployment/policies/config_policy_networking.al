#----------------------------------------------------------------------------------------------------------------------#
# Create network params for policy
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/policies/config_policy_networking.al

on error ignore
if section == broker then goto broker-params

:tcp-params:
set policy new_policy [config][ip] = '!external_ip'
set policy new_policy [config][local_ip] = '!ip'

if !enable_dns == true and !enable_external_dns == true then set policy new_policy [config][ip] = '!external_dns'
if !overlay_ip              then set policy new_policy [config][local_ip] = '!overlay_ip'
else if !enable_dns == true and (!is_dns_local == false or !dns_domain)  then set policy new_policy [config][local_ip] = '!dns'

set policy new_policy [config][port]     = '!anylog_server_port.int'
set policy new_policy [config][tcp_threads]  = '!tcp_threads.int'
set policy new_policy [config][tcp_bind] = '!tcp_bind.bool'

:rest-params:
if !rest_bind == true and !overlay_ip                then set policy new_policy [config][rest_ip] = '!overlay_ip'
else if !rest_bind == true and ( !enable_dns == true and (!is_dns_local == false or !dns_domain) )    then set policy new_policy [config][rest_ip] = '!dns'
else if !rest_bind == true                           then set policy new_policy [config][rest_ip] = '!ip'

set policy new_policy [config][rest_port]     = '!anylog_rest_port.int'
set policy new_policy [config][rest_threads]  = !rest_threads.int
set policy new_policy [config][rest_timeout] = '!rest_timeout.int'
set policy new_policy [config][rest_bind]     = '!rest_bind.bool'

if not !anylog_broker_port then goto end-script

:broker-params:
if !broker_bind == true and !overlay_ip                then set policy new_policy [config][broker_ip] = '!overlay_ip'
else if !broker_bind == true and ( !enable_dns == true and (!is_dns_local == false or !dns_domain) )     then set policy new_policy [config][broker_ip] = '!dns'
else if !broker_bind == true                           then set policy new_policy [config][broker_ip] = '!ip'


set policy new_policy [config][broker_port]     = '!anylog_broker_port.int'
set policy new_policy [config][broker_threads]  = '!broker_threads.int'
set policy new_policy [config][broker_bind] = '!broker_bind'

:end-script:
end script
