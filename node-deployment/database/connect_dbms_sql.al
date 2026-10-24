#-----------------------------------------------------------------------------------------------------------------------
# default script for connecting to logical database
# :supported:
#   - PostgresSQL
#   - SQLite
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/database/connect_dbms_sql.al

:set-debug:
if !enable_debug == true then set debug on

:check-db:
err_code = 0

if not !db_name then
do err_code = 1
do goto end-script

# check isn't needed. 'connect dbms' already returns success when the same db is already connected with the same type, and returns an error if it's connected with a different type 
#list_dbs = get databases where format=json
#if !list_dbs contains !db_name then goto end-script

:connect:
on error goto connect-error
<if !db_type == psql then connect dbms !db_name where
    type=!db_type and
    user = !db_user and
    password = !db_passwd and
    ip = !db_ip and
    port = !db_port>
else connect dbms !db_name where type=!db_type


:end-script:
end script

:terminate-scripts:
exit scripts


:connect-error:
echo "Error: Unable to connect to " + !db_name + " database with db type: " + !db_type + ". Cannot continue"
goto terminate-scripts
