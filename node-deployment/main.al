#-----------------------------------------------------------------------------------------------------------------------
# The following is intended to deploy an AnyLog instance based on user configurations
# If !policy_based_networking == true, the deployment is executed in the following way
# Script: !local_scripts/start_node_policy_based.al
#   1. set params
#   2. config node based on node type
#       - set network configs (tcp/port)
#       - blockchain seed
#       - database(s)
#       - policies
#       - support scripts
#-----------------------------------------------------------------------------------------------------------------------
# python3.11 AnyLog-Network/anylog_enterprise/anylog.py process $ANYLOG_PATH/deployment-scripts/node-deployment/main.al
system date

:set-debug:
set enable_debug = false
if      $TRACE_LEVEL and $TRACE_LEVEL == 1 then trace level = 1
else if $TRACE_LEVEL and $TRACE_LEVEL == 2 then trace level = 2
else if $TRACE_LEVEL and $TRACE_LEVEL == 3 then trace level = 3
else if $SCRIPT_DEBUG == true              then
do set enable_debug = true
do set debug on

:disable-auth:
set echo queue on
set authentication off

:is-edgelake:

# check whether we're running EdgeLake or AnyLog
set is_edgelake = false
set release_type = ""
version = get version
deployment_type = python !version.split(" ")[0]

if !deployment_type == AnyLog then release_type = python !version.split("(")[-1].split(")")
if !deployment_type != AnyLog or !release_type == "RTS" then set is_edgelake = true

if !is_edgelake == true and $NODE_TYPE == publisher then goto edgelake-error

:directories:

# directory where deployment-scripts is stored
set anylog_path = /app
if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
else if $EDGELAKE_PATH then set anylog_path = $EDGELAKE_PATH

set anylog home !anylog_path

local_scripts = !anylog_path/deployment-scripts
test_dir = !local_scripts/test
if $LOCAL_SCRIPTS then set local_scripts = $LOCAL_SCRIPTS
if $TEST_DIR then set test_dir = $TEST_DIR

is_dir = file test !local_scripts
if !is_dir == false then
do print "missing local scripts directory": !local_scripts
do goto terminate-scripts

create work directories

:set-params:
# if !is_edgelake == false then  process !local_scripts/node-deployment/authentication/gen_keys.al
process !local_scripts/node-deployment/set_params.al

:set-configs:
on error ignore
process !local_scripts/node-deployment/policies/config_policy.al

:finish-deployment:
if !node_type != generic then
do run blockchain sync
do blockchain reload metadata

get processes

if !enable_mqtt == true then get msg client

:end-script:
on error ignore
if $TRACE_LEVEL and $TRACE_LEVEL.int > 0 then trace level = 0
else if !enable_debug == true then set debug off

system date
end script

:terminate-scripts:
on error ignore

if $TRACE_LEVEL and $TRACE_LEVEL.int > 0 then trace level = 0
else if !enable_debug == true then set debug off

exit scripts

:set-debug-error:
echo "Failed to set enable debug state"
return



:edgelake-error:
print "Node type `publisher` not supported with EdgeLake deployment"
goto terminate-scripts

:license-error:
print "Failed set license"
goto end-script

