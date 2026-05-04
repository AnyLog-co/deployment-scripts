#----------------------------------------------------------------------------------------------------------------------#
# Mapping policy to accept data from Litmus Edge
# Data is split into one table where metadata will be stored as a raw string
#
#:sample-data:
#{
#   "success":False,
#   "datatype":"uint32",
#   "timestamp":1776294205000,
#   "registerId":"b1",
#   "value":None,
#   "deviceID":"d1",
#   "tagName":"ns1_Device_Temperature",
#   "deviceName":"opcua",
#   "description":"",
#   "metadata":{
#       "error":"BadNodeIdUnknown"
#   }
#}
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/sample-scripts/litmus_single_table.al

on error ignore

topic_name = litmus

:mapping-data:
policy_id = litmus-data
is_policy = blockchain get mapping where id = !policy_id
if !is_policy then goto metadata-mapping

<new_policy = {"mapping" : {
        "id" : !policy_id,
        "dbms" : !default_dbms,
        "table" : "bring [deviceName] _ [deviceID]",
        "readings" : "",
        "schema" : {
            "timestamp" : {
                "type" : "timestamp",
                "default": "now()",
                "bring" : "[timestamp]",
                "apply" :  "epoch_to_datetime"
            },
            "*" : {
                "type": "*",
                "bring": ["success", "tagName", "value", "description"]
            },
            "metadata": {
                "type": "varchar",
                "bring": "[metadata]"
            }
        }
}}>


:publish-policy:
process !local_scripts/node-deployment/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error

:msg-call:
on error goto msg-error
if !anylog_broker_port then
<do run msg client where broker=local and port=!anylog_broker_port and log=false and topic=(
    name=!topic_name and
    policy=!policy_id
)>

if not !anylog_broker_port and !user_name and !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user=!user_name and password=!user_password and user-agent=anylog and log=false and topic=(
    name=!topic_name and
    policy=!policy_id
)>

if not !anylog_broker_port and not !user_name and not !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and topic=(
    name=!topic_name and
    policy=!policy_id
)>

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign master policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member master policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare master policy on blockchain"
goto terminate-scripts

:msg-error:
echo "Failed to deploy MQTT process"
goto end-script

