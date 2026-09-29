#----------------------------------------------------------------------------------------------------------------------#
# Create connection to object storage
# :supported:
#   - Akave
#   - S3
#   - MinIO (?)
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/node-deployment/database/connect_dbms_objstore.al

:set-debug:
if !enable_debug == true then set debug on

:declare-provider:
on error goto declare-provider-error

<connect dbms !default_dbms where
    type = bucket and
    provider = !blob_storage_type and
    access_key = !bucket_access_key and
    secret_key = $bucket_secrete_key and
    region = !bucket_region and
    endpoint = !blob_storage_ip and
    network_id = x123x and
    bucket_name = my-bucket>

<bucket provider connect where
    group = !bucket_group and
    provider =  and
    id = !bucket_id and
    access_key = !bucket_access_key and
    secret_key = ! and
    region = ! and
    endpoint_url = !
>

:assign-logical-name:
on error goto assign-logical-name-error
connect dbms !default_dbms where type = bucket and connection = !bucket_group


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



