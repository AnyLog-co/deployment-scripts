#-----------------------------------------------------------------------------------------------------------------------
# The following file is intended as a placeholder for user implemented code. The file is automatically called by master,
# operator, publisher, query or single_node (operator / publisher) files. If not is written then nothing runs.
#
# Sample commands could include things like;
#   * complicated MQTT calls
#   * Kafka requests
#   * non-standard schedule processes, such as recording disk usage and automated queries
#
# Documentation: https://github.com/AnyLog-co/documentation
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/local_script.al

# set debug interactive

run scheduler 2
if !node_type == operator and !store_ then process !local_scripts/southbound-monitoring/configure_dbms_monitoring.al
schedule scheduler = 2 and name = get_stats and time=!monitoring_frequency and task node_insight = get stats where service = operator and topic = summary  and format = json
schedule scheduler = 2 and name = get_timestamp and time=!monitoring_frequency and task node_insight[timestamp] = get datetime local now()

schedule scheduler = 2 and name = get_disk_space and time=!monitoring_frequency and task disk_space = get disk percentage .
schedule scheduler = 2 and name = get_cpu_percent and time = 30 seconds task cpu_percent = get node info cpu_percent
schedule scheduler = 2 and name = get_packets_recv and time = 30 seconds task packets_recv = get node info net_io_counters packets_recv
schedule scheduler = 2 and name = get_packets_sent and time = 30 seconds task packets_sent = get node info net_io_counters packets_sent

schedule scheduler = 2 and name = disk_space   and time = 30 seconds task if !disk_space   then node_insight[Free Space Percent] = !disk_space.float
schedule scheduler = 2 and name = cpu_percent  and time = 30 seconds task if !cpu_percent  then node_insight[CPU Percent] = !cpu_percent.float
schedule scheduler = 2 and name = packets_recv and time = 30 seconds task if !packets_recv then node_insight[Packets Recv] = !packets_recv.int
schedule scheduler = 2 and name = packets_sent and time = 30 seconds task if !packets_sent then node_insight[Packets Sent] = !packets_sent.int

schedule scheduler = 2 and name = errin and time = 30 seconds task errin = get node info net_io_counters errin
schedule scheduler = 2 and name = errout and time = 30 seconds task errout = get node info net_io_counters errout
schedule scheduler = 2 and name = get_error_count and time = 30 seconds task if !errin and !errout then error_count = python int(!errin) + int(!errout)
schedule scheduler = 2 and name = error_count and time = 30 seconds task if !error_count then node_insight[Network Error] = !error_count.int

# schedule scheduler = 2 and name = set_node_type and time=!monitoring_frequency and task set node_insight[node type] = !node_type
# schedule scheduler = 2 and name = clean_status and time = 30 seconds task node_insight[status]='Active'


schedule scheduler = 2 and name = local_monitor_node and time = 30 seconds task monitor operators where info = !node_insight

if !store_monitoring == true and !node_type == operator then schedule scheduler = 2 and name = operator_monitor_node and time = 30 seconds task stream !node_insight where dbms=monitoring and table=node_insight

# schedule scheduler = 2 and name = monitor_node and time = 30 seconds task if !view_monitoring_dest then run client (!view_monitoring_dest) monitor operators where info = !node_insight
# if !store_monitoring == true and !node_type != operator then schedule scheduler = 2 and name = operator_monitor_node and time = 30 seconds task if !store_monitoring_dest then run client (!store_monitoring_dest) stream !node_insight where dbms=monitoring and table=node_insight
