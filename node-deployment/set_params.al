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
# process !local_scripts/node-deployment//set_params.al
on error ignore

if $DISABLE_CLI == true or  $DISABLE_CLI == True or $DISABLE_CLI == TRUE then set cli off

:required-params:
company_name = "New Company"
hostname = get hostname
ledger_conn = 127.0.0.1:32048

set is_hidden =false
set master_configs = false

if not $NODE_TYPE then goto missing-node-type
else if $NODE_TYPE == master-operator  then node_type = operator
else if $NODE_TYPE == master-publisher then node_type = publisher
else set node_type = $NODE_TYPE

if $NODE_TYPE == master-operator or $NODE_TYPE == master-publisher or $NODE_TYPE == master then set master_configs = true
if !node_type != operator and $IS_HIDDEN == true or $IS_HIDDEN == True or $IS_HIDDEN == TRUE then is_hidden = true

if $NODE_NAME then node_name = $NODE_NAME
else node_name = !hostname + " " + !node_type

set node name !node_name

if $COMPANY_NAME then company_name = $COMPANY_NAME


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
set nic_type = ""
set enable_dns = false

config_name = !node_type.name + - + !company_name.name + -configs

if !node_type == generic then
do anylog_server_port = 32548
do anylog_rest_port = 32549
else if !node_type == master then
do anylog_server_port = 32048
do anylog_rest_port = 32049
else if !node_type == query then
do anylog_server_port = 32348
do anylog_rest_port = 32349
else if !node_type == operator then
do anylog_server_port = 32148
do anylog_rest_port = 32149
do anylog_broker_port = 32150
else if !node_type == publisher then
do anylog_server_port = 32248
do anylog_rest_port = 32249
do anylog_broker_port = 32250


tcp_bind = false
tcp_threads=6
rest_bind = false
rest_threads=6
rest_timeout=30
broker_bind = false
broker_threads=6

if $NIC_TYPE then
do set nic_type = $NIC_TYPE
do on error call nic-error
do set internal ip with !nic_type
do on error ignore

if $ENABLE_DNS == true  or $ENABLE_DNS == True or $ENABLE_DNS == TRUE then set  enable_dns = true
if $EXTERNAL_DNS then set external_dns = $EXTERNAL_DNS
if $DNS then set dns = $DNS
else if $DNS_DOMAIN then dns = !hostname.$DNS_DOMAIN

if $ANYLOG_SERVER_PORT then anylog_server_port = $ANYLOG_SERVER_PORT
if $ANYLOG_REST_PORT then anylog_rest_port = $ANYLOG_REST_PORT
if $ANYLOG_BROKER_PORT then anylog_broker_port = $ANYLOG_BROKER_PORT

if $TCP_BIND == true or $TCP_BIND == True or $TCP_BIND == TRUE then tcp_bind = true
if $TCP_THREADS then tcp_threads = $TCP_THREADS
if !tcp_threads.int < 1 then tcp_threads = 1

if $REST_BIND == true or $REST_BIND == True or $REST_BIND == TRUE then rest_bind = true
if $REST_THREADS then rest_threads = $REST_THREADS
if !rest_threads.int < 1 then rest_threads = 1
if $REST_TIMEOUT then rest_timeout = $REST_TIMEOUT
if !rest_timeout.int < 0 then rest_timeout = 0 # continuous

if $BROKER_BIND == true or $BROKER_BIND == True or $BROKER_BIND == TRUE then broker_bind = true
if !broker_threads.int < 1 then broker_threads = 1

# update !ip based on $NIC_TYPE
if $NIC_TYPE then set internal ip with $NIC_TYPE
# useer OVERLAY IP address
if not $NIC_TYPE and $OVERLAY_IP then overlay_ip = $OVERLAY_IP
if $CONFIG_NAME then config_name = $CONFIG_NAME

:ledger-config:
# option to not set ledger_conn for master
if $LEDGER_CONN then
do set env_ledger = $LEDGER_CONN
do if !env_ledger then env_ledger_start = python !env_ledger.split(":")[0]

if !env_ledger_start != "127.0.0.1" and $LEDGER_CONN then
do set ledger_conn = $LEDGER_CONN
do goto authentication

if !master_configs == true and !enable_dns == true then ledger_conn = !external_dns + ":" + !anylog_server_port
else if !master_configs == false and !enable_dns == true then ledger_conn = !external_dns + ":32048"
else if !master_configs == true and !overlay_ip then ledger_conn = !overlay_ip + ":" + !anylog_server_port
else if !master_configs == false and !overlay_ip then ledger_conn = !overlay_ip + ":32048"
else if !master_configs == true then ledger_conn = !ip + ":" + !anylog_server_port
else if !master_configs == false then ledger_conn = !ip + ":32048"

config_version = system grep -m1 "^version" !local_scripts/setup.cfg | awk -F " = " '{print $2}' | xargs

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
if !node_type == query or $SYSTEM_QUERY == true or $SYSTEM_QUERY == True or $SYSTEM_QUERY == TRUE  then
do set system_query = true
do if $MEMORY == false or $MEMORY == False or $MEMORY == FALSE then set memory=false

set enable_mcp = false
if $ENABLE_MCP == true or $ENABLE_MCP == True or $ENABLE_MCP == TRUE then set enable_mcp = true

system_query_db = sqlite
if $SYSTEM_QUERY_DB == psql or $SYSTEM_QUERY_DB == sqlite then system_query_db = $SYSTEM_QUERY_DB

:blob-storage:
# store blobs in data store - mongo, s3, akave, minio, etc.
set blobs_storage = false
# store blobs in local file
# compress blobs
set blobs_compress = true
# reuse repeating blobs
set blobs_reuse = true

# store blobs in storage that's not local file system
if $BLOBS_STORAGE == true or $BLOBS_STORAGE == True or $BLOBS_STORAGE == TRUE then
do set blobs_storage = true
do set blobs_folder = false

# by default we're storing blobs to local files, so disable that option - either by user or us
# - user can force disable by setting folder as False
# - user can force enable by setting  folder as True
if  !blobs_storage == false or ($BLOBS_FOLDER == true or $BLOBS_FOLDER == True or $BLOBS_FOLDER == TRUE) then set blobs_folder=true

# compress blob content when stored (true by default)
if $BLOBS_COMPRESS == false or $BLOBS_COMPRESS == False or $BLOBS_COMPRESS == FALSE then set blobs_compress = false

# reuse blob content if it contains the same hash value (true by default)
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
partition_interval = 14 days
partition_keep = 3
partition_sync = 1 day

if $MEMBER and $MEMBER.int then member = $MEMBER
if $IS_MAIN and ($IS_MAIN == true or $IS_MAIN == True or $IS_MAIN == TRUE) then set is_main = true
else if $IS_MAIN and ($IS_MAIN == false or $IS_MAIN == False  or $IS_MAIN == FALSE) then set is_main = false

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
start_date = -30d

if $ENABLE_HA == true or $ENABLE_HA == TRUE or $ENABLE_HA == True then set enable_ha=true
if $START_DATE then start_date = $START_DATE
if !start_date.int then start_date = - + $START_DATE + d

:video-streaming-configs:
#--- Video Streaming ---
set enable_video_streaming = false
set enable_detections = false
video_url = ""
video_name = fstream
yolo_model_port = 5001
video_port = 32800
video_grpc_dir = !anylog_path/AnyLog-Network/external_lib/frame_modeling
# video_dbms = !default_dbms + "_blobs"

if $ENABLE_VIDEO_STREAMING == true or $ENABLE_VIDEO_STREAMING == True or $ENABLE_VIDEO_STREAMING == TRUE then enable_video_streaming=true
if $ENABLE_DETECTIONS == true or $ENABLE_DETECTIONS == True or $ENABLE_DETECTIONS == TRUE then set enable_detections=true

if $VIDEO_URL then set video_url = $VIDEO_URL
if $VIDEO_PORT then set video_port = $VIDEO_PORT
if $VIDEO_NAME then set video_name=$VIDEO_NAME
if $YOLO_MODEL_PORT then set yolo_model_port=$YOLO_MODEL_PORT

if $VIDEO_GRPC_DIR then video_grpc_dir = $VIDEO_GRPC_DIR

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
if !enable_mqtt == false then goto monitoring

if $MQTT_BROKER then mqtt_broker=$MQTT_BROKER
if $MQTT_PORT then mqtt_port=$MQTT_PORT
if $MQTT_USER then mqtt_user=$MQTT_USER
if $MQTT_PASSWD then mqtt_passwd=$MQTT_PASSWD
if $MQTT_LOG == true or $MQTT_LOG == True or $MQTT_LOG == TRUE then set msg_log =true
if $MSG_TOPIC then msg_topic=$MSG_TOPIC

if $DEFAULT_DBMS then msg_dbms=$DEFAULT_DBMS
else if $MSG_DBMS then msg_dbms=$MSG_DBMS

if $MSG_TABLE then msg_table=$MSG_TABLE
if $MSG_TIMESTAMP_COLUMN then msg_timestamp_column=$MSG_TIMESTAMP_COLUMN
if $MSG_VALUE_COLUMN_TYPE then msg_value_column_type=$MSG_VALUE_COLUMN_TYPE
if $MSG_VALUE_COLUMN then msg_value_column=$MSG_VALUE_COLUMN


:monitoring:
set node_monitoring     = false
set syslog_monitoring   = false
set docker_monitoring   = false
store_monitoring        = false
store_monitoring_dest   = ""
view_monitoring_dest    = ""

monitoring_frequency = "30 seconds"
docker_frequency = 5


if $NODE_MONITORING == true   or $NODE_MONITORING == True   or $NODE_MONITORING == TRUE   then set node_monitoring   = true
if $SYSLOG_MONITORING == true or $SYSLOG_MONITORING == True or $SYSLOG_MONITORING == TRUE then set syslog_monitoring = true
if $DOCKER_MONITORING == true or $DOCKER_MONITORING == True or $DOCKER_MONITORING == TRUE then set docker_monitoring = true

if $STORE_MONITORING == true or $STORE_MONITORING == True or $STORE_MONITORING == TRUE then set store_monitoring = true
# if not set - will be declare using `blockchain get operator bring.last`
if $STORE_MONITORING_DEST then store_monitoring_dest = $STORE_MONITORING_DEST
# if not set - will be declare using `blockchain get query bring.ip_port`
if $VIEW_MONITORING_DEST then view_monitoring_dest = $VIEW_MONITORING_DEST

if $MONITORING_FREQUENCY then monitoring_frequency = $MONITORING_FREQUENCY
if $DOCKER_FREQUENCY     then docker_frequency     = $DOCKER_FREQUENCY

:opcua-configs:
set enable_opcua = false
opcua_frequency = 5

if $ENABLE_OPCUA == true or $ENABLE_OPCUA == True or $ENABLE_OPCUA == TRUE then enable_opcua = true
if $OPCUA_URL then opcua_url = $OPCUA_URL
if $OPCUA_NODE then opcua_node = $OPCUA_NODE

if $OPCUA_NAME  then opcua_name = $OPCUA_NAME

if $OPCUA_USERNAME then opcua_username = $OPCUA_USERNAME
if $OPCUA_PASSWORD then opcua_password = $OPCUA_PASSWORD

if $OPCUA_FREQUENCY then opcua_frequency = $OPCUA_FREQUENCY


# :aggregations:
# deploy aggregation based on policy - need policy key
# aggregation_policy = ""
# if $AGGREGATION_POLICY then aggregation_policy = $AGGREGATION_POLICY

#-----------------------------------------------------------------------------#
# Default aggregation parameters                                               #
#-----------------------------------------------------------------------------#
# enable aggregations
# set enable_aggregations = false
# if $ENABLE_AGGREGATIONS and ($ENABLE_AGGREGATIONS == true or $ENABLE_AGGREGATIONS == True or $ENABLE_AGGREGATIONS == TRUE) then set enable_aggregations = true
# else goto other-settings


# Logical database to aggregate against
# set aggregations_dbms = !default_dbms

# Logical table to aggregate against
# set aggregations_table = *

# Number of aggregation intervals to keep
# set aggregations_intervals = 10

# Time window for each aggregation
# set aggregations_time = 1 minute

# Timestamp column used for aggregation
# set aggregation_time_column = insert_timestamp

# Value column to aggregate
# set aggregation_value_column = value

# if $AGGREGATIONS_DBMS then set aggregations_dbms = $AGGREGATIONS_DBMS
# if $AGGREGATIONS_TABLE then set aggregations_table = $AGGREGATIONS_TABLE
# if $AGGREGATIONS_INTERVALS then set aggregations_intervals = $AGGREGATIONS_INTERVALS
# if $AGGREGATIONS_TIME then set aggregations_time = $AGGREGATIONS_TIME
# if $AGGREGATION_TIME_COLUMN then set aggregation_time_column = $AGGREGATION_TIME_COLUMN
# if $AGGREGATION_VALUE_COLUMN then set aggregation_value_column = $AGGREGATION_VALUE_COLUMN
#-----------------------------------------------------------------------------#
# Ingestion behavior                                                          #
#-----------------------------------------------------------------------------#
# Ingest raw (non-aggregated) data
# set ingest_raw_data = true
# Ingest aggregated data
# set ingest_aggregations = false

# if $INGEST_RAW_DATA then set ingest_raw_data = $INGEST_RAW_DATA
# if $INGEST_AGGREGATIONS then set ingest_aggregations = $INGEST_AGGREGATIONS


#-----------------------------------------------------------------------------#
# Optional encoding configuration                                              #
#-----------------------------------------------------------------------------#

# Enable value encoding (true / false)
# set enable_encoding = false

# Encoding tolerance (numeric)
# set encoding_tolerance = ""

# bounds - all entries in the time interval are replaced with a single entry representing:
# arle - Approximated Run-Length Encoding, the entries in the time interval are represented in a sequence of entries. Each entry includes:
# encoding_type = bounds

# if $ENABLE_ENCODING and ($ENABLE_ENCODING == true or $ENABLE_ENCODING == True or $ENABLE_ENCODING == TRUE) then set enable_encoding = true
# if $ENCODING_TOLERANCE then set encoding_tolerance = $ENCODING_TOLERANCE
# if $ENCODING_TYPE then encoding_type = $ENCODING_TYPE

:other-settings:
set deploy_local_script = false
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

:nic-error:
echo "Invalid NIC type " + !nic_Type
return


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
