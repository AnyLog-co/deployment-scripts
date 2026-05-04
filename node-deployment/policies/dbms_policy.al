<new_policy = {
    "config": {
        "id": "conn-dbms",
        "script": [
            "if !node_type == master and !db_type == sqlite then connect dbms blockchain where type=sqlite",
            "if !node_type == master and !db_type == psql   then connect dbms blockchain where type=psql and user = !db_user and password = !db_passwd and ip = !db_ip and port = !db_port",
            "if !node_type == query or !system_query == true and !db_type == sqlite then connect
        ]
    }
}>