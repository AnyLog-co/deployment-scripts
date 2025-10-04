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
# process !local_scripts/policies/license_policy.al

if !is_edgelake == true then goto end-script

:check-policy:
if !debug_mode == true then print "Check whether license policy exists"

activation_key =  blockchain get license bring.last [license][activation_key] "{'company':'"  [license][company] "','expiration':'"  [license][expiration] "','type':'" [license][type] "'}"
if !activation_key then goto set-license
if not !activation_key and not !license_key then goto missing-license-key

:set-params:
on error ignore
if !debug_mode == true then print "set params"
set create_license = false

license_key_num = !license_key[:256]
license_type = from !license_key[256:] bring [type]
expiration = from !license_key[256:] bring [expiration]
owner = from !license_key[256:] bring [company]

:create-license:
if !debug_mode == true then print "Create license policy"
on error ignore
<new_policy = {
    "license": {
        "company": !owner,
        "expiration": !expiration,
        "type": !license_type,
        "activation_key": !license_key_num
    }
}>

:publish-policy:
if !debug_mode == true then print "Declare policy on blockchain"

process !local_scripts/policies/publish_policy.al
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


