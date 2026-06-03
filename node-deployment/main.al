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

:set-debug:
on error call set-debug-error
if $ENABLE_TRACEBACK == true or $ENABLE_TRACEBACK == True or $ENABLE_TRACEBACK == TRUE then
do set exception traceback on
do set debug_mode = true

# replace with with `if $TRACE_LEVEL then trace level = $TRACE_LEVEL` but not currently supported
if $TRACE_LEVEL == 1 then
do trace level = 1
do set debug_mode = true
else if $TRACE_LEVEL == 2 then
do trace level = 1
do set debug_mode = true
else if $TRACE_LEVEL == 3 then
do trace level = 1
do set debug_mode = true


# if $TRACE_LEVEL then trace level = $TRACE_LEVEL
# if $TRACE_LEVEL and !debug_mode == false then do set debug_mode = true

:disable-auth:
set echo queue on
set authentication off

:is-edgelake:

# check whether we're running EdgeLake or AnyLog
set is_edgelake = false
version = get version
deployment_type = python !version.split(" ")[0]
if !deployment_type != AnyLog then set is_edgelake = true
if !is_edgelake == true and $NODE_TYPE == publisher then edgelake-error

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
process !local_scripts/node-deployment/authentication/gen_keys.al
process !local_scripts/node-deployment/set_params.al

:set-configs:
on error ignore
process !local_scripts/node-deployment/policies/config_policy.al

:end-script:

on error ignore
if !debug_mode == true then
do set exception traceback off
do trace level = 0


get processes
if !enable_mqtt == true then get msg client
end script

:set-debug-error:
echo "Failed to set enable debug state"
return

:terminate-scripts:
if $TRACE_LEVEL == 1 or $TRACE_LEVEL == 3 then  trace level = 0
exit scripts


:edgelake-error:
print "Node type `publisher` not supported with EdgeLake deployment"
goto terminate-scripts

:license-error:
print "Failed set license"
goto end-script

