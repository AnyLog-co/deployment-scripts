#---------------------------------------------------------------------------------------------------------------------#
# process to initiate viewing video feed and recording insurances
#---------------------------------------------------------------------------------------------------------------------#
# process $DEPLOYMENT_SCRIPTS/deployment-scripts/southbound-video-streaming/video_ai_streams.al

on error ignore

# Check video GRPC directory
is_file = file test !video_grpc_dir
if !is_file == false then goto grpc-error

# Only run detections if enabled
if !enable_detections == true then goto detection-video-streams
goto video-streams

:detection-video-streams:
on error goto video-connect-error
<video connect where
    name = !video_name and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = !default_dbms and
    video_table = video_table and
    detection_dbms = customers and
    detection_table = detection_table and
    detection_column = person and
    detection_column = car and
    detection_column = truck and
    detection_column = bus and
    recording_segment_time = 1 and
    detection_ignore_time = 10
>

on error goto grpc-error
<run grpc client where
    name = yolov5 and
    ip = !ip and
    port = !yolo_model_port and
    grpc_dir = !video_grpc_dir and
    proto = infer and
    function = PredictStream and
    request = "PredictRequest" and
    response = "PredictResponse" and
    service = InferenceService and
    debug = false and
    invoke = true
>

do on error goto video-stream-error
run video stream where name = !video_name and import_display = imshow and grpc_name = yolov5
goto end-script

:video-streams:
on error goto video-stream-error
<video connect where
    name = !video_name and
    protocol = https and
    interface = url and
    address = !video_url and
    video_dbms = !default_dbms
>
run video stream where name = !video_name and import_display = imshow

:end-script:
end script

:grpc-error:
print "ERROR - GRPC client failed"
goto end-script

:video-connect-error:
print "ERROR - Failed to connect video for detection"
goto end-script

:video-stream-error:
print "ERROR - Video stream failed"
goto end-script