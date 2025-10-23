on error ignore

if !node_type != operator or (not !monitor_nodes and not !syslog_monitoring and not !docker_monitoring) then goto end-script

:set-dbms-monitoring:
schedule name = monitoring_ips and time=300 seconds and task monitoring_ips = blockchain get query bring.ip_port

if !node_type == operator and (!monitor_nodes == true or !syslog_monitoring == true or !docker_monitoring == true) then
do process !anylog_path/deployment-scripts/southbound-monitoring/configure_dbms_monitoring.al
do goto end-script

:set-schedule:
on error goto set-schedule-error
if !node_type != operator and (!monitor_nodes == true or !syslog_monitoring == true or !docker_monitoring == true) then
<do schedule name=operator_monitoring_ips and time=300 seconds and task
    if not !operator_monitoring_ip then operator_monitoring_ip = blockchain get operator bring.first [*][ip] : [*][port]>

:end-script:
end script

:set-schedule-error:
echo "failed to set schedule to get operator
goto end-script
