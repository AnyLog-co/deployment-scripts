#----------------------------------------------------------------------------------------------------------------------#
# Create network params for policy
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/node-deployment/policies/config_policy_networking.al


on error ignore
:set-debug:
if !enable_debug == true then set debug on

if section == broker then goto broker-params

:tcp-params:
# public/advertised ip

set policy new_policy [config][ip] = '!external_ip'
if !enable_dns == true and !external_dns   then set policy new_policy [config][ip] = '!external_dns'
else if !tcp_bind == true and !overlay_ip  then set policy new_policy [config][ip] = '!overlay_ip'
else if !tcp_bind == true                  then set policy new_policy [config][ip] = '!ip'

if      $DNS_DOMAIN or $DNS                 then set policy new_policy [config][local_ip] = '!dns'
else if !tcp_bind == false and !overlay_ip  then set policy new_policy [config][local_ip] = '!overlay_ip'
else if !tcp_bind == false                  then set policy new_policy [config][local_ip] = '!ip'

#if !vpn_advertise == true and !overlay_ip then
#do set policy new_policy [config][vpn_advertise] = true
#do set policy new_policy [config][ip] = '!overlay_ip'
#do set policy new_policy [config][local_ip] = '!overlay_ip'


if !rest_bind == true and $DNS              then set policy new_policy [config][rest_ip] = '!dns'
else if !rest_bind == true and !overlay_ip  then set policy new_policy [config][rest_ip] = '!overlay_ip'
else if !rest_bind == true                  then set policy new_policy [config][rest_ip] = '!ip'

if !broker_bind == true and $DNS              then set policy new_policy [config][broker_ip] = '!dns'
else if !broker_bind == true and !overlay_ip  then set policy new_policy [config][broker_ip] = '!overlay_ip'
else if !broker_bind == true                  then set policy new_policy [config][broker_ip] = '!ip'


set policy new_policy [config][port]     = '!anylog_server_port.int'
set policy new_policy [config][tcp_threads]  = '!tcp_threads.int'
set policy new_policy [config][tcp_bind] = '!tcp_bind.bool'

:rest-params:
set policy new_policy [config][rest_port]     = '!anylog_rest_port.int'
set policy new_policy [config][rest_threads]  = '!rest_threads.int'
set policy new_policy [config][rest_timeout]  = '!rest_timeout.int'
set policy new_policy [config][rest_bind]     = '!rest_bind.bool'

if not !anylog_broker_port then goto end-script

:broker-params:
set policy new_policy [config][broker_port]     = '!anylog_broker_port.int'
set policy new_policy [config][broker_threads]  = '!broker_threads.int'
set policy new_policy [config][broker_bind] = '!broker_bind'

:end-script:
end script
