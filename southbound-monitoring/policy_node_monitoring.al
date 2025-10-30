#----------------------------------------------------------------------------------------------------------------------#
# Configure node monitoring
#   1. Get Query node IP and port
#   2. Get Operator IP and port
#       - If operator then connect dbms monitoring and set partitions
#       - If operator is not operator + publish --> specify operator node
#   3. Get insights about node
#   4. Send to query node
#   5. Send to Operator node(s)
#
# :Sample Data:
# {
#    'node name' : 'anylog-query@172.232.20.156:32348',
#    'status' : 'Active',
#    'operational time' : '00:00:00',
#    'processing time' : '00:00:00',
#    'elapsed time' : '00:00:30',
#    'new rows' : 0,
#    'total rows' : 0,
#    'new errors' : 0,
#    'total errors' : 0,
#    'avg. rows/sec' : 0.0,
#    'timestamp' : '2024-09-19 15:34:50.112695',
#    'Free space %' : 65.43,
#    'CPU %' : 1.1,
#    'Packets Recv' : 205093,
#    'Packets Sent' : 201552,
#    'Network Error' : 0
# }
#----------------------------------------------------------------------------------------------------------------------#
# process !anylog_path/deployment-scripts/southbound-monitoring/policy_node_monitoring.al

set debug interactive
on error ignore

:set-params:
schedule_id = node-monitoring
set create_policy = false

:check-policy:
is_policy = blockchain get schedule where id=!schedule_id

# just created the policy + exists
if !is_policy then goto config-policy

# failure show created policy
if not !is_policy and !create_policy == true then goto declare-policy-error

:create-policy
<new_policy = {
    "schedule": {
        "id": !schedule_id,
        "name": "Node Monitoring Schedule",
        "scripts": [
            "print set database",
            "if !node_type == operator then process !anylog_path/deployment-scripts/southbound-monitoring/create_node_monitoring_table.al",

            "print prep test",
            "if !node_type != operator and !store_monitoring == true and not !monitoring_storage_dest then schedule name=get-storage-dest and time = 300 seconds task if not !monitoring_storage_dest then monitoring_storage_dest = blockchain get operator bring.last [*][ip] : [*][port]",
            "if not !view_monitoring_dest then schedule name = get-view-dest  and time = 300 seconds task if not !view_monitoring_dest then view_monitoring_dest = blockchain get query bring.ip_port",

            "print insights",
            "schedule name = get_stats and time=30 seconds and task node_insight = get stats where service = operator and topic = summary  and format = json",
            "schedule name = get_timestamp and time=30 seconds and task node_insight[timestamp] = get datetime local now()",
            "schedule name = set_node_type and time=30 seconds and task set node_insight[node type] = !node_type",

            "schedule name = get_disk_space and time=30 seconds and task disk_space = get disk percentage .",
            "schedule name = get_cpu_percent and time = 30 seconds task cpu_percent = get node info cpu_percent",
            "schedule name = get_packets_recv and time = 30 seconds task packets_recv = get node info net_io_counters packets_recv",
            "schedule name = get_packets_sent and time = 30 seconds task packets_sent = get node info net_io_counters packets_sent",

            "schedule name = disk_space   and time = 30 seconds task if !disk_space   then node_insight[Free Space Percent] = !disk_space.float",
            "schedule name = cpu_percent  and time = 30 seconds task if !cpu_percent  then node_insight[CPU Percent] = !cpu_percent.float",
            "schedule name = packets_recv and time = 30 seconds task if !packets_recv then node_insight[Packets Recv] = !packets_recv.int",
            "schedule name = packets_sent and time = 30 seconds task if !packets_sent then node_insight[Packets Sent] = !packets_sent.int",

            "schedule name = errin and time = 30 seconds task errin = get node info net_io_counters errin",
            "schedule name = errout and time = 30 seconds task errout = get node info net_io_counters errout",
            "schedule name = get_error_count and time = 30 seconds task if !errin and !errout then error_count = python int(!errin) + int(!errout)",
            "schedule name = error_count and time = 30 seconds task if !error_count then node_insight[Network Error] = !error_count.int",

            "schedule name = local_monitor_node and time = 30 seconds task monitor operators where info = !node_insight",
            "schedule name = clean_status and time = 30 seconds task node_insight[status]='Active'",

            "print send insights",
            "schedule name = monitor_node and time = 30 seconds task if !view_monitoring_dest then run client (!view_monitoring_dest) monitor operators where info = !node_insight",
            "if !store_monitoring == true and !node_type == operator then schedule name = operator_monitor_node and time = 30 seconds task stream !node_insight where dbms=monitoring and table=node_insight",
            "if !store_monitoring == true and !node_type != operator then schedule name = operator_monitor_node and time = 30 seconds task if !monitoring_storage_dest then run client (!monitoring_storage_dest) stream !node_insight where dbms=monitoring and table=node_insight"
        ]
    }
}>


:publish-policy:
on error ignore
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy

:config-policy:
if !debug_mode == true then print "Config from policy"
on error goto config-policy-error
config from policy where id=!schedule_id

:end-script:
end script

:terminate-scripts:
exit scripts

:store-monitoring-error:
print "Failed to store "
:config-policy-error:
print "Failed to configure node based on Schedule ID"
goto terminate-scripts

:sign-policy-error:
print "Failed to sign schedule policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member schedule policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare schedule policy on blockchain"
goto terminate-scripts

