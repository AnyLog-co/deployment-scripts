<new_policy = {
    "mapping": {
        "id": "dados",
        "dbms": !default_dbms,
        "table": "ds_data",
        "reading": "",
        "schema": {
            "timestamp": {
                "type": "timestamp",
                "default": "now()",
                "bring": "[timestamp]"
            },
            "snapshot_id": {
                "type": "string",
                "default": null,
                "bring": "[snapshot_id]"
            },
            "seq": {
                "type": "int",
                "default": null,
                "bring": "[seq]"
            },
            "broker": {
                "type": "string",
                "default": null,
                "bring": "[broker]"
            },
            "topic": {
                "type": "string",
                "default": null,
                "bring": "[topic]"
            },
            "metric_name": {
                "type": "string",
                "default": null,
                "bring": "[metric_name]"
            },
            "data_type": {
                "type": "int",
                "default": null,
                "bring": "[data_type]"
            },
            "value_int": {
                "type": "int",
                "default": null,
                "bring": "[value_int]"
            },
            "value_uint": {
                "type": "string",
                "default": null,
                "bring": "[value_uint]"
            },
            "value_double": {
                "type": "float",
                "default": null,
                "bring": "[value_double]"
            },
            "value_bool": {
                "type": "boolean",
                "default": null,
                "bring": "[value_bool]"
            },
            "value_string": {
                "type": "string",
                "default": null,
                "bring": "[value_string]"
            },
            "value_bytes": {
                "type": "string",
                "default": null,
                "bring": "[value_bytes]"
            },
            "alias": {
                "type": "string",
                "default": null,
                "bring": "[alias]"
            }
        }
    }
}>

process !local_scripts/node-deployment/policies/publish_policy.al


run msg client where broker=rest and user-agent=anylog and log=false and topic=(name="spBv1.0/#" and policy=dados)
