on error ignore
set create_policy = false
set policy_id = "dadosflow-policy"
:check-policy:
is_policy = blockchain get (mapping, transform) where id = !!policy_id
if not !is_policy and !create_policy == false then goto declare-policy
else if !is_policy then goto define-grpc
else if not !is_policy and !create_policy == true then goto declare-policy-error

:declare-policy:
<new_policy = {
  "mapping": {
    "id": !policy_id,
    "dbms": !default_dbms,
    "table": "ds_data",
    "readings": "",
    "schema": {
      "timestamp": {
        "type": "timestamp",
        "default": "now()",
        "bring": "[timestamp]",
        "apply": "epoch_to_datetime"
      },
      "snapshot_id": {
        "type": "string",
        "default": "",
        "bring": "[snapshot_id]"
      },
      "data_type": {
        "type": "int",
        "default" : Null
        "bring": "[data_type]"
      },
      "metric_name": {
        "type": "string",
        "default": "",
        "bring": "[metric_name]"
      },
      "topic": {
        "type": "string",
        "default": "",
        "bring": "[topic]"
      },
      "broker": {
        "type": "string",
        "default": "",
        "bring": "[broker]"
      },
      "seq": {
        "type": "int",
        "default": 0,
        "bring": "[seq]"
      },
      "value_bool": {
        "type": "bool",
        "default" : Null
        "bring": "[value_bool]"
      },
      "value_int": {
        "type": "int",
        "default" : Null
        "bring": "[value_int]"
      },
      "value_double": {
        "type": "float",
        "default" : Null
        "bring": "[value_double]"
      },
      "value_string": {
        "type": "string",
        "default": "",
        "bring": "[value_string]"
      },
      "value_uint": {
        "type": "int",
        "default" : Null
        "bring": "[value_uint]"
      },
      "value_bytes": {
        "type": "string",
        "default" : Null
        "bring": "[value_bytes]"
      },
      "sys_publisher_egress": {
        "type": "timestamp",
        "default": "now()",
        "bring": "[sys_publisher_egress]",
        "apply": "epoch_to_datetime"
      },
      "sys_dadosflow_ingress": {
        "type": "timestamp",
        "default": "now()",
        "bring": "[sys_dadosflow_ingress]",
        "apply": "epoch_to_datetime"
      },
      "sys_dadosflow_egress": {
        "type": "timestamp",
        "default": "now()",
        "bring": "[sys_dadosflow_egress]",
        "apply": "epoch_to_datetime"
      }
    }
  }
}>

:publish-policy:
process !local_scripts/node-deployment/policies/publish_policy.al
if not !error_code.int then
do set create_policy = true
goto check-policy

if !error_code == 1 then goto sign-policy-error
else if !error_code == 2 then goto prepare-policy-error
else if !error_code == 3 then goto declare-policy-error

:define-grpc:
on error goto grpc-error
# run grpc client where name = [unique name] and ip = [IP] and port = [port] and policy = [policy id]
set debug on
reset error log
<run grpc client
  where name = persistence-ds_data
    and ip = 192.168.1.211
    and port = 50055
    and grpc_dir = /app/dados
    and proto = dados
    and function = WatchTable
    and request = WatchRequest
    and response = DataRow
    and service = PersistenceService
    and policy=!policy_id>

:end-script:
set debug off
end script

:terminate-scripts:
set debug off
exit scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts

:grpc-error:
print "Failed to init gRPC client for DaDOS"
goto terminate-scripts
