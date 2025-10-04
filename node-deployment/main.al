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

if $EXCEPTION_TRACEBACK == true or $EXCEPTION_TRACEBACK == True or $EXCEPTION_TRACEBACK == TRUE then set exception traceback on

:debug-mode:
on error ignore
set debug_mode = false
if $DEBUG_MODE == true or  $DEBUG_MODE == True or $DEBUG_MODE == TRUE then set debug_mode=true
if !debug_mode == true then
do set debug on
do print "Set Script defined configs"
else set debug off

:disable-auth:
set echo queue on
set authentication off

:is-edgelake:
if !debug_mode == true then print "Check whether if an EdgeLake or AnyLog Deployment"

# check whether we're running EdgeLake or AnyLog
set is_edgelake = false
version = get version
deployment_type = python !version.split(" ")[0]
if !deployment_type != AnyLog then set is_edgelake = true
if !is_edgelake == true and $NODE_TYPE == publisher then edgelake-error

:directories:
if !debug_mode == true then print "Set directory paths"

# directory where deployment-scripts is stored
set anylog_path = /app
if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
else if $EDGELAKE_PATH then set anylog_path = $EDGELAKE_PATH

if !debug_mode == true then print "set home path"
set anylog home !anylog_path

local_scripts = !anylog_path/deployment-scripts/node-deployment
test_dir = !anylog_path/deployment-scripts/test
if $LOCAL_SCRIPTS then set local_scripts = $LOCAL_SCRIPTS
if $TEST_DIR then set test_dir = $TEST_DIR

if !debug_mode == true then print "Create work directories"
create work directories

:set-params:
if !debug_mode == true then print "Set environment params"
process !local_scripts/set_params.al


:set-configs:
if !debug_mode == true then print "declare configs"
process !local_scripts/policies/config_policy.al

:end-script:
if !debug_mode == true then print "Validate everything is running as expected"
get processes
if !enable_mqtt == true then get msg client
end script

:edgelake-error:
print "Node type `publisher` not supported with EdgeLake deployment"
goto terminate-scripts

:blockchain-seed-error:
print "Failed to run blockchain seed"
return

:license-error:
print "Failed set license"
goto end-script

