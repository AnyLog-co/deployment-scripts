#-----------------------------------------------------------------------------------------------------------------------
# Run gRPC client against AnyLog
#   - The HealthCheck simply replies the corresponding value sent to it. It's suppose to show bidirectional communication
#   -
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/grpc/kubearmor/grpc_client.al
on error call grpc-client-error

if !grpc_function == HealthCheck then
<do run grpc client where
    ip = !grpc_client_ip and port = !grpc_client_port and
    name = !grpc_name and
    grpc_dir = !grpc_dir and
    proto = !grpc_proto and
    function = !grpc_function and
    request = !grpc_request and
    response = !grpc_response and
    service = !grpc_service and
    value = !grpc_value and
    debug = true and
    limit = 1
>
do goto end-script

<run grpc client where
    ip = !grpc_client_ip and port = !grpc_client_port and
    name = !grpc_name and
    grpc_dir = !grpc_dir and
    proto = !grpc_proto and
    function = !grpc_function and
    request = !grpc_request and
    response = !grpc_response and
    service = !grpc_service and
    value = !grpc_value and
    policy = !grpc_name and
    dbms = !default_dbms and
    table = !table_name and
    debug = !grpc_debug and
    ingest = !grpc_ingest and
    limit = !grpc_limit
>


:end-script:
end script

:grpc-client-error:
echo "Failed to run grpc client"
goto end-script
