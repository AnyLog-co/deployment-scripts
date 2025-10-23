#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for almgm logical database
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/configure_dbms_almgm.al

on error ignore
:connect-dbms:
db_name = almgm
process !local_scripts/database/connect_dbms_sql.al

:create-table:
on error goto almgm-table-error
is_table = info table almgm tsd_info exists
if !is_table == false then create table tsd_info where dbms=almgm


:end-script:
end script

:terminate-scripts:
exit scripts


:almgm-table-error:
echo "Error: Failed to create table almgm.tsd_info. Cannot continue"
goto terminate-scripts