#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for operator node
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/database/configure_dbms_operator.al

on error ignore
:connect-dbms:
if not !default_dbms then goto connect-dbms-error
db_name = !default_dbms
process !local_scripts/node-deployment/database/connect_dbms_sql.al

:data-partitioning:
if !enable_partitions == true then
do on error goto partitioning-error
do partition !default_dbms !table_name using !partition_column by !partition_interval
<do schedule time=!partition_sync and name="Drop Partitions"
    task drop partition where dbms=!default_dbms and table =!table_name and keep=!partition_keep>
schedule name=remove_archive and time=1 day and task delete archive where days = !archive_delete

:worker-threads:
on error call worker-thread-err

if !operator_helpers and !operator_helpers.int >= 1 and !node_type == operator and !db_type == psql then
do run helpers where type = psql and count = !operator_helpers.int

:end-script:
end script

:terminate-scripts:
exit scripts

:connect-dbms-error:
echo "Missing logical database - connect continue"
goto terminate-scripts

:partitioning-error;
echo "Failed to set partitions for logical database: " + !default_dbms + " - data will stored in a single table"
goto end-script

:worker-thread-err:
echo "Failed to define worker threads for data insertion"
goto end-script