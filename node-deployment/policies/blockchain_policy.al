:set-debug:
if !enable_debug == true then set debug on

set create_policy = false

:check-policy:

on error ignore
is_policy = blockchain get blockchain-info where company=!company_name and public_key=!blockchain_public_key and chain_id=!chain_id
if !is_policy then goto end-script
else if not !is_policy and !create_policy == true then goto declare-policy-error

:prep-policy:

on error ignore
<new_policy = {
    "blockchain-info": {
        "name": "blockchain info",
        "company": !company_name,
        "public_key": !blockchain_public_key,
        "chain_id": !chain_id,
        "contract": !contract
}}>

:publish-policy:
set debug on
process !local_scripts/node-deployment/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
set debug off
goto check-policy

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign blockchain info policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member blockchain info policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare blockchain info policy on blockchain"
goto terminate-scripts

:policy-error:
print "Failed to publish policy for an unknown reason"
goto terminate-scripts
