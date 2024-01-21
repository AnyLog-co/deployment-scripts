#-----------------------------------------------------------------------------------------------------------------------
# Deploy process to accept data from KubeArmor
# Steps:
#   1. Compile proto file
#   2. Set params
#   3. gRPC client
#-----------------------------------------------------------------------------------------------------------------------
# process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/deploy_kubearmor_healthcheck.al
on error ignore

# Compile proto file
#:compile-proto:
# on error goto compile-error
# compile proto where protocol_file=$ANYLOG_PATH/deployment-scripts/grpc/kubearmor/kubearmor/kubearmor.proto

# Set Params
:set-params:
grpc_name = healthcheck1
grpc_client_ip = 127.0.0.1
grpc_client_port = 32769
grpc_dir = $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/
grpc_proto = kubearmor
grpc_function = HealthCheck
grpc_request = NonceMessage
grpc_response = ReplyMessage
grpc_service = LogService
grpc_value = (nonce = 11.int)
set grpc_debug = true

:run-grpc-client:
process $ANYLOG_PATH/deployment-scripts/grpc/kubearmor/grpc_client.al

