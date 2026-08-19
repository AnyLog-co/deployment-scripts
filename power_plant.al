set debug interactive

<new_policy = {
    "mapping": {
        "id": "power-plant",
        "readings": "",
        "schema": {
            "timestamp": {
                "type": "timestamp",
                "default": null,
                "bring": "[timestamp]"
            },
            "monitor_id": {
                "type": "string",
                "default": null,
                "bring": "[monitor_id]"
            },
            "a_current": {
                "type": "float",
                "default": null,
                "bring": "[A_Current]"
            },
            "a_n_voltage": {
                "type": "float",
                "default": null,
                "bring": "[A_N_Voltage]"
            },
            "b_current": {
                "type": "float",
                "default": null,
                "bring": "[B_Current]"
            },
            "b_n_voltage": {
                "type": "float",
                "default": null,
                "bring": "[B_N_Voltage]"
            },
            "c_current": {
                "type": "float",
                "default": null,
                "bring": "[C_Current]"
            },
            "c_n_voltage": {
                "type": "float",
                "default": null,
                "bring": "[C_N_Voltage]"
            },
            "comms_status": {
                "type": "bool",
                "default": null,
                "bring": "[CommsStatus]"
            },
            "energy_multiplier": {
                "type": "float",
                "default": null,
                "bring": "[EnergyMultiplier]"
            },
            "frequency": {
                "type": "float",
                "default": null,
                "bring": "[Frequency]"
            },
            "power_factor": {
                "type": "float",
                "default": null,
                "bring": "[PowerFactor]"
            },
            "reactive_power": {
                "type": "float",
                "default": null,
                "bring": "[ReactivePower]"
            },
            "real_power": {
                "type": "float",
                "default": null,
                "bring": "[RealPower]"
            }
        }
    }
}>

process !local_scripts/node-deployment/policies/publish_policy.al


<run msg client where
    broker=172.104.228.251 and port=1883 and
    user=anyloguser and password=mqtt4AnyLog! and
    log=false and topic=(
        name=power-plant and
        dbms=default_dbms and
        table=pp_pm and
        policy="power-plant"
    )>

