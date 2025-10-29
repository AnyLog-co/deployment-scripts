#-----------------------------------------------------------------------------------------------------------------------
# Script for deploying node monitoring process
# :process:
#   1. if node_type is operator & store_monitoring then create monitoring database & partitioning
#   2. declare schedule policy
#   3. execute policy
# :Generated policy:
# {'schedule' : {
#   'id' : 'generic-schedule-policy',
#   'name' : 'Generic Monitoring Schedule',
#   'script' : [
#       "schedule name = monitoring_ips and time=300 seconds and task monitoring_ips = blockchain get query bring.ip_port",
#       "if !store_monitoring == true and !node_type == operator then process !local_scripts/connectors/monitoring_table_policy.al",
#       "if !store_monitoring == true and !node_type != operator then schedule name=operator_monitoring_ips and time=300 seconds and task if not !operator_monitoring_ip then operator_monitoring_ip = blockchain get operator bring.first [*][ip] : [*][port]",
#       "schedule name = get_stats and time=30 seconds and task node_insight = get stats where service = operator and topic = summary  and format = json",
#       "schedule name = get_timestamp and time=30 seconds and task node_insight[timestamp] = get datetime local now()",
#       "schedule name = set_node_type and time=30 seconds and task node_insight[node type]=!node_type",
#       "schedule name = get_disk_space and time=30 seconds and task disk_space = get disk percentage .",
#       "schedule name = get_cpu_percent and time = 30 seconds task cpu_percent = get node info cpu_percent",
#       "schedule name = get_packets_recv and time = 30 seconds task packets_recv = get node info net_io_counters packets_recv",
#       "schedule name = get_packets_sent and time = 30 seconds task packets_sent = get node info net_io_counters packets_sent",
#       "schedule name = disk_space   and time = 30 seconds task if !disk_space   then node_insight[Free space %] = !disk_space.float",
#       "schedule name = cpu_percent  and time = 30 seconds task if !cpu_percent  then node_insight[CPU %] = !cpu_percent.float",
#       "schedule name = packets_recv and time = 30 seconds task if !packets_recv then node_insight[Packets Recv] = !packets_recv.int",
#       "schedule name = packets_sent and time = 30 seconds task if !packets_sent then node_insight[Packets Sent] = !packets_sent.int",
#       "schedule name = errin and time = 30 seconds task errin = get node info net_io_counters errin",
#       "schedule name = errout and time = 30 seconds task errout = get node info net_io_counters errout",
#       "schedule name = get_error_count and time = 30 seconds task if !errin and !errout then error_count = python int(!errin) + int(!errout)",
#       "schedule name = error_count and time = 30 seconds task if !error_count then node_insight[Network Error] = !error_count.int",
#       "schedule name = local_monitor_node and time = 30 seconds task monitor operators where info = !node_insight",
#       "schedule name = monitor_node and time = 30 seconds task if !monitoring_ips then run client (!monitoring_ips) monitor operators where info = !node_insight",
#       "schedule name = clean_status and time = 30 seconds task node_insight[status]='Active'",
#       "if !store_monitoring == true and !node_type == operator then schedule name = operator_monitor_node and time = 30 seconds task stream !node_insight where dbms=monitoring and table=node_insight",
#       "if !store_monitoring == true and !node_type != operator then schedule name = operator_monitor_node and time = 30 seconds task if !operator_monitoring_ip then run client (!operator_monitoring_ip) stream !node_insight  where dbms=monitoring and table=node_insight"
#   ],
#   'date' : '2024-09-18T23:55:40.154342Z',
#   'ledger' : 'global'
# }}

#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/connectors/monitoring_policy.al
on error ignore
if !debug_mode == true then set debug on

:declare-policy:
# if !store_monitoring == true and !node_type == operator then process !anylog_path/deployment-scripts/southbound-monitoring/node_monitoring_table.al

:set-params:
if !debug_mode == true then print "Setting env params"
schedule_id = generic-schedule-policy
set create_policy = false

:check-policy:
if !debug_mode == true then print "check if policy exists"
is_policy = blockchain get schedule where id=!schedule_id

# just created the policy + exists
if !is_policy then goto config-policy

# failure show created policy
if not !is_policy and !create_policy == true then goto declare-policy-error

:schedule-policy:
if !debug_mode == true then print "create policy"
new_policy=""
<new_policy = {
    "schedule": {
        "id": !schedule_id,
        "name": "Generic Monitoring Schedule",
        "script": [
            "if !store_monitoring == true and !node_type == operator then process !anylog_path/deployment-scripts/southbound-monitoring/node_monitoring_table.al",

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
            "schedule name = monitor_node and time = 30 seconds task if !monitoring_ips then run client (!monitoring_ips) monitor operators where info = !node_insight",
            "schedule name = clean_status and time = 30 seconds task node_insight[status]='Active'",
            
            "if !store_monitoring == true and !node_type == operator then schedule name = operator_monitor_node and time = 30 seconds task stream !node_insight where dbms=monitoring and table=node_insight",
            "if !store_monitoring == true and !node_type != operator then schedule name = operator_monitor_node and time = 30 seconds task if !operator_monitoring_ip then run client (!operator_monitoring_ip) stream !node_insight  where dbms=monitoring and table=node_insight"
        ]
}}>

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

