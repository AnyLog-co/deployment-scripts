# Deployment Scripts 

This repository contains the default deployment process and sample scripts for AnyLog and EdgeLake.

These scripts streamline the setup, configuration, and management of nodes, and are downloaded automatically when 
running through Docker, Podman, or Kubernetes.

If you want to use these deployment scripts locally when running AnyLog / EdgeLake from source or as a service, follow the steps described in
<a href="https://github.com/AnyLog-co/documentation/blob/master/deployments/AnyLog_as_Service.md" target="_blank">AnyLog as a Service</a>. 

- [Node Deployment](#node-deployment)
  - [Process for Node Deployment](#process-for-node-deployment)
- [Southbound Industrial](southbound-industrial/README.md)
- [Southbound Monitoring](southbound-monitoring/README.md)
  - [Node Monitoring](southbound-monitoring/README.md#node-monitoring)
  - [Syslog & Docker Monitoring](southbound-monitoring/README.md#syslog--docker-monitoring)
  - [Docker](southbound-monitoring/README.md#docker)
- [gRPC](gRPC/README.md)
- [Enable Aggregations](#enable-aggregations)
  - [Python Call](#python-call)



### Repository Structure 
```tree
├───node-deployment             <-- Node deployment process scripts
│   ├───database                <-- Database setup and initialization
│   └───policies                <-- Policy configuration scripts
├───data-generator              <-- Scripts for ingesting sample data from the Sample Data Generator
├───grpc                        <-- gRPC connection scripts, protocol definitions, and compilation utilities
│   └───kubearmor               <-- gRPC scripts specific to KubeArmor integration
├───sample-scripts              <-- Scripts to receive data from third-party applications
├───southbound-industrial       <-- Scripts to accept data from OPC-UA, Modbus, EtherIP, and other industrial protocols
├───southbound-monitoring       <-- Scripts for collecting and ingesting monitoring data from nodes
├───test-network-local-scripts  <-- Scripts used by the test network in local environments
└──customers                    <-- Customer-specific deployment scripts and configurations
    ├───machine-builder
    └───smart-city
        ├───grafana
        │   ├───power_plant
        │   ├───waste_water
        │   └───water_plant
        └───imgs
```

## Node Deployment

The process of deploying a node is entirely configuration-based and is initiated via the [main.al](node-deployment/main.al) script. 

```
# AnyLog
python3 anylog.py process deployment-scripts/node-deployment/main.al

# EdgeLake
python3 edgelake.py process deployment-scripts/node-deployment/main.al
``` 

**Note**: `process` is an AnyLog/EdgeLake built-in function for executing `.al` scripts.


### Process for node deployment

0. **Set environment variables** - This is handled automatically when running via Docker or Kubernetes.


1. **Set file paths in the agent**

```anylog
set anylog_path = /app
set anylog home !anylog_path 
create work directories
```


2. **Convert environment variables** - Environment variables are mapped to AnyLog/EdgeLake variables via [set_params.al](node-deployment/set_params.al)


3. **Declare configuration policy** - The configuration policy defines:
   * Which services to enable
   * Which additional scripts to run 
   * The operational role of the node

Below is an example policy for an operator node. When applied, it enables:
* TCP 
* REST 
* Blockchain sync 
* Cluster + operator policies (if DNE)
* associated logical databases 
* data processing processes 
* (optional) node monitoring  
* (optional) industrial device(s)
* enable license if not EdgeLake

```json
 {'config' : {
    'name' : 'operator-configs',
    'company' : 'My Company',
    'node_type' : 'operator',
    'ip' : '!external_ip',
    'local_ip' : '!ip',
    'port' : '!anylog_server_port.int',
    'rest_port' : '!anylog_rest_port.int',
    'threads' : '!tcp_threads.int',
    'tcp_bind' : '!tcp_bind',
    'rest_threads' : '!rest_threads.int',
    'rest_timeout' : '!rest_timeout.int',
    'rest_bind' : '!rest_bind',
    'script' : [
      'process !local_scripts/connect_blockchain.al',
      'process !local_scripts/policies/cluster_policy.al',
      'process !local_scripts/policies/node_policy.al',
      'process !local_scripts/database/deploy_database.al',      
      'run scheduler 1',
      'set buffer threshold where time=!threshold_time and volume=!thre',
      'shold_volume and write_immediate=!write_immediate',
      'run streamer',
      'if !enable_ha == true then run data distributor',
      'if !enable_ha == true then run data consumer where start_date=!start_data',
      'if !operator_id and !blockchain_source != master then run operator where create_table=!create_table and update_tsd_info=!update_tsd_info and compress_json=!compress_file and compress_sql=!compress_sql and archive_json=!archive and archive_sql=!archive_sql and blockchain=!blockchain_source and policy=!operator_id and threads=!operator_threads',
      'if !operator_id and !blockchain_source == master then run operator where create_table=!create_table and update_tsd_info=!update_tsd_info and compress_json=!compress_file and compress_sql=!compress_sql and archive_json=!archive and archive_sql=!archive_sql and master_node=!ledger_conn and policy=!operator_id and threads=!operator_threads',
      'process !anylog_path/deployment-scripts/southbound-monitoring/config_monitoring_policy.al',
      'process !anylog_path/deployment-scripts/southbound-industrial/industrial_policy.al',
      'if !deploy_local_script == true then process !local_scripts/local_script.al',
      'if !is_edgelake == false then process !local_scripts/policies/license_policy.al'
    ],
    'id' : '2e54c04ce4e1241d41e68cbbd31a2469',
    'date' : '2025-08-04T17:07:16.505677Z',
    'ledger' : 'global'
  }
}
```

## Enable Aggregations

The <a href="https://github.com/AnyLog-co/documentation/blob/master/aggregations.md" target="_blank">Aggregation function</a>
allows you to summarize streaming data over a time interval. While it can be run via the AnyLog CLI, it is often simpler 
to deploy it using a Python or REST script.

This process should run on either a **Publisher** or **Operator** node — whichever is initially receiving the data.

**Base CLI Command**: 
```anylog 
<set aggregations where 
   dbms=opcua_demo and 
   table=t1 and 
   intervals=1 minute and 
   time=10 minutes  and
   time_column=timestamp and
   value_column=value>
```

### Python Call
1. Locate [set_aggregations.py](sample-scripts/set_aggregations.py) script
```shell
docker volume inspect docker-makefiles_my-operator-local-scripts
```

**Output**
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

```shell
python3 /var/lib/docker/volumes/    "docker-makefiles_my-operator-local-scripts/_data/sample-scripts\set_aggregations.py --help
```

**Output**
```output
usage: set_aggregations.py [-h] [--table TABLE] [--interval INTERVAL] [--time-frame TIME_FRAME] conn dbms
positional arguments:
  conn                  Comma-separated operator or publisher connections
  dbms                  Database name

options:
  -h, --help            show this help message and exit
  --table TABLE         Table name (default: None)
  --interval INTERVAL
  --time-frame TIME_FRAME
```
**Note**: If `--table` is not provided, the script will execute aggregation for all numeric columns in all tables of the specified database.

3. Execute aggregation
```shell
python3 /var/lib/docker/volumes/    "docker-makefiles_my-operator-local-scripts/_data/sample-scripts\set_aggregations.py 127.0.0.1:32149 opcua_demo
```
