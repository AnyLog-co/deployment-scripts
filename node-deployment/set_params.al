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
if !debug_mode == true then set debug on

# if $DISABLE_CLI == true or  $DISABLE_CLI == True or $DISABLE_CLI == TRUE then set cli off

:required-params:
company_name = "New Company"
ledger_conn = 127.0.0.1:32048
hostname = get hostname

if $NODE_TYPE == master-operator then set node_type = operator
else if $NODE_TYPE == master-publisher then set node_type = publisher
else if $NODE_TYPE then set node_type = $NODE_TYPE
else goto missing-node-type

if $NODE_NAME then node_name = $NODE_NAME
else node_name = !hostname + " " + !node_type

set node name !node_name

if $COMPANY_NAME then company_name = $COMPANY_NAME

if $LEDGER_CONN then ledger_conn=$LEDGER_CONN

if $LICENSE_KEY then license_key = $LICENSE_KEY

:general-params:
loc_info = rest get where url = https://ipinfo.io/json
if $LOCATION then loc = $LOCATION
if $COUNTRY then country = $COUNTRY
if $STATE then state = $STATE
if $CITY then city = $CITY
if $BRANCH then branch= $BRANCH
if $DEPT then dept = $DEPT

if !loc_info and not !loc then loc = from !loc_info bring [loc]
if not !loc_info and not !loc then loc = 0.0, 0.0
if !loc_info and not !country then country = from !loc_info bring [country]
if not !loc_info and not !country then country = Unknown
if !loc_info and not !state then state = from !loc_info bring [region]
if not !loc_info and not !state then state = Unknown
if !loc_info and not !city then city = from !loc_info bring [city]
if not !loc_info and not !city then city = Unknown

:networking:
set configure_dns=false
config_name = !node_type.name + - + !company_name.name + -configs
if $ANYLOG_BROKER_PORT then config_name = !node_type.name + - + !company_name.name + -configs-broker
set anylog_server_port = ""
set anylog_rest_port = ""
tcp_bind = false
tcp_threads=6
rest_bind = false
rest_threads=6
rest_timeout=30
broker_bind = false
broker_threads=6

if $CONFIGURE_DNS == true or $CONFIGURE_DNS == True or $CONFIGURE_DNS == TRUE then set configure_dns = true
if $ANYLOG_SERVER_PORT then anylog_server_port = $ANYLOG_SERVER_PORT
if $ANYLOG_REST_PORT then anylog_rest_port = $ANYLOG_REST_PORT

if !node_type == master and not !anylog_server_port then anylog_server_port = 32048
if !node_type == master and not !anylog_rest_port then anylog_rest_port = 32049
if !node_type == operator and not !anylog_server_port then anylog_server_port = 32148
if !node_type == operator and not !anylog_rest_port then anylog_rest_port = 32149
if !node_type == query and not !anylog_server_port then anylog_server_port = 32348
if !node_type == query and not !anylog_rest_port then anylog_rest_port = 32349
if !node_type == publisher and not !anylog_server_port then anylog_server_port = 32248
if !node_type == publisher and not !anylog_rest_port then anylog_rest_port = 32249
if not !anylog_server_port then anylog_server_port = 32548
if not !anylog_rest_port then anylog_rest_port = 32549


if $TCP_BIND == true or $TCP_BIND == True or $TCP_BIND == TRUE then tcp_bind = true
if $TCP_THREADS then tcp_threads = $TCP_THREADS
if !tcp_threads.int < 1 then tcp_threads = 1

if $REST_BIND == true or $REST_BIND == True or $REST_BIND == TRUE then rest_bind = true
if $REST_THREADS then rest_threads = $REST_THREADS
if !rest_threads.int < 1 then rest_threads = 1
if $REST_TIMEOUT then rest_timeout = $REST_TIMEOUT
if !rest_timeout.int < 0 then rest_timeout = 0 # continuous

if $ANYLOG_BROKER_PORT then anylog_broker_port = $ANYLOG_BROKER_PORT
if $BROKER_BIND == true or $BROKER_BIND == True or $BROKER_BIND == TRUE then broker_bind = true
if !broker_threads.int < 1 then broker_threads = 1

# update !ip based on $NIC_TYPE
if $NIC_TYPE then set internal ip with $NIC_TYPE
# useer OVERLAY IP address
if not $NIC_TYPE and $OVERLAY_IP then overlay_ip = $OVERLAY_IP
if $PROXY_IP then proxy_ip = $PROXY_IP
if $CONFIG_NAME then config_name = $CONFIG_NAME

# option to not set ledger_conn for master
if !node_type == master and not $LEDGER_CONN and !overlay_ip then tmp_ledger = !overlay_ip + ":" + !anylog_server_port
else if !node_type == master and not $LEDGER_CONN then tmp_ledger = !ip + ":" + !anylog_server_port
if !node_type == master and not $LEDGER_CONN then ledger_conn = python !tmp_ledger.strip()

:authentication:
set enable_auth = false
if !is_edgelake == false and ($ENABLE_AUTH == true or $ENABLE_AUTH == True or $ENABLE_AUTH == TRUE) then set enable_auth = true
if !is_edgelake == true or !enable_auth == false then goto sql-database

if $NODE_PASSWORD then node_password = $NODE_PASSWORD
if $USERNAME then username = $USERNAME
if $USER_PASSWORD then user_passsword = $USER_PASSWORD

:sql-database:
db_type = sqlite
set autocommit = true
set unlog = false
default_dbms=!company_name.name
set system_query = false
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
if !node_type == query or $SYSTEM_QUERY == true or $SYSTEM_QUERY == True or $SYSTEM_QUERY == TRUE  then
do set system_query = true
do if $MEMORY == false or $MEMORY == False or $MEMORY == FALSE then set memory=false

system_query_db = sqlite
if $SYSTEM_QUERY_DB == psql or $SYSTEM_QUERY_DB == sqlite then system_query_db = $SYSTEM_QUERY_DB

:blob-storage:
# store blobs in data store - mongo, s3, akave, minio, etc.
set blobs_storage = false
# store blobs in local file
set blobs_folder = true
# compress blobs
set blobs_compress = true
# reuse repeating blobs
set blobs_reuse = true

# store blobs in storage that's not local file system
if $BLOBS_STORAGE == true or $BLOBS_STORAGE == True or $BLOBS_STORAGE == TRUE then set blobs_storage = true

# by default we're storing blobs to local files, so disable that option - either by user or us
# - user can force disable by setting folder as False
# - user can force enable by setting  folder as True
if $BLOBS_FOLDER == false or $BLOBS_FOLDER == False or $BLOBS_FOLDER == FALSE then set blobs_folder = false
else if not $BLOBS_FOLDER and !blobs_dbms == true then set set blobs_folder = false


if $BLOBS_REUSE == false or $BLOBS_REUSE == False or $BLOBS_REUSE == FALSE then set blobs_reuse = false

# Storage type (mongo, akave, s3 , etc)
if $BLOB_STORAGE_TYPE then blob_storage_type = $BLOB_STORAGE_TYPE

# URL or IP address to access blob storage
if $BLOB_STORAGE_IP then blob_storage_ip = $BLOB_STORAGE_IP
if $BLOB_STORAGE_PORT then blob_storage_port = $BLOB_STORAGE_PORT

:blob-dbms:
# MongoDB access credentials
if $BLOB_STORAGE_USER then blob_storage_user = $BLOB_STORAGE_USER
if $BLOB_STORAGE_PASSWORD then blob_storage_password = $BLOB_STORAGE_PASSWORD

:blob-bucket:
if $BUCKET_GROUP then bucket_group = $BUCKET_GROUP
if $BUCKET_ID then bucket_id = $BUCKET_ID
if $BUCKET_ACCESS_KEY then bucket_access_key = $BUCKET_ACCESS_KEY
if $BUCKET_SECRETE_KEY then bucket_secrete_key = $BUCKET_SECRETE_KEY
if $BUCKET_REGION then bucket_region = $BUCKET_REGION

:blockchain-basic:
# blockchain platform - either master (node) or optimism
set blockchain_source = master
set blockchain_destination = file
blockchain_sync = 30 seconds
# whether to use the master node as a relay against the blockchain or not
set is_relay=false

if $BLOCKCHAIN_SYNC then blockchain_sync = $BLOCKCHAIN_SYNC
if $BLOCKCHAIN_SOURCE then blockchain_source=$BLOCKCHAIN_SOURCE
if $DESTINATION then set blockchain_destination=$DESTINATION
if !node_type == master and !blockchain_source != master then set is_relay = true
if $LEDGER_CONN ledger_conn = $LEDGER_CONN

if blockchain_source == master then goto operator-settings

:blockchain-connect:
# live blockchain configuration
provider = https://optimism-sepolia.infura.io/v3/532f565202744c0cb7434505859efb74
blockchain_public_key = 0xdf29075946610ABD4FA2761100850869dcd07Aa7
blockchain_private_key = 712be5b5827d8c111b3e57a6e529eaa9769dcde550895659e008bdcf4f893c1c
chain_id = 11155420

if $PROVIDER then provider = $PROVIDER
if $BLOCKCHAIN_PUBLIC_KEY then blockchain_public_key = $BLOCKCHAIN_PUBLIC_KEY
if $BLOCKCHAIN_PRIVATE_KEY then blockchain_private_key = $BLOCKCHAIN_PRIVATE_KEY
if $CHAIN_ID then chain_id = $CHAIN_ID
if $CONTRACT then contract = $CONTRACT

:operator-settings:
set enable_partitions = true
table_name=*
partition_column = insert_timestamp
partition_interval = day
partition_keep = 3
partition_sync = 1 day

if $MEMBER and $MEMBER.int then member = $MEMBER

if $ENABLE_PARTITIONS == false or $ENABLE_PARTITIONS == False or $ENABLE_PARTITIONS == FALSE then set enable_partitions=false

if not $CLUSTER_NAME or $CLUSTER_NAME == nc-cluster or $CLUSTER_NAME == new-cluster then cluster_name = !company_name.name + -cluster- + !hostname.name
else cluster_name = $CLUSTER_NAME

if $TABLE_NAME then table_name=$TABLE_NAME
if $PARTITION_COLUMN then set partition_column = $PARTITION_COLUMN
if $PARTITION_INTERVAL then set partition_interval = $PARTITION_INTERVAL
if $PARTITION_KEEP then set partition_keep = $PARTITION_KEEP
if $PARTITION_SYNC then set partition_sync = $PARTITION_SYNC

:operator-ha:
set enable_ha = false
start_data = -30d

if $ENABLE_HA == true or $ENABLE_HA == TRUE or $ENABLE_HA == True then set enable_ha=true
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

:docker-monitoring:
set docker_continuous = true
if $DOCKER_CONTINUOUS == false or $DOCKER_CONTINUOUS == False or $DOCKER_CONTINUOUS == FALSE then  set docker_continuous = false

:opcua-configs:
set enable_opcua=false
set set_opcua_tags = false
if $SET_OPCUA_TAGS == true or $SET_OPCUA_TAGS == True or $SET_OPCUA_TAGS == TRUE then set set_opcua_tags=true
if $ENABLE_OPCUA == true or $ENABLE_OPCUA == True or $ENABLE_OPCUA == TRUE then set enable_opcua = true
if $OPCUA_URL then opcua_url=$OPCUA_URL
if $OPCUA_NODE then opcua_node=$OPCUA_NODE
if $OPCUA_FREQUENCY then opcua_frequency=$OPCUA_FREQUENCY


:etherip-conifgs:
set enable_etherip=false
set set_etherip_tags=false
if $ENABLE_ETHERIP == true or $ENABLE_ETHERIP == True or $ENABLE_ETHERIP == TRUE then set enable_etherip = true
if $ETHERIP_URL then etherip_url = $ETHERIP_URL
else if !enable_etherip and ($SIMULATOR_MODE == true or $SIMULATOR_MODE == True or $SIMULATOR_MODE == TRUE) then etherip_url=127.0.0.1
if $ETHERIP_FREQUENCY then etherip_frequency = $ETHERIP_FREQUENCY
if $SET_ETHERIP_TAGS == true or $SET_ETHERIP_TAGS == True or $SET_ETHERIP_TAGS == TRUE then set set_etherip_tags=true

:aggregations:
set enable_aggregations = false
aggregations_intervals  = 10
aggregations_time = 1 minute
aggregation_time_column = insert_timestamp
aggregation_value_column = value

if $ENABLE_AGGREGATIONS == true or $ENABLE_AGGREGATIONS == True or $ENABLE_AGGREGATIONS == TRUE then set enable_aggregations = true
if $AGGREGATIONS_INTERVALS then aggregations_intervals = $AGGREGATIONS_INTERVALS
if $AGGREGATIONS_TIME then aggregations_time = $AGGREGATIONS_TIME
if $AGGREGATION_TIME_COLUMN then aggregation_time_column = $AGGREGATION_TIME_COLUMN
if $AGGREGATION_VALUE_COLUMN then aggregation_value_column = $AGGREGATION_VALUE_COLUMN

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

if $ARCHIVE == false or $ARCHIVE == False or $ARCHIVE == FALSE then set archive=false
if $ARCHIVE_SQL == true or $ARCHIVE == True or $ARCHIVE == TRUE then set archive_sql=true
if $ARCHIVE_DELETE then archive_delete=$ARCHIVE_DELETE

:end-script:
end script

:terminate-scripts:
exit scripts

:missing-node-type:
print "Missing node type, cannot continue..."
goto terminate-scripts

# :missing-node-name:
# print "Missing node name, cannot continue..."
# goto terminate-scripts

:missing-license-key:
print "Missing license key, cannot continue..."
goto terminate-scripts

:missing-company-name:
print "Missing company name, cannot continue..."
goto terminate-scripts

:missing-ledger-conn:
print "Missing ledger connection information, cannot continue..."
goto terminate-scripts

:invalid-blockchain-source:
print "Invalid blockchain source " !blockchain_source " (valid sources: optimism, master)"
goto terminate-scripts

:invalid-sql-database:
print "Invalid SQL database type " $DB_TYPE ", cannot continue..."
goto terminate-scripts

:invalid-nosql-database:
print "Invalid NoSQL database type " $NOSQL_TYPE ", cannot continue..."
goto terminate-scripts
