<node_policy = {
    "publisher": {
        "name": !node_name,
        "ip": !external_ip,
        "local_ip": !ip,
        "port": !anylog_server_port,
        "rest_port": !anylog_rest_port
    }
}>

<config_policy = {
  "config": {
      "id": "blockchain-node",
      "node_type": "publisher",
      "ip": "'!external_ip'",
      "local_ip": "'!ip'",
      "port": "'!anylog_server_port'",
      "rest_port": "'!anylog_rest_port'",
      "scripts": [
          "if !db_type == sqlite then connect dbms blockchain where type=sqlite",
          "if !db_type == psql   then connect dbms blockchain where type=psql and ip=!db_ip and port=!db_port and user=!db_user and password=!db_passwd",
          "create table ledger where dbms=blockchain",
          "if !system_query_db == sqlite and !system_query == true and !memory == true then connect dbms system_query where type=sqlite and memory=!memory",
          "if !system_query_db == psql and !system_query == true and !memory == true then connect dbms system_query where ip=!db_ip and port=!db_port and user=!db_user and password=!db_passwd and unlog=!memory",
          "run blockchain sync where source=!blockchain_source and time=!blockchain_sync and dest=!blockchain_destination and connection=!ledger_conn",
          "run scheduler 1",
          "is_policy = blockchain get master where name=!node_name",
          "if not !is_policy then blockchain insert where policy=!node_policy and local=true and master=!ledger_conn",
          "set buffer threshold where time=!threshold_time and volume=!threshold_volume and write_immediate=false",
          "run streamer",
          "run publisher where archive_json=true and compress_json=!compress_file and compress_sql=!compress_file and dbms_name=!dbms_file_location and table_name=!table_file_location"
      ]
  }
}

blockchain insert where policy = !config_policy and local=true and master = !ledger_conn
