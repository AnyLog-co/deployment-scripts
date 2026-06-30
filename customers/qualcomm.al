policy_id = "litmuspolicy"
<combined_policy = {
    "mapping": {
        "id": !policy_id,
        "dbms": "new_company",
        "table": "bring [deviceName] _ [deviceID]",
        "readings": "",
        "schema": {
            "timestamp": {
                "type": "timestamp",
                "default": "now()",
                "bring": "[timestamp]",
                "apply": "epoch_to_datetime"
            },
            "success": {
                "type": "bool",
                "default": false,
                "bring": "[success]"
            },
            "tagName": {
                "type": "string",
                "default": "",
                "bring": "[tagName]"
            },
            "value": {
                "type": "float",
                "default": null,
                "bring": "[value]"
            },
            "description": {
                "type": "string",
                "default": "",
                "bring": "[description]"
            },
            "registerId": {
                "type": "string",
                "default": "",
                "bring": "[registerId]"
            },
            "datatype": {
            "type": "string",
                "default": "",
                "bring": "[datatype]"
            },
            "metadata": {
                "type": "varchar",
                "default": "{}",
                "bring": "[metadata]"
            }
        }
}}>

blockchain insert where policy = !combined_policy and local = true and master = !ledger_conn

<run msg client where broker = local and
  master_node = !ledger_conn and log = false and
  topic = (
    name = litmus and
    policy = !policy_id
  )>