#-----------------------------------------------------------------------------------------------------------------------
# Script to deploy a policy with license information
#
# ---- Sample Policy ---
# {'license' : {
#       'owner' : 'AnyLogCo.',
#       'company' : 'AnyLog Co.',
#       "expiration": "2025-03-01",
#       "type": "beta",
#       "activation_key": "af043d39675e85e5c9d74999dfd123de2e54e6ed4f1fe9bed04b8ce7754826c89aa1adfb562b18d49f7c4a336ece
#                          dadb3c3ca43f88a7d3f4644b6424c5f6ba9217bede0bbcdc94094af9f6e213aa247ccb3ed5f77b794f68df07a6255
#                          2ac0c6d9c67e406fe6213d6145d7c3d2c127e99906dffebd1c34c12b259719d80e6fcb3",
#       'id' : '0015392622f3eaac70eafa4311fc2338',
#       'date' : '2022-06-04T22:47:48.479532Z',
#       'status' : 'active',
#       'ledger' : 'global'
# }}
# ---- Sample Policy ---
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/policies/license_policy.al

:set-debug:
if !enable_debug == true then set debug on

:is-edgelake
if !is_edgelake == true then goto end-script

:check-policy:
on error ignore
is_blockchain_license = blockchain get license bring.last
if not !is_blockchain_license then goto set-params

# --- license exists on the blockchain: rebuild the activation key from its fields ---
key_num      = from !is_blockchain_license bring [*][activation_key]
company      = from !is_blockchain_license bring [*][company]
expiration   = from !is_blockchain_license bring [*][expiration]
license_type = from !is_blockchain_license bring [*][type]
max_nodes    = from !is_blockchain_license bring [*][max_nodes]

if not !key_num then goto missing-license-key
if not !max_nodes then set max_nodes = 0         # older licenses without max_nodes

license_info = {"company": !company, "expiration": !expiration, "type": !license_type, "max_nodes": !max_nodes.int}
serialized_json_info  = json !license_info
activation_key = !key_num + !serialized_json_info

if !activation_key then goto set-license
goto missing-license-key

:set-params:
on error ignore
set create_license = false

license_key_num = $LICENSE_KEY[:256]
license_type = from $LICENSE_KEY[256:] bring [type]
expiration = from $LICENSE_KEY[256:] bring [expiration]
owner = from $LICENSE_KEY[256:] bring [company]
max_nodes = from $LICENSE_KEY[256:]  bring [max_nodes]

:create-license:
on error ignore
<new_policy = {
    "license": {
        "company": !owner,
        "expiration": !expiration,
        "type": !license_type,
        "activation_key": !license_key_num,
        "max_nodes": !max_nodes.int
    }
}>

:publish-policy:

process !local_scripts/node-deployment/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_cluster = true

goto check-policy

:set-license:
on error goto set-license-error
set license where activation_key = !activation_key

:end-script:
end script

:terminate-scripts:
exit scripts

:missing-license-key:
print "missing license key, cannot create policy / activate node"
goto terminate-scripts

:expiration-error:
print "License key expiration date is older them today, cannot create policy / activate node"
goto terminate-scripts

:sign-policy-error:
print "Failed to sign cluster policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member cluster policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare cluster policy on blockchain"
goto terminate-scripts

:set-license-error:
print "Failed to active node using the license key"
goto terminate-scripts

:policy-error:
print "Failed to publish policy for an unknown reason"
goto terminate-scripts


