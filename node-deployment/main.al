#-----------------------------------------------------------------------------------------------------------------------
# The following is intended to deploy an AnyLog instance based on user configurations
# If !policy_based_networking == true, the deployment is executed in the following way
# Script: !local_scripts/start_node_policy_based.al
#   1. set params
#   2. run tcp server
#   3. blockchain seed
#   4. config node based on node type - if node type is generic then "stop"
#-----------------------------------------------------------------------------------------------------------------------
# python3.10 AnyLog-Network/anylog_enterprise/anylog.py process $ANYLOG_PATH/deployment-scripts/node-deployment/main.al

:debug-mode:
on error ignore
if $DEBUG_MODE.int > 0 and $DEBUG_MODE < 3 then print "Set Script defined configs"
set debug_mode = 0
if $DEBUG_MODE then set debug_mode=$DEBUG_MODE
if !debug_mode.int == 1 then set debug on
else if !debug_mode.int == 2 then set debug interactive
else if !debug_mode.int > 2 then debug_mode=0

:set-configs:
set debug off
set echo queue on
#set authentication off

:is-edgelake:
if !debug_mode.int > 0 then do print "Check whether if an EdgeLake or AnyLog Deployment"

# check whether we're running EdgeLake or AnyLog
set is_edgelake = false
version = get version
deployment_type = python !version.split(" ")[0]
if !deployment_type != AnyLog then set is_edgelake = true
if !is_edgelake == true and $NODE_TYPE == publisher then edgelake-error

:directories:
if !debug_mode.int > 0 then print "Set directory paths"

# directory where deployment-scripts is stored
set anylog_path = /app
local_scripts = !anylog_path/deployment-scripts/node-deployment
test_dir = !anylog_path/deployment-scripts/test

if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
else if $EDGELAKE_PATH then set anylog_path = $EDGELAKE_PATH
if $LOCAL_SCRIPTS then set local_scripts = $LOCAL_SCRIPTS
if $TEST_DIR then set test_dir = $TEST_DIR


if !debug_mode.int > 0 then print "Create work directories"
create work directories

:set-params:
if !debug_mode.int > 0 then print "Set environment params"
process !local_scripts/set_params.al

:configure-networking:
if !debug_mode.int == 1 then print "Configure networking"
do process !local_scripts/connect_networking.al
if !debug_mode.int == 2 then thread !local_scripts/connect_networking.al
else do print "Connect networking"
do process !local_scripts/connect_networking.al

:blockchain-seed:
if !debug_mode.int == 1 then print "Blockchain Seed"
do blockchain seed from !ledger_conn
if !node_type == generic then goto set-license
else if !node_type != master and !blockchain_source != master then process !local_scripts/connect_blockchain.al
else if !node_type != master then
do on error call blockchain-seed-error
do blockchain seed from !ledger_conn
do on error ignore

:declare-policy:
if !debug_mode.int == 1 then print "Declare policies"
do process !local_scripts/policies/config_policy.al
if !debug_mode.int == 2 then thread !local_scripts/policies/config_policy.al
else do process !local_scripts/policies/config_policy.al

:set-license:
if !debug_mode.int > 0  then print "Set license key"

if !is_edgelake == true then goto end-script

if not !license_key then license_key = blockchain get master bring [*][license]
if not !license_key then goto license-error
set license where activation_key = !license_key

:end-script:
if !debug_mode.int > 0 then print "Validate everything is running as expected"
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

