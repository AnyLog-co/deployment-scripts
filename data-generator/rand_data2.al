#--------------------------------------------------------------------------------------------------------------#
# A replication of rand_data.al but using mapping + uns for testing a basic table to test multiple nodes with the same table (for testing)
#
# :Sample Data (published):
# {"timestamp": "2026-04-05T05:23:49.997386", "value": 0.18598355032073355, "dbms": "mydb", "table": "rand_data"}
#--------------------------------------------------------------------------------------------------------------#
# process !local_scripts/data-generator/rand_data2.al

on error ignore
:msg-client:
on error ignore
<run msg client where
    broker=!mqtt_broker and port=!mqtt_port and
    user=!mqtt_user and password=!mqtt_passwd and
    master_node=!ledger_conn and log=false and topic=(
        name=rand-data and
        dbms=!msg_dbms and
        table = "bring [table]" and
        column.timestamp.timestamp = "bring [timestamp]" and
        column.value = (type=float and value="bring [value]") and
        column.node_name = (type=string and value=!node_name) and
        auto_uns=true
    )>


:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign mapping policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare mapping policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare mapping policy on blockchain"
goto terminate-scripts


