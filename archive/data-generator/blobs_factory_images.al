#-----------------------------------------------------------------------------------------------------------------------
# The following demonstrate receiving data from EdgeX against a single topic with multiple types of data, using policies
# function. For the demonstrating we are using both the Random-Integer-Generator01  & Modbus TCP test device. The example
# expects receiving data via MQTT, with params preset by the configuration file when deploying the AnyLog instance.
#
# :process:
#   1. Set parameters
#   2. Add mapping policies to blockchain (if they don't already exist)
#   3. `run msg client` command
#
# :sample data coming in:
#    {
#        "id": "f85b2ddc-761d-88da-c524-12283fbb0f21",
#        "dbms": "ntt",
#        "table": "deeptector",
#        "file_name": "20200306202533614.jpeg",
#        "file_type": "image/jpeg",
#        "file_content": "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD",
#        "detection": [
#                {"class": "kizu", "bbox": [666, 275, 682, 291], "score": 0.83249},
#                {"class": "kizu", "bbox": [669, 262, 684, 277], "score": 0.83249},
#                {"class": "kizu", "bbox": [688, 261, 706,276], "score": 0.72732},
#                {"class": "kizu", "bbox": [698, 277, 713, 292], "score": 0.72659},
#        ],
#        "status": "ok"
#    }
#
# :sample policy:
# {
#   "mapping": {
#       "id": !policy_id,
#       "dbms": "bring [dbms]",
#       "table": "bring [table]",
#       "readings": "detection",
#       "schema": {
#           "timestamp": {
#               "type": "timestamp",
#               "default": "now()"
#           },
#           "file": {
#               "root" : true,
#               "blob" : true,
#               "bring" : "[file_content]",
#               "extension" : "jpeg",
#               "apply" : "base64decoding",
#               "hash" : "md5",
#               "type" : "varchar"
#           },
#           "class": {
#               "type": "string",
#               "bring": "[class]",
#               "default": ""
#           },
#           "bbox": {
#               "type": "string",
#               "bring": "[bbox]",
#               "default": ""
#           },
#           "score": {
#               "type": "float",
#               "bring": "[score]",
#               "default": -1
#           },
#           "status": {
#               "root": true,
#               "type": "string",
#               "bring": "[status]",
#               "default": ""
#           }
#       }
#   }
# }
#
# :documents:
#   - Documentation: https://github.com/AnyLog-co/documentation/blob/master/mapping%20data%20to%20tables.md
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/demo-scripts/blobs_factory_images.al

:preparre-policy:
policy_id = factory-imgs # used also as the mqtt topic name
policy = blockchain get mapping where id = !policy_id
if !policy then goto msg-call

:create-policy:
on error ignore
set new_policy = ""
set policy new_policy [mapping] = {}
set policy new_policy [mapping][id] = !policy_id
set policy new_policy [mapping][dbms] = "bring [dbms]"
set policy new_policy [mapping][table] = "bring [table]"
set policy new_policy [mapping][readings] = "detection"

set policy new_policy [mapping][schema] = {}
set policy new_policy [mapping][schema][timestamp] = {}
set policy new_policy [mapping][schema][timestamp][type] = "timestamp"
set policy new_policy [mapping][schema][timestamp][default] = "now()"

set policy new_policy [mapping][schema][file] = {}
set policy new_policy [mapping][schema][file][root] = true.bool
set policy new_policy [mapping][schema][file][blob] = true.bool
set policy new_policy [mapping][schema][file][bring] = "[file_content]"
set policy new_policy [mapping][schema][file][extension] = "jpeg"
set policy new_policy [mapping][schema][file][hash] = "md5"
set policy new_policy [mapping][schema][file][type] = "varchar"

set policy new_policy [mapping][schema][file][apply] = "base64decoding"
# --- Sample Code for using opencv ---
# set policy new_policy [mapping][schema][file][apply] = "opencv"
# --- Sample Code for using opencv ---

set policy new_policy [mapping][schema][class] = {}
set policy new_policy [mapping][schema][class][type] = "string"
set policy new_policy [mapping][schema][class][bring] = "[class]"
set policy new_policy [mapping][schema][class][default] = ""

set policy new_policy [mapping][schema][bbox] = {}
set policy new_policy [mapping][schema][bbox][type] = "string"
set policy new_policy [mapping][schema][bbox][bring] = "[bbox]"
set policy new_policy [mapping][schema][bbox][default] = ""

set policy new_policy [mapping][schema][score] = {}
set policy new_policy [mapping][schema][score][type] = "float"
set policy new_policy [mapping][schema][score][bring] = "[score]"
set policy new_policy [mapping][schema][score][default] = -1.0

set policy new_policy [mapping][schema][status] = {}
set policy new_policy [mapping][schema][status][type] = "string"
set policy new_policy [mapping][schema][status][bring] = "[bbox]"
set policy new_policy [mapping][schema][status][default] = ""

:test-policy:
test_policy = json !new_policy test
if !test_policy == false then goto test-policy-error

:publish-policy:
process !local_scripts/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error

:msg-call:
if !is_demo == true then goto end-script
on error goto msg-error
if !anylog_broker_port then
<do run msg client where broker=local and port=!anylog_broker_port and log=false and topic=(
    name=!policy_id and
    policy=!policy_id
)>
else if not !anylog_broker_port and !user_name and !user_password then
<do run msg client where broker=rest and port=!anylog_rest_port and user=!user_name and password=!user_password and user-agent=anylog and log=false and topic=(
    name=!policy_id and
    policy=!policy_id
)>
else if not !anylog_broker_port then
<do run msg client where broker=rest and port=!anylog_rest_port and user-agent=anylog and log=false and topic=(
    name=!policy_id and
    policy=!policy_id
)>

:end-script:
end script

:terminate-scripts:
exit scripts

:test-policy-error:
echo "Invalid JSON format, cannot declare policy"
goto end-script

:sign-policy-error:
print "Failed to sign cluster policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member cluster policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare cluster policy on blockchain"
goto terminate-scripts

:policy-error:
print "Failed to publish policy for an unknown reason"
goto terminate-scripts


:msg-error:
echo "Failed to deploy MQTT process"
goto end-script







