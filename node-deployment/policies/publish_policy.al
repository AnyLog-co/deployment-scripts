#-----------------------------------------------------------------------------------------------------------------------
# generic process to declare policy on blockchain (using node key)
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/policies/publish_policy.al
on error ignore

:set-params:
error_code = 0

:private-key:

if !enable_auth == true and not !node_private_key then
do on error ignore
do node_private_key = get private key where keys_file = !key_name
do if not !node_private_key then goto private-key-error

:prepare-policy:

on error goto sign-policy-error
if !enable_auth == true then new_policy = id sign !new_policy where key = !node_private_key and password = !node_password
validate_policy = json !new_policy
if not !validate_policy then goto prepare-policy-error

:declare-policy:

on error call declare-policy-error
blockchain prepare policy !new_policy

policy_type = from !new_policy  bring [*]
if !policy_type == config or !master_configs == true then
do blockchain insert where policy=!new_policy and local=true
do config_policy = !new_policy
else blockchain insert where policy=!new_policy and local=true and master=!ledger_conn

:end-script:
end script

:private-key-error:
echo "Failed to get private key from generated node key"
goto end-script

:sign-policy-error:
# error code 1 - failed to sign policy
error_code = 1

:prepare-policy-error:
# error code 2 - policy is not in the correct format
error_code = 2

:declare-policy-error:
# error code 3 - failed to publish policy on the blockchain
error_code = 3
