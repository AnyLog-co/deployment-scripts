#-----------------------------------------------------------------------------------------------------------------------
# Based on node_type create relevant databases / tables for system_query
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/database/configure_dbms_system_query.al
on error ignore

:set-debug:
if !enable_debug == true then set debug on

:system-query-dbms:
on error goto system-query-db-error
if !system_query_db == sqlite then connect dbms system_query where type=sqlite and memory=!memory
<else if !system_query_db == psql then connect dbms system_query where
    type=!system_query_db and
    user = !db_user and
    password = !db_passwd and
    ip = !db_ip and
    port = !db_port and
    autocommit = !autocommit and
    unlog = !memory>

:end-script:
end script


:system-query-db-error:
echo "Error: Unable to connect to almgm database with db type: " !system_query_db ". Cannot continue"
goto end-script
