#---------------------------------------------------------------------------------------------------------------------#
# The following provides a post-config deployment validation to check whether a node is configured properly.
# it is run outside the config policy because if the config fails, we still want to know what has run / hasn't run
#
# :process:
#   1. define license key
#   2. `get msg client` <-- shows active message clients (operator / publisher)
#   3. `get scheduler` <-- shows active scheduled processes (node monitoring)
#   4. `get scheduled pull` <-- show  docker monitoring
#   5. `get msg rules` <-- shows syslog monitoring (operator / publisher)
#   5. `get processes`
#---------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/node-deployment/status_check.al
on error ignore


:define-license:

process !local_scripts/node-deployment/policies/license_policy.al


:standard-data:

if !node_type != operator and !node_type != publisher then goto check-processes


if $FORCE_DISABLE_ALL != true and !enable_mqtt == true then get msg client
if $FORCE_DISABLE_ALL != true and !docker_monitoring == true then get scheduled pull
if $FORCE_DISABLE_ALL != true and !syslog_monitoring == true then get msg rules

:check-processes:
if $FORCE_DISABLE_ALL != true and !disable_node_monitoring == false then get scheduler

get processes

:end-script:
end script
