#-----------------------------------------------------------------------------------------------------------------------
# Connect to MongoDB logical database & set blobs archiver
# If params were not set in set_params.al section, then utilize defaults
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/database/configure_dbms_nosql.al
on error ignore
if !debug_mode == true then set debug on

if !enable_nosql == false then goto blobs-archiver
if !enable_nosql == true and !nosql_type == akave then
do process !local_scripts/database/configure_dbms_akave.al
do goto end-script

:connect-dbms:
if !debug_mode == true then print "Deploy blobs database " !default_dbms


:blobs-archiver:
if !debug_mode == true then print "Enable blobs archiver"





