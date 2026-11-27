#---------------------------------------------------------------------------------------------------------------------#
# AnyLog scripts used for demo for blobs data
#---------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/test-network-local-scripts/blobs_demo.al
on error ignore

:declare-params:
set is_demo = true
car_policy = car-videos
factory_policy = factory-imgs
people_policy = people-videos

:declare-policies:
process !local_scripts/data-generator/blobs_car_videos.al
process !local_scripts/data-generator/blobs_factory_images.al
process !local_scripts/data-generator/blobs_people_videos.al

:msg-client:
on error call msg-client-error
if !anylog_broker_port then
<do run msg client where broker=local and port=!anylog_broker_port and log=false and topic=(
    name=!car_policy and
    policy=!car_policy
) and topic = (
    name=!factory_policy and
    policy=!factory_policy
) and topic =(
    name=!people_policy and
    policy=!people_policy
)>
if not !anylog_broker_port and !user_name and !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user=!user_name and password=!user_password and user-agent=anylog and log=false and topic=(
    name=!car_policy and
    policy=!car_policy
) and topic = (
    name=!factory_policy and
    policy=!factory_policy
) and topic =(
    name=!people_policy and
    policy=!people_policy
)>
if not !anylog_broker_port then
<do run msg client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and topic=(
    name=!car_policy and
    policy=!car_policy
) and topic = (
    name=!factory_policy and
    policy=!factory_policy
) and topic =(
    name=!people_policy and
    policy=!people_policy
)>

:end-script: 
end script

:msg-client-error:
echo "Failed to declare message client process" 
goto end-script
