#-----------------------------------------------------------------------------------------------------------------------
# Declare a generic publisher node policy
#   -> connect to TCP and REST (both not binded)
#   -> run blockchain sync
#   -> create almgm + tsd_info
#   -> prepare for deployment
#   -> execute `run publisher`
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/generic_scripts/generic_publisher_policy.al

<new_policy = {
    "config": {
        "id": "generic-publisher-policy",
        "node_type": "publisher",
        "ip": '!external_ip',
        "local_ip": '!ip',
        "port": '!anylog_server_port.int',
        "rest_port": '!anylog_rest_port.int',
        "scripts": [
            "set node name !node_name",
            "run scheduler 1",
            "run blockchain sync where source=master and time=30 seconds and dest=file and connection=!ledger_conn",
            "connect dbms !default_dbms where type=sqlite",
            "connect dbms almgm where dbms=sqlite",
            "create table tsd_info where dbms=sqlite",
            "partition !default_dbms * using insert_timestamp by day",
            "schedule time=1 day and name="Drop Partitions" task drop partition where dbms=!default_dbms and table=* and keep=3",
            "set buffer threshold where time=60 seconds and volume=10KB and write_immediate=true",
            "run streamer",
            "run publisher where compress_json=true and compress_sql=true and master_node=!ledger_conn and dbms_name=0 and table_name=1"
        ]
}}>

process !local_scripts/generic_scripts/publish_policy.al
if error_code == 1 then goto sign-policy-error
if error_code == 2 then goto prepare-policy-error
if error_code == 3 then declare-policy-error

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
echo "Failed to sign cluster policy"
goto terminate-scripts

:prepare-policy-error:
echo "Failed to prepare member cluster policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
echo "Failed to declare cluster policy on blockchain"
goto terminate-scripts