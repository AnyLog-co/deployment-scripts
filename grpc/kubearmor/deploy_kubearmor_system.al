#-----------------------------------------------------------------------------------------------------------------------
# Deploy process to accept data from KubeArmor
# Steps:
#   1. Compile proto file
#   2. Set params
#   3. Declare Policy
#   4. gRPC client
#-----------------------------------------------------------------------------------------------------------------------
# process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/deploy_kubearmor_system.al
on error ignore

# Compile proto file
#:compile-proto:
# on error goto compile-error
# compile proto where protocol_file=$ANYLOG_PATH/deployment-scripts/grpc/kubearmor/kubearmor/kubearmor.proto

# Set Params
:set-params:

grpc_client_ip = 10.128.0.8
grpc_client_port = 32769
grpc_dir = $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/
grpc_proto = kubearmor
grpc_value = (Filter = all)
grpc_limit = 0
set grpc_ingest = true
set grpc_debug = false

grpc_service = LogService
grpc_request = RequestMessage

set alert_flag_1 = false
set alert_level = 0
ingestion_alerts = ''
table_name = bring [Operation]

set default_dbms = kubearmor
set company_name = kubearmor



:run-grpc-client:
grpc_name = kubearmor-message
grpc_function = WatchMessages
grpc_response = Message

process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/kubearmor_message.al
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/grpc_client.al

grpc_name = kubearmor-alert
grpc_function = WatchAlerts
grpc_response = Alert

process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/kubearmor_alert.al
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/grpc_client.al

grpc_name = kubearmor-alert
grpc_function = WatchAlerts
grpc_response = Alert

process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/kubearmor_alert.al
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/grpc_client.al


grpc_name = kubearmor-logs
grpc_function = WatchLogs
grpc_response = Logs
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/kubearmor_log.al
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/grpc_client.al
