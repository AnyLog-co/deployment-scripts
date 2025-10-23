#-----------------------------------------------------------------------------------------------------------------------
# default script for connecting to logical database
# :supported:
#   - PostgresSQL
#   - SQLite
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/connect_dbms_sql.al

:check-db:
err_code = 0

if not !db_name then
do err_code = 1
do goto end-script

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


:almgm-dbms-error:
echo "Error: Unable to connect to " + !db_name + " database with db type: " + !db_type + ". Cannot continue"
goto terminate-scripts
