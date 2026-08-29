#------------------------------------------------------------------------------------#
# Configure destination params if not set
# - store_monitoring_dest: operator node to store data
# - view_monitoring_dest: query node to store monitoring
#   - if node is standalone then                `view_monitoring_dest = blockchain get (operator, publisher, query)`
#   - if node is master w/ system_query then    `view_monitoring_dest = blockchain get (master, query)`
#   - all other cases                           `view_monitoring_dest = blockchain get query`
# if a variable is not set, then enable a scheduled process to configure it.
#------------------------------------------------------------------------------------#
# process !local_scripts/southbound-monitoring/node_monitoring_set_params.al

if !monitoring_node == true then process !local_scripts/southbound-monitoring/monitoring_node.al

schedule_time = 300 seconds

:get-view-monitoring-dest:
if not !view_monitoring_dest then schedule name=view_monitoring_dest and time=!schedule_time and task view_monitoring_dest = blockchain get monitoring-node where type=query bring.ip_port

:store-monitoring-dest:
if not !store_monitoring_dest then schedule name=store_monitoring_dest and time=!schedule_time and task if not !store_monitoring_dest then store_monitoring_dest = blockchain get monitoring-node where type=operator bring.last [*][ip] : [*][port]


:end-script:
end script
