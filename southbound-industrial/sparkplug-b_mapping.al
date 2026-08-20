#----------------------------------------------------------------------------------------------------------------------#
# Sample mapping for Sparkplug based on the
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/southbound-industrial/sparkplug-b_mapping.al

sparkplug_mapping_id = "sparkplug-mapping"

set create_policy = false

:check-policy:
is_policy = blockchain get (mapping, transform) where id = !sparkplug_mapping_id
if not !is_policy and !create_policy == false then goto declare-policy
else if !is_policy then goto end-script
else if not !is_policy and !create_policy == true then goto declare-policy-error


:declare-policy:
set new_policy = {}
set policy new_policy [mapping] = {}
set policy new_policy [mapping][id] = !sparkplug_mapping_id
set policy new_policy [mapping][dbms] = !default_dbms
# if !sparkplug_dynamic == true then set policy new_policy [mapping][dynamic] = true
# set policy new_policy [mapping][table] = "sparkplug"

set policy new_policy [mapping][readings] = ""
<set policy new_policy [mapping][schema] =  {
    "timestamp": {
        "type" : "timestamp",
        "default": "now()",
        "bring" : "[timestamp]",
        "apply" :  "epoch_to_datetime"
    },
    "group_id": {
        "type": "string",
        "default": null,
        "bring": "[group_id]"
    },
    "edge": {
        "type": "string",
        "default": null,
        "bring": "[edge_node_id]"
    },
    "device": {
        "type": "string",
        "default": null,
        "bring": "[device_id]"
    },
    "msg_type": {
        "type": "string",
        "default": null,
        "bring": "[message_type]"
    },
    "mach_design_speed": {
        "type": "float",
        "default": null,
        "bring": "[Admin/MachDesignSpeed]",
        "optional": true
    },
    "consumed": {
        "type": "float",
        "default": null,
        "bring": "[Admin/ProdConsumedCount/0/Count]",
        "optional": true
    },
    "defective": {
        "type": "float",
        "default": null,
        "bring": "[Admin/ProdDefectiveCount/0/Count]",
        "optional": true
    },
    "processed": {
        "type": "float",
        "default": null,
        "bring": "[Admin/ProdProcessedCount/0/Count]",
        "optional": true
    },
    "mach_speed": {
        "type": "float",
        "default": null,
        "bring": "[Status/MachSpeed]",
        "optional": true
    },
    "cur_mach_speed": {
        "type": "float",
        "default": null,
        "bring": "[Status/CurMachSpeed]",
        "optional": true
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
