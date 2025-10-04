# Southbound Monitoring

If any form of monitoring is enabled, the system automatically connects to a logical database called `monitoring`, and 
store associated data for 36 hours in 12 hour partition intervals. 

For convenience, the different monitoring options, and associated database, using [monitoring_policy.al](config_monitoring_policy.al)

## Node Monitoring

By default, AnyLog agents gather basic insights about the machine - such as CPU, disk and memory usage, as well as network 
insights - that's available to view via the Remote-CLI. In addition, this data can be stored on the operator nodes. 

**Command**: 
```anylog 
process deployment-scripts/southbound-monitoring/node_policy.al
```

**Generated / Used Policy**
```json
{'schedule' : {
  'id' : 'generic-schedule-policy',
  'name' : 'Generic Monitoring Schedule',
  'script' : [
    "schedule name = monitoring_ips and time=300 seconds and task monitoring_ips = blockchain get query bring.ip_port",
    "if !store_monitoring == true and !node_type == operator then process !local_scripts/connectors/monitoring_table_policy.al",
    "if !store_monitoring == true and !node_type != operator then schedule name=operator_monitoring_ips and time=300 seconds and task if not !operator_monitoring_ip then operator_monitoring_ip = blockchain get operator bring.first [*][ip] : [*][port]",
    "schedule name = get_stats and time=30 seconds and task node_insight = get stats where service = operator and topic = summary  and format = json",
    "schedule name = get_timestamp and time=30 seconds and task node_insight[timestamp] = get datetime local now()",
    "schedule name = set_node_type and time=30 seconds and task node_insight[node type]=!node_type",
    "schedule name = get_disk_space and time=30 seconds and task disk_space = get disk percentage .",
    "schedule name = get_cpu_percent and time = 30 seconds task cpu_percent = get node info cpu_percent",
    "schedule name = get_packets_recv and time = 30 seconds task packets_recv = get node info net_io_counters packets_recv",
    "schedule name = get_packets_sent and time = 30 seconds task packets_sent = get node info net_io_counters packets_sent",
    "schedule name = disk_space   and time = 30 seconds task if !disk_space   then node_insight[Free space %] = !disk_space.float",
    "schedule name = cpu_percent  and time = 30 seconds task if !cpu_percent  then node_insight[CPU %] = !cpu_percent.float",
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
  ],
  'date' : '2024-09-18T23:55:40.154342Z',
  'ledger' : 'global'
}}
```

If configured store the data on operator node(s) - this data is stored for 36 hours in 12 hour intervals 

## Syslog & Docker Monitoring
AnyLog/EdgeLake enable comprehensive monitoring of both node status and Docker container insights. They also collect 
and store syslog data, allowing you to view the health and activity of your entire distributed network from a single 
centralized point.

### Syslog
Syslog integration involves multiple steps. A detailed explanation of the syslog process is available in the <a href="https://github.com/AnyLog-co/documentation/blob/master/using%20syslog.md" target="_blank">documentation</a>

1. **Enable Message Broker**: When deploying AnyLog / EdgeLake that's supposed to get content from syslog - make sure to enable `ANLOG_BROKER_PORT`
2. **Configure rSyslog**: Set the appropriate rsyslog configurations for your node
3. **Define Message Rules via AnyLog CLI**
```anylog 
<set msg rule my_rule if 
    ip = 10.0.0.78 and port = 1468 then 
    dbms = monitoring and 
    table = syslog and 
    syslog = true>
```

Sample [syslog](syslog_monitoring.al) call using AnyLog script
```process
process !anylog_path/deployment-scripts/southbound-industrial/syslog_monitoring.al
```

### Docker

Monitoring Docker is more straightforward. It primarily requires referencing the docker.socket path in your Docker 
Compose configuration.
When deploying using our [docker-compose](https://github.com/AnyLog-co/docker-compose), this is done automatically.

**Sample Call**:
```anylog 
<run scheduled pull
  where name = docker_insights
  and type = docker
  and frequency = 5
  and continuous = true
  and dbms = monitoring
  and table = docker_insight>
```

Sample [docker](docker_monitoring.al) call using AnyLog script
```process
process !anylog_path/deployment-scripts/southbound-industrial/docker_monitoring.al
```

### Multiple Sources

In large-scale networks, there is often a need to collect syslog and Docker insights from multiple sources.
Running the same command repeatedly with only minor parameter changes can be redundant and time-consuming.
To simplify this process, users can use the [syslog_docker_insight.py](python-code/syslog_docker_insight.py) script, 
which allows executing requests for multiple sources from a single point.

1. Locate [syslog_docker_insight.py](python-code/syslog_docker_insight.py)
```shell
docker volume inspect docker-makefiles_my-operator-local-scripts
```

**Example Output**
```output
[
    {
        "CreatedAt": "2025-07-14T00:52:11Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "docker-makefiles",
            "com.docker.compose.version": "2.29.1",
            "com.docker.compose.volume": "smart-city-operator3-local-scripts"
        },
        "Mountpoint": "/var/lib/docker/volumes/    "docker-makefiles_my-operator-local-scripts/_data",
        "Name": "    "docker-makefiles_my-operator-local-scripts",
        "Options": null,
        "Scope": "local"
    }
]
```

2.View script `help` options
```anylog
python3 /var/lib/docker/volumes/docker-makefiles_my-operator-local-scripts/_data/southbound-monitoring/python-code/syslog_docker_insight.py --help
```

**Output**
```output 
PS C:\Users\oshad\AnyLog-code\deployment-scripts> python3 .\southbound-monitoring\python-code\syslog_docker_insight.py --help 
usage: syslog_docker_insight.py [-h] [--node-type NODE_TYPE] [--node-name NODE_NAME] [--local-ip [LOCAL_IP]] [--db-name DB_NAME] [--docker-table DOCKER_TABLE]
                                [--syslog-table SYSLOG_TABLE] [--docker-insight [DOCKER_INSIGHT]] [--syslog-insight [SYSLOG_INSIGHT]]
                                dest

positional arguments:
  dest                  destination to run command against

options:
  -h, --help            show this help message and exit
  --node-type NODE_TYPE
                        comma separated list of node types to get blockchain info from
  --node-name NODE_NAME
                        comma separated list of node names to get information from
  --local-ip [LOCAL_IP]
                        force use `local_ip`, otherwise will use `ip` address
  --db-name DB_NAME     database to store monitoring in
  --docker-table DOCKER_TABLE
                        table to store docker insight
  --syslog-table SYSLOG_TABLE
                        table to store syslog insight
  --docker-insight [DOCKER_INSIGHT]
                        get docker container insights for node(s)
  --syslog-insight [SYSLOG_INSIGHT]
                        get syslog insights for node(s)
```
**Note**: If no `--node-name` is set, then simply declare `msg rule` for local syslog.

3. Execute `msg rule` based on the provided params
```shell
python3 /var/lib/docker/volumes/docker-makefiles_my-operator-local-scripts/_data/southbound-monitoring/python-code/syslog_docker_insight.py 127.0.0.1:32149 \ 
  --node-type master,operator,query \
  --node-name operator1,query2 \
  --db-name monitoring
  --docker-table docker \
  --syslog-table syslog \
  --docker-insight \
  --syslog-insight
```