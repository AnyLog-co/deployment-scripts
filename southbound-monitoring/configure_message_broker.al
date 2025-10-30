#----------------------------------------------------------------------------------------------------------------------#
# Configure message broker if not set - used by policy_syslog_monitoring.al
#   1. check if message broker is connected - if not, set configs (not port) to be the same as TCP
#   2. connect to message broker
#----------------------------------------------------------------------------------------------------------------------#


:check-network:
on error ignore
conn_info = get connections where format=json
is_msg_broker  = from !conn_info bring [Messaging][external]
if !is_msg_broker == 'Not declared' then set is_msg_broker = false
else goto end-script

:set-configs:
if not !anylog_broker_port then
do anylog_broker_port = 32150
do set broker_bind = !rest_bind
do set broker_threads = !rest_threads

if !is_msg_broker  == 'Not declared' then


:connect-broker:
on error goto connect-broker-error

if !overlay_ip then
<do run message broker where
    external_ip=!external_ip and external_port=!anylog_broker_port and
    internal_ip=!!overlay_ip and internal_port=!anylog_broker_port and
    bind=!broker_bind and threads=!broker_threads>

<else run message broker where
    external_ip=!external_ip and external_port=!anylog_broker_port and
    internal_ip=!ip and internal_port=!anylog_broker_port and
    bind=!broker_bind and threads=!broker_threads>

:end-script:
end script

:terminate-scripts:
exit scripts

:connect-broker-error:
print "Error: Failed to connect to Message Broker with IP address - will continue deployment without Message Broker"
do goto terminate-scripts

