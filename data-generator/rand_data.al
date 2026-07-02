#--------------------------------------------------------------------------------------------------------------#
# Hardcoded call to the data generator for random data
#
# :Sample Data (published):
# {"timestamp": "2026-04-05T05:23:49.997386", "value": 0.18598355032073355, "dbms": "mydb", "table": "rand_data"}
#--------------------------------------------------------------------------------------------------------------#
# process !local_scripts/data-generator/rand_data.al

on error ignore

<run msg client where
    broker=!mqtt_broker and port=!mqtt_port and
    user=!mqtt_user and password=!mqtt_passwd and
    log=false and topic=(
        name=rand-data and
        dbms=!msg_dbms and
        table = "bring [table]" and
        column.timestamp.timestamp = "bring [timestamp]" and
        column.value = (type=float and value="bring [value]")
    )>

get msg client

:end-script:
end script