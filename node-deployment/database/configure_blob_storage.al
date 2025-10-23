#----------------------------------------------------------------------------------------------------------------------#
# The following validates configuration options and calls corresponding connection scripts. Once done it enables archiver
#----------------------------------------------------------------------------------------------------------------------#
on error ignore

:validate-process:
if !blobs_storage == true and not !blob_storage_type then goto missing-storage-type
if !blobs_storage == false and !blobs_folder == true then goto blobs-archiver
else if !blobs_storage == false and !blobs_folder == false then goto end-script


:connect-blob-storage:
if !blobs_storage == true and !blob_storage_type == mongo then goto !local_scripts/database/connect_dbms_mongo.al
if !blobs_storage == true and (!blobs_storage_type == akave or !blobs_storage_type == s3) then goto !local_scripts/database/connect_dbms_bucket.al

:blobs-archiver:
#----------------------------------------------------------------------------------------------------------------------#
# `run blobs archiver` is how AnyLog / EdgeLake configures storing blobs into database and/or file.
# - if !blobs_storage is True then it'll store to nosql database (ex. mongo, s3, akave)
# - if !blobs_folder is True then it'll store to file (blobs_dir/)
#
# The 2 options are independent of one another
#----------------------------------------------------------------------------------------------------------------------#
on error call blobs-archiver-error
<run blobs archiver where
    dbms=!blobs_storage and
    folder=!blobs_folder and
    compress=!blobs_compress and
    reuse_blobs=!blobs_reuse
>

:end-script:
end script

:terminate-scripts:
exit scripts

:missing-storage-type:
echo "Warning: missing blobs storage type - blobs will be stored in local file"
goto blobs-archiver

:blobs-archiver-error:
echo "Error: Failed to enable blobs archiver"
goto terminate-scripts