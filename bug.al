<new_policy = {
    "mapping": {
        "id": "my-data", 
        "dbms": !default_dbms,
        "table": "my_data",
        "reading": "",
        "schema: {
            "timestamp": {
                "type": "timestamp",
                "default" "now()",
                "bring": "[timestamp]"
            },
            "str_val": {
                "type": "string",
                "default": "",
                "bring": "[str_val]"
            },
            "val": {
                "type": "float",
                "default" : Null,
                "bring": "[val]"
            }
        }
    }
}>

blockchain insert where policy=!new_policy and local=true and master=!ledger_conn

run msg client where broker=rest and user-agent=anylog and log=false and topic=(name=my-data and policy=my-data)