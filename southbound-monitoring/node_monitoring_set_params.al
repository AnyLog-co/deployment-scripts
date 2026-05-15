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

if !store_monitoring_dest and !view_monitoring_dest then goto end-script
if !store_monitoring_dest and not !view_monitoring_dest goto view-monitoring-dest


:store-monitoring-dest:
if not !store_monitoring_dest and !node_type != operator and !store_monitoring == true then
<do schedule
    name=store-monitoring-dest and
    time = !schedule_time and
    task if not !store_monitoring_dest then store_monitoring_dest = blockchain get operator bring.last [*][ip] : [*][port]>

if !view_monitoring_dest then goto end-script

:view-monitoring-dest:
if $NODE_TYPE == master-operator or  $NODE_TYPE == master-publisher then
<do schedule
    name = view-monitoring-dest1 and
    time = !schedule_time and
    task if not !view_monitoring_dest then view_monitoring_dest = blockchain get (operator, publisher, query) bring.ip_port>
else if !node_type == master and !system_query == true then
<do schedule
    name = view-monitoring-dest2 and
    time = !schedule_time and
    task if not !view_monitoring_dest then view_monitoring_dest = blockchain get (master, query) bring.ip_port>
<else schedule
    name = view-monitoring-dest3 and
    time = !schedule_time and
    task if not !view_monitoring_dest then view_monitoring_dest = blockchain get query bring.ip_port>


:end-script:
end script
