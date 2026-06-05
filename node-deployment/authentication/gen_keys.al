#---------------------------------------------------------------------------------------------------------------------#
# define a public / private key to pre-exist on the node by default
# the first 5 chars for the public key are to be used as part of the node name / cluster name if name DNE
#
# :process:
#   1. check if node ID exists
#   2. create node ID (if DNE)
#   3. extract 5 chars from node-id
#---------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/authentication/gen_keys.al

on error ignore
:set-params:
node_password = 123
if $NODE_PASSWORD then node_password = $NODE_PASSWORD
set is_id = false

:check-ids:
node_id = get node id
if !node_id then goto node-info node-info
else if !is_id == true then goto create-id-error

:create-id:
on error goto create-id-error
id create keys for node where password = node_password
set is_id = true
goto check-ids

:node-info:
on error ignore
node_uid = python !node_id[:5]


:end-script:
end script

:create-id-error:
echo "Failed to create public / private key set"
goto end-script
