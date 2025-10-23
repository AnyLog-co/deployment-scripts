#----------------------------------------------------------------------------------------------------------------------#
# Create connection to NoSQL database
# :supported:
#   - MongoDB
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/database/connect_dbms_nosql.al

if not !blob_storage_ip or not !blob_storage_port then goto missing-conn-info

on error goto connect-dbms-error
if !nosql_user and !nosql_passwd then
<do connect dbms !default_dbms where
    type=!blob_storage_type and
    ip=!blob_storage_ip and
    port=!blob_storage_port and
    user=!blob_storage_user and
    password=!blob_storage_password
>
else connect dbms !default_dbms where type=!blob_storage_type and ip=!blob_storage_ip and port=!blob_storage_port

:end-script:
end script

:terminate-scripts:
exit scripts

:missing-conn-info:
echo "Error: Missing IP or Port for connecting to " + !blob_storage_type + " database"
goto terminate-scripts

:connect-dbms-error:
echo "Error: Failed to declare " !default_dbms " NoSQL database with database type " !db_type
goto terminate-scripts
