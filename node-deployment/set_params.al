#-----------------------------------------------------------------------------------------------------------------------
# The following takes the environment variables and converts them into AnyLog variables
#   --> required params (ex. node_type, node_name, company_name, license)
#   --> general params (ex. hostname, location)
#   --> networking (ex. binding, ports, port thread count, REST timeout)
#   --> authentication (ex. enabling) - credentials are in authentication scripts
#   --> sql-database (ex. type, credentials, enabling system_query)
#   --> nosql-database (ex. type and credentials)
#   --> blockchain (ex. sync time, ledger_conn, source and destination)
#   --> operator-settings (ex. partitioning data, cluster name, operator member ID)
#   --> operator-ha (ex. enable ha and how far back)
#   --> mqtt (ex. enable, broker credential information, data mapping)
#   --> node-monitoring (ex. enable monitoring, node that receives monitoring and company associated with that node)
#   --> settings (ex. streaming speed / size, deploy local/personalized script)
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/deployment_scripts/set_params.al
on error ignore
set debug off
if !debug_mode.int > 0 then set debug on


if $DISABLE_CLI == true or  $DISABLE_CLI == True or $DISABLE_CLI == TRUE then set cli off

:required-params:
node_name = anylog-node
company_name = "New Company"
ledger_conn = 127.0.0.1:32048

if $NODE_TYPE == master-operator then set node_type = operator
else if $NODE_TYPE == master-publisher then set node_type = publisher
else if $NODE_TYPE then set node_type = $NODE_TYPE
else goto missing-node-type

if not $NODE_NAME and !node_type == generic and !is_edgelake == true then node_name = edgelake-node
else if not $NODE_NAME and !node_type != generic then goto missing-node-name
else if $NODE_NAME then set node_name = $NODE_NAME

set node name !node_name

if $LICENSE_KEY then license_key=$LICENSE_KEY

if not $COMPANY_NAME and node_type != generic then goto missing-company-name
else if $COMPANY_NAME then company_name = $COMPANY_NAME

if not $LEDGER_CONN and !node_type != generic then goto missing-ledger-conn
else if $LEDGER_CONN then ledger_conn=$LEDGER_CONN

:general-params:
hostname = get hostname
loc_info = rest get where url = https://ipinfo.io/json
if $LOCATION then loc = $LOCATION
if $COUNTRY then country = $COUNTRY
if $STATE then state = $STATE
if $CITY then city = $CITY

if !loc_info and not !loc then loc = from !loc_info bring [loc]
if not !loc_info and not !loc then loc = 0.0, 0.0
if !loc_info and not !country then country = from !loc_info bring [country]
if not !loc_info and not !country then country = Unknown
if !loc_info and not !state then state = from !loc_info bring [state]
if not !loc_info and not !state then state = Unknown
if !loc_info and not !city then city = from !loc_info bring [city]
if not !loc_info and not !city then city = Unknown

:networking:
config_name = !node_type.name + - + !company_name.name + -configs
if $ANYLOG_BROKER_PORT then config_name = !node_type.name + - + !company_name.name + -configs-broker
tcp_bind = false
tcp_threads=6
rest_bind = false
rest_threads=6
rest_timeout=30
broker_bind = false
broker_threads=6

if !node_type == master then
do anylog_server_port = 32048
do anylog_rest_port = 32049

if !node_type == operator then
do anylog_server_port = 32148
do anylog_rest_port = 32149

if !node_type == publisher then
do anylog_server_port = 32248
do anylog_rest_port = 32249

if !node_type == query then
do anylog_server_port = 32348
do anylog_rest_port = 32349

if !node_type == generic then
do anylog_server_port = 32548
do anylog_rest_port = 32549

if $ANYLOG_SERVER_PORT then anylog_server_port = $ANYLOG_SERVER_PORT
if $TCP_BIND == true or $TCP_BIND == True or $TCP_BIND == TRUE then tcp_bind = true
if $TCP_THREADS then tcp_threads = $TCP_THREADS
if !tcp_threads.int < 1 then tcp_threads = 1

if $ANYLOG_REST_PORT then anylog_rest_port = $ANYLOG_REST_PORT
if $REST_BIND == true or $REST_BIND == True or $REST_BIND == TRUE then rest_bind = true
if $REST_THREADS then rest_threads = $REST_THREADS
if !rest_threads.int < 1 then rest_threads = 1
if $REST_TIMEOUT then rest_timeout = $REST_TIMEOUT
if !rest_timeout.int < 0 then rest_timeout = 0 # continuous

if $ANYLOG_BROKER_PORT then anylog_broker_port = $ANYLOG_BROKER_PORT
if $BROKER_BIND == true or $BROKER_BIND == True or $BROKER_BIND == TRUE then broker_bind = true
if !broker_threads.int < 1 then broker_threads = 1

if $OVERLAY_IP then overlay_ip = $OVERLAY_IP
if $PROXY_IP then proxy_ip = $PROXY_IP
if $CONFIG_NAME then config_name = $CONFIG_NAME

:authentication:
set enable_auth = false
set enable_rest_auth = false
set rest_ssl = false

if $ENABLE_AUTH == true or $ENABLE_AUTH == True or $ENABLE_AUTH == TRUE then set enable_auth = true
if $ENABLE_REST_AUTH == true or $ENABLE_REST_AUTH == True or $ENABLE_REST_AUTH == TRUE then
do set enable_rest_auth = true
do set rest_ssl = true

:sql-database:
db_type = sqlite
set autocommit = true
set unlog = false
default_dbms=!company_name.name
set deploy_system_query = false
set memory = true

if $DEFAULT_DBMS then default_dbms = $DEFAULT_DBMS

if $DB_TYPE and $DB_TYPE != psql and $DB_TYPE != sqlite then goto invalid-sql-database
if $DB_TYPE then set db_type = $DB_TYPE

if $DB_USER then set db_user = $DB_USER
if $DB_PASSWD then set db_passwd = $DB_PASSWD
if $DB_IP then db_ip = $DB_IP
if $DB_PORT then db_port = $DB_PORT

if $AUTOCOMMIT == false or $AUTOCOMMIT == False or $AUTOCOMMIT == FALSE then set autocommit = false
if $UNLOG == true or $UNLOG == True or $UNLOG == TRUE then set unlog =  true
if !node_type == query or $DEPLOY_SYSTEM_QUERY == true or $DEPLOY_SYSTEM_QUERY == True or $DEPLOY_SYSTEM_QUERY == TRUE  then
do set deploy_system_query = true
do if $MEMORY == false or $MEMORY == False or $MEMORY == FALSE then set memory=false

:nosql-database:
set enable_nosql = false
nosql_type = mongo
nosql_ip = 127.0.0.1
nosql_port = 27017
set blobs_dbms = false
set blobs_folder = true
set blobs_compress = true
set blobs_reuse = true

if $ENABLE_NOSQL == true or $ENABLE_NOSQL == True or $ENABLE_NOSQL == TRUE then
do set enable_nosql=true
do set blobs_dbms = true
if $BLOBS_DBMS == true or $BLOBS_DBMS == True or $BLOBS_DBMS == TRUE  then set blobs_dbms = true
if $BLOBS_REUSE == false or $BLOBS_REUSE == False or $BLOBS_REUSE == FALSE then set blobs_reuse = false

# if $NOSQL_TYPE then set nosql_type = $NOSQL_TYPE
# if !nosql_type != mongo then  goto invalid-nosql-database

if $NOSQL_IP then nosql_ip = $NOSQL_IP
if $NOSQL_PORT then nosql_port = $NOSQL_PORT
if $NOSQL_USER then nosql_user = $NOSQL_USER
if $NOSQL_PASSWD then nosql_passwd = $NOSQL_PASSWD

:blockchain:
blockchain_sync = 30 seconds
set blockchain_source = master
set blockchain_destination = file
provider = https://optimism-sepolia.infura.io/v3/532f565202744c0cb7434505859efb74
chain_id = 11155420
public_key = 0xdf29075946610ABD4FA2761100850869dcd07Aa7
private_key = 712be5b5827d8c111b3e57a6e529eaa9769dcde550895659e008bdcf4f893c1c
contract = blockchain deploy contract where  platform = optimism and public_key = !public_key

if $SYNC_TIME then sync_time = $SYNC_TIME
if $BLOCKCHAIN_SOURCE then blockchain_source=$SOURCE
if $DESTINATION then set blockchain_destination=$DESTINATION

# if ledger_conn == 127.0.0.1 and TCP bind is true then update to use local IP
if !tcp_bind == true then
do ledger_ip = python !ledger_conn.split(':')[0]
do ledger_port = python !ledger_conn.split(':')[1]
if !tcp_bind == true and !ledger_ip == 127.0.0.1 and !overlay_ip then ledger_conn = !overlay_ip + : + !ledger_port
if !tcp_bind == true and !ledger_ip == 127.0.0.1 and not !overlay_ip then ledger_conn = !ip + : + !ledger_port


:operator-settings:
set enable_partitions = true
cluster_name = !node_name.name + -cluster
table_name=*
partition_column = insert_timestamp
partition_interval = day
partition_keep = 3
partition_sync = 1 day

if $MEMBER and $MEMBER.int then member = $MEMBER

if $ENABLE_PARTITIONS == false or $ENABLE_PARTITIONS == False or $ENABLE_PARTITIONS == FALSE then set enable_partitions=false
if $CLUSTER_NAME then cluster_name = $CLUSTER_NAME

if $TABLE_NAME then table_name=$TABLE_NAME
if $PARTITION_COLUMN then set partition_column = $PARTITION_COLUMN
if $PARTITION_INTERVAL then set partition_interval = $PARTITION_INTERVAL
if $PARTITION_KEEP then set partition_keep = $PARTITION_KEEP
if $PARTITION_SYNC then set partition_sync = $PARTITION_SYNC

:operator-ha:
set enable_ha = false
set operator_main = false
start_data = -30d

if $ENABLE_HA == true or $ENABLE_HA == TRUE or $ENABLE_HA == True then set enable_ha=true
if $OPERATOR_MAIN == true or $OPERATOR_MAIN == TRUE or $OPERATOR_MAIN == True then set operator_main = true
if $START_DATE then start_date = $START_DATE
if !start_date.int then start_date = - + $START_DATE + d


:mqtt:
set enable_mqtt = false
mqtt_broker = 139.144.46.246
mqtt_port = 1883
mqtt_user = anyloguser
mqtt_passwd = mqtt4AnyLog!

msg_topic = anylog-demo
set msg_log = false
set msg_dbms = "bring [dbms]"
msg_table = "bring [table]"
msg_timestamp_column = "bring [timestamp]"
msg_value_column_type = float
msg_value_column = "bring [value]"

if $ENABLE_MQTT == true or $ENABLE_MQTT == True or $ENABLE_MQTT == TRUE then set enable_mqtt = true
if !enable_mqtt == true then
if $DEFAULT_DBMS then set msg_dbms = $DEFAULT_DBMS
if $MQTT_BROKER then mqtt_broker=$MQTT_BROKER
if $MQTT_PORT then mqtt_port=$MQTT_PORT
if $MQTT_USER then mqtt_user=$MQTT_USER
if $MQTT_PASSWD then mqtt_passwd=$MQTT_PASSWD
if $MSG_TOPIC then msg_topic=$MSG_TOPIC

if $DEFAULT_DBMS then msg_dbms=$DEFAULT_DBMS
else if $MSG_DBMS then msg_dbms=$MSG_DBMS

if $MSG_TABLE then msg_table=$MSG_TABLE
if $MSG_TIMESTAMP_COLUMN then msg_timestamp_column=$MSG_TIMESTAMP_COLUMN
if $MSG_VALUE_COLUMN_TYPE then msg_value_column_type=$MSG_VALUE_COLUMN_TYPE
if $MSG_VALUE_COLUMN then msg_value_column=$MSG_VALUE_COLUMN

:node-monitoring:
set monitor_nodes = true
set store_monitoring = false

if $MONITOR_NODES == false or $MONITOR_NODES == False or $MONITOR_NODES == FALSE then set monitor_nodes = false
if $STORE_MONITORING == true or $STORE_MONITORING == True or $STORE_MONITORING == TRUE then set store_monitoring = true
if $MONITORING_OPERATOR then monitoring_operator = $MONITORING_OPERATOR


:other-settings:
set deploy_local_script = false
set syslog_monitoring = false
set create_table = true
set update_tsd_info = true
set archive = true
set archive_sql = false
set distributor = true
set compress_file = true
set compress_sql = true
set move_json = true
set write_immediate = true
operator_threads = 3
query_pool = 6
archive_delete=30

dbms_file_location = file_name[0]
table_file_location = file_name[1]
threshold_time = 60 seconds
threshold_volume = 10KB

if $DEPLOY_LOCAL_SCRIPT == true or $DEPLOY_LOCAL_SCRIPT == True or $DEPLOY_LOCAL_SCRIPT == TRUE then set deploy_local_script=true
if $SYSLOG_MONITORING == true or $SYSLOG_MONITORING == True or $SYSLOG_MONITORING == TRUE then set syslog_monitoring = true

if !SYSLOG_MONITORING == true and not !anylog_broker_port then
do echo "Unable to deploy syslog support - broker port is required"
do set SYSLOG_MONITORING = false

if $COMPRESS_FILE == false or $COMPRESS_FILE == False or $COMPRESS_FILE == FALSE then set compress_file=false
if $WRITE_IMMEDIATE == false or $WRITE_IMMEDIATE == False or $WRITE_IMMEDIATE == FALSE then set write_immediate=false

#if $DBMS_FILE_LOCATION then dbms_file_location = $DBMS_FILE_LOCATION
#if $TABLE_FILE_LOCATION then table_file_location = $TABLE_FILE_LOCATION

if $THRESHOLD_TIME then threshold_time = $THRESHOLD_TIME
if $THRESHOLD_VOLUME then threshold_volume = $THRESHOLD_VOLUME

if $OPERATOR_THREADS and $OPERATOR_THREADS.int then operator_threads=$OPERATOR_THREADS
if !operator_threads.int < 1 then operator_threads=1

if $QUERY_POOL and $QUERY_POOL.int then query_pool=$QUERY_POOL
if !query_pool.int < 1 then query_pool = 1

if $ARCHIVE_DELETE then archive_delete=$ARCHIVE_DELETE

:end-script:
end script

:terminate-scripts:
exit scripts

:missing-node-type:
print "Missing node type, cannot continue..."
goto terminate-scripts

:missing-node-name:
print "Missing node name, cannot continue..."
goto terminate-scripts

:missing-license-key:
print "Missing license key, cannot continue..."
goto terminate-scripts

:missing-company-name:
print "Missing company name, cannot continue..."
goto terminate-scripts

:missing-ledger-conn:
print "Missing ledger connection information, cannot continue..."
goto terminate-scripts

:invalid-sql-database:
print "Invalid SQL database type " $DB_TYPE ", cannot continue..."
goto terminate-scripts

:invalid-nosql-database:
print "Invalid NoSQL database type " $NOSQL_TYPE ", cannot continue..."
goto terminate-scripts
