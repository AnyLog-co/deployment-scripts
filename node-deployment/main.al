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

if $DEBUG_MODE.int != 0 then set debug on

:set-configs:
on error ignore
set debug off
set echo queue on
set authentication off

:is-edgelake:
if $DEBUG_MODE.int == 2 then
do set debug interactive
do print "Check whether if an EdgeLake or AnyLog Deployment"
do set debug on

# check whether we're running EdgeLake or AnyLog
set is_edgelake = false
version = get version
deployment_type = python !version.split(" ")[0]
if !deployment_type != AnyLog then set is_edgelake = true
if !is_edgelake == true and $NODE_TYPE == publisher then edgelake-error

:directories:
if $DEBUG_MODE.int == 2 then
do set debug interactive
do print "Set directory paths"
do set debug on

# directory where deployment-scripts is stored
set anylog_path = /app
if $ANYLOG_PATH then set anylog_path = $ANYLOG_PATH
else if $EDGELAKE_PATH then set anylog_path = $EDGELAKE_PATH
set anylog home !anylog_path
set local_scripts = !anylog_path/deployment-scripts/node-deployment
set test_dir = !anylog_path/deployment-scripts/test

if $DEBUG_MODE.int == 2 then
do set debug interactive
do print "Create work directories"
do set debug on
create work directories

:set-params:
if $DEBUG_MODE.int == 2 then
do set debug interactive
do print "Set environment params"
do set debug on
process !local_scripts/set_params.al

:configure-networking:
if $DEBUG_MODE.int == 2 then
do set debug interactive
do print "Configure networking"
do set debug on
if $DEBUG_MODE.int == 2 then thread !local_scripts/connect_networking.al
else process !local_scripts/connect_networking.al

:is-generic:
if !node_type == generic then goto set-license

:blockchain-seed:
if $DEBUG_MODE.int == 2 and !node_type != master then
do set debug interactive
do print "Copy blockchain to local node"
do set debug on

on error call blockchain-seed-error
if !node_type != master then blockchain seed from !ledger_conn

:declare-policy:
if $DEBUG_MODE.int == 2 then
do set debug interactive
do print "Declare policies"
do set debug on

on error ignore
if $DEBUG_MODE.int == 2 then thread !local_scripts/policies/config_policy.al
else process !local_scripts/policies/config_policy.al

:set-license:
if $DEBUG_MODE.int == 2 and !is_edgelake == false then
do set debug interactive
do print "Validate license key exists (if AnyLog) and set license key"

on error ignore
if !is_edgelake == true then goto end-script
else if not !license_key then license_key = blockchain get master bring [*][license]

if not !license_key then goto license-error
set license where activation_key = !license_key

:end-script:
print "Validate everything is running as expected"
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

