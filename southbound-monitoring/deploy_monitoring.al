#----------------------------------------------------------------------------------------------------------------------#
# Generic call to initiate monitoring database + declare / execute policies
#   1. create database
#   2. declare node monitoring
#   3. create syslog monitoring
#   4. create docker monitoring
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/southbound-monitoring/deploy_monitoring.al

on error ignore

if !node_type == operator and (!node_monitoring == true or !syslog_monitoring == true or !docker_monitoring == true) then
do process !anylog_path/deployment-scripts/node-deployment/database/configure_dbms_monitoring.al

if !node_monitoring   == true then process !anylog_path/deployment-scripts/southbound-monitoring/policy_node_monitoring.al
if !syslog_monitoring == true then process !anylog_path/deployment-scripts/southbound-monitoring/policy_syslog_monitoring.al
if !docker_monitoring == true then process !anylog_path/deployment-scripts/southbound-monitoring/policy_docker_monitoring.al

end script