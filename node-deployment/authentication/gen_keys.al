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
auth_password = 123
if $AUTH_PASSWORD then auth_password=$AUTH_PASSWORD
node_id = get node id

if !node_id then goto node-info

:check-is-file:
is_file = test file

:create-id:
on error goto create-id-error
id create keys for node where password = auth_password

:node-info:
on error ignore
node_id = get node id
node_uid = python !node_id[:5]


:end-script:
end script

:create-id-error:
echo "Failed to create public / private key set"
goto end-script
