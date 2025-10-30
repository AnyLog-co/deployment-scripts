#-----------------------------------------------------------------------------------------------------------------------
# Monitoring logical database
# - partition by 12 hours
# - database keeps 36 hours of data
# - file storage keeps 3 days of data
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/configure_dbms_operator.al

on error ignore
:connect-dbms:
db_name = monitoring
process !local_scripts/database/connect_dbms_sql.al

:data-partitioning:
if !debug_mode == true then print "Set Partitioning"
if !enable_partitions == true then
do on error goto partitioning-error
do partition !default_dbms * using insert_timestamp by 12 hours
<do schedule time=12 hours and name="Monitoring - Drop Partitions"
    task drop partition where dbms=monitoring and table="*" and keep=3>

# schedule name=remove_archive and time=1 day and task delete archive where days = 3


:end-script:
end script

:terminate-scripts:
exit scripts

:partitioning-error;
echo "Failed to set partitions for logical database: " + !default_dbms + " - data will stored in a single table"
goto end-script

