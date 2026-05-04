<mapping_policy = {
    "mapping": {
        "id": "data1",
        "dbms": "litmus",
        "table": "bring [deviceName]",
        "readings": "",
        "schema": {
            "timestamp" : {
                "bring": "[timestamp]",
                "default" : "now()",
                "type" : "timestamp",
                "apply" :  "epoch_to_datetime"
            },
            "success": {
                "bring": "[success]",
                "type": "bool",
                "default": Null
            },
            "device_id": {
                "bring": "[deviceID]",
                "type": "string",
                "default": Null
            },
            "value": {
                "bring": "[value]",
                "type": "float",
                "default": Null
            }
        }
    }
}>

blockchain insert where policy = !mapping_policy and local=true

<run msg client where broker = local and log=false and topic = (
    name=data1 and
    policy = data1
)>