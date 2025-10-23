#----------------------------------------------------------------------------------------------------------------------#
# call for connecting to Akave network - everything but logical database is currently hardcoded
#----------------------------------------------------------------------------------------------------------------------#
# proces !local_scripts/database/configure_dbms_akave.al

:declare-provider:
on error goto declare-provider-error
<bucket provider connect where
    group = branch_videos and
    provider = akave and # $BLOB_STORAGE_TYPE
    id = 123 and
    access_key = !akave_access_key and
    secret_key = !akave_secret_key and
    region = akave-network and
    endpoint_url = https://o3-rc3.akave.xyz> # $BLOB_STORAGE_IP

# we need a function to check if bucket has been created
#:create-bucket:
#on error goto create-bucket-error
#bucket create where group = branch_videos and name = deptcounts

:assign-logical-name:
on error goto assign-logical-name-error
connect dbms !default_dbms where type = bucket and connection = branch_videos

:end-script:
end script

:terminate-scripts:
exit scripts


:declare-provider-error:
echo "Error: Failed to declare Akave as the default provider"
goto terminate-scripts

:create-bucket-error:
echo "Error: failed to declare bucket branch_videos.deptcounts"
goto terminate-scripts

:assign-logical-name-error:
echo "Error: Failed to connect to logical database: " !default_dbms
goto terminate-scripts
