#----------------------------------------------------------------------------------------------------------------------#
# Sample mapping for Sparkplug based on the
#----------------------------------------------------------------------------------------------------------------------#

policy_id = "sparkplug-mapping"

set create_policy = false

:check-policy:
is_policy = blockchain get (mapping, transform) where id = !policy_id
if not !is_policy and !create_policy == false then goto declare-policy
else if !is_policy then goto end-script
else if not !is_policy and !create_policy == true then goto declare-policy-error


:declare-policy:
set policy new_policy [mapping] = {}
set policy new_policy [mapping][id] = !policy_id
set policy new_policy [mapping][dbms] = '!default_dbms'
if !sparkplug_dynamic == true then set policy new_policy [mapping][dynamic] = true
else set policy new_policy [mapping][table] = "sparkplug"

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
    },
    "cur_mach_speed": {
        "type": "float",
        "default": null,
        "bring": "[Status/CurMachSpeed]",
        "optional": true
    }
}>