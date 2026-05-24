#---------------------------------------------------------------------------------------------------------------------#
# Sample mapping policy for Modbus - based on
#   docker run -itd --rm -p 5020:5020 oitc/modbus-server:latest
#
# :URL:
#   https://hub.docker.com/r/oitc/modbus-server
#---------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/southbound-industrial/sample_mapping_modbus.al

on error ignore

policy_id = "modbus-mapping"
set create_policy = false

:check-policy:
is_policy = blockchain get modbus-mapping where id = !policy_id
if not !is_policy and !create_policy == false then goto declare-policy
else if !is_policy then goto end-script
else if not !is_policy and !create_policy == true then goto declare-policy-error

:declare-policy:
set new_policy = ""
<new_policy = {
    "modbus-mapping" : {
        "id": "modbus-mapping",
        "table": "modbus_readings_10",
        "schema": [
            {"name":"kitchen_temperature","register":0},
            {"name":"kitchen_humidity","register":1}
        ]
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

:end-script:
end script

:terminate-scripts:
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


