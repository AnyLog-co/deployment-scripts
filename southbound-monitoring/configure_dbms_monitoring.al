#-----------------------------------------------------------------------------------------------------------------------
# Monitoring logical database
# - partition by 12 hours
# - database keeps 36 hours of data
# - file storage keeps 3 days of data
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/southbound-monitoring/configure_dbms_operator.al

on error ignore

if !node_monitoring == false and !syslog_monitoring == false and !docker_monitoring == false then goto end-script

:connect-dbms:
db_name = monitoring
process !local_scripts/node-deployment/database/connect_dbms_sql.al
# connect dbms !db_name where type=sqlite

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

:partitioning-error;
echo "Failed to set partitions for logical database: " + !default_dbms + " - data will stored in a single table"
goto end-script

