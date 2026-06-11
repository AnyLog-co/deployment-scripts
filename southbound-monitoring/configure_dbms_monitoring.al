#-----------------------------------------------------------------------------------------------------------------------
# Monitoring logical database
# - partition by 12 hours
# - database keeps 36 hours of data
# - file storage keeps 3 days of data
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/southbound-monitoring/configure_dbms_monitoring.al

on error ignore

if !node_monitoring == false and !syslog_monitoring == false and !docker_monitoring == false then goto end-script

:connect-dbms:
db_name = monitoring

:check-db:
err_code = 0

if not !db_name then
do err_code = 1
do goto end-script

list_dbs = get databases where format=json
if !list_dbs contains !db_name then goto data-partitioning

:connect:
on error goto connect-error
<if !monitoring_db == psql then connect dbms !db_name where
    type=!monitoring_db and
    user = !db_user and
    password = !db_passwd and
    ip = !db_ip and
    port = !db_port>
else connect dbms !db_name where type=!monitoring_db

:data-partitioning:
if !enable_partitions == true then
do on error goto partitioning-error
do partition monitoring * using insert_timestamp by 12 hours
<do schedule time=12 hours and name="Monitoring - Drop Partitions"
    task drop partition where dbms=monitoring and table="*" and keep=3>

# schedule name=remove_archive and time=1 day and task delete archive where days = 3

set db_name = ""

:end-script:
end script

:terminate-scripts:
exit scripts

:connect-error:
echo "Error: Unable to connect to " + !db_name + " database with db type: " + !db_type + ". Cannot continue"
goto terminate-scripts

:partitioning-error;
echo "Failed to set partitions for logical database: " + !default_dbms + " - data will stored in a single table"
goto end-script
