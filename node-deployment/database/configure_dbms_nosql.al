#-----------------------------------------------------------------------------------------------------------------------
# Connect to MongoDB logical database & set blobs archiver
# If params were not set in set_params.al section, then utilize defaults
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/configure_dbms_nosql.al
on error ignore
if !debug_mode == true then set debug on

if !enable_nosql == false then goto blobs-archiver

:connect-dbms:
if !debug_mode == true then print "Deploy blobs database " !default_dbms

on error goto connect-dbms-error
if !nosql_user and !nosql_passwd then
<do connect dbms !default_dbms where
    type=!nosql_type and
    ip=!nosql_ip and
    port=!nosql_port and
    user=!nosql_user and
    password=!nosql_passwd
>
else connect dbms !default_dbms where type=!nosql_type and ip=!nosql_ip and port=!nosql_port

:blobs-archiver:
if !debug_mode == true then print "Enable blobs archiver"

on error call blobs-archiver-error
# if !blobs_dbms == false then set blobs_folder = true
<run blobs archiver where
    dbms=!blobs_dbms and
    folder=!blobs_folder and
    compress=!blobs_compress and
    reuse_blobs=!blobs_reuse
>

:end-script:
end script

:terminate-scripts:
exit scripts


:declare-params-error:
echo "Error: Failed to set a NoSQL parameter"
return

:connect-dbms-error:
echo "Error: Failed to declare " !default_dbms " NoSQL database with database type " !db_type
goto terminate-scripts

:blobs-archiver-error:
echo "Error: Failed to enable blobs archiver"
return
