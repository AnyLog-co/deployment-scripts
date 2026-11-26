#---------------------------------------------------------------------------------------------------------------------#
# define a public / private key to pre-exist on the node by default
#
# :process:
#   1. check if node ID exists
#   2. create node ID (if DNE)
#---------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/node-deployment/authentication/gen_keys.al

on error ignore

:set-debug:
if !enable_debug == true then set debug on

:set-params:
node_password = 123
if $NODE_PASSWORD then node_password = $NODE_PASSWORD
set is_id = false

:check-ids:
node_id = get node id
if !node_id then goto end-script
else if not !node_id and !is_id == true then goto create-id-error


:create-id:
on error goto create-id-error
id create keys for node where password = !node_password
set is_id = true
goto check-ids

:end-script:
end script

:create-id-error:
echo "Failed to create public / private key set"
goto end-script
