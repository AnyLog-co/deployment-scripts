#-----------------------------------------------------------------------------------------------------------------#
# Configuration policy related to industrial data sources
#-----------------------------------------------------------------------------------------------------------------#
# process !local_scripts/policies/southbound_industrial_policies.al

on error ignore
set create_config = false

:get-monitoring-config:
on error ignore
is_policy = blockchain get config where id = industrial-config
if !is_policy then goto config-policy
if not !is_policy and !create_config == true then goto declare-policy-error

:industrial-config:
<new_policy = {
    "config": {
        "name": "industrial southbound sources",
        "id": "industrial-config",
        "script": [
            "if !enable_mqtt == true then process !local_scripts/sample-scripts/basic_msg_client.al",
            "if !enable_opcua == true and !set_opcua_tags == true then process !local_scripts/southbound-industrial/opcua_tags.al",
            "if !enable_opcua == true and !set_opcua_tags == false then process !local_scripts/southbound-industrial/opcua_client.al",
            "if !enable_etherip == true and !set_ether_tags == true then process !local_scripts/southbound-industrial/etherip_tags.al",
            "if !enable_etherip == true and !set_ether_tags == false then process !local_scripts/southbound-industrial/etherip_client.al",
        ]
    }
}>

:publish-policy:
set is_config = true
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_config = true
wait 5
blockchain reload metadata
set is_config = false
goto get-monitoring-config

:publish-policy:
set is_config = true
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_config = true
wait 5
blockchain reload metadata
set is_config = false
goto check-policy

:config-policy:
on error goto config-policy-error
config from policy where id = !config_id

:end-script:
end script

:sign-policy-error:
print "Failed to sign config policy"
goto end-script

:prepare-policy-error:
print "Failed to prepare member config policy for publishing on blockchain"
goto end-script

:declare-policy-error:
print "Failed to declare config policy on blockchain"
goto end-script

:config-policy-error:
print "Failed to execute config policy"
goto end-script
