<query_policy = {
    "master": {
        "name": !node_name,
        "ip": !external_ip,
        "local_ip": !ip,
        "port": !anylog_server_port,
        "rest_port": !anylog_rest_port
    }
}>

{
  "config": {
      "node_type": "query",
      "ip": "'!external_ip'",
      "local_ip": "'!ip'",
      "port": "'!anylog_server_port'",
      "rest_port": "'!anylog_rest_port'",
      "scripts": [
          "if !system_query_db == sqlite then connect dbms system_query where type=sqlite and memory=!memory",
          "if !system_query_db == psql   then connect dbms system_query where ip=!db_ip and port=!db_port and user=!db_user and password=!db_passwd and unlog=!memory",
          "run blockchain sync where source=!blockchain_source and time=!blockchain_sync and dest=!blockchain_destination and connection=!ledger_conn",
          "is_policy = blockchain get master where name=!node_name",
          "if not !is_policy then blockchain insert where policy=!master_policy and local=true and master=!ledger_conn",
      ]
  }
}

