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


:define-query-policy:

# if we are looking at a node that's not query, but does fit a certain set of criteria, then define a query policy
# for monitoring purposes
# :criteria:
#   1. system_query enabled
#   2. remote-gui would be running on the same machine
#   3. node_type != query
#   5. is not hidden

if !system_query == true and $REMOTE_GUI == true and !node_type != query and !is_hidden == false then
do set tmp_node_type = !node_type
do set node_type = query
do process !local_scripts/node-deployment/policies/node_policy.al
do set node_type = !tmp_node_type


:end-script:
end script


:system-query-db-error:
echo "Error: Unable to connect to almgm database with db type: " !system_query_db ". Cannot continue"
goto end-script
