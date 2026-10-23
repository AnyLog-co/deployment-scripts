on error ignore

:set-debug:
if !enable_debug == true then set debug on

:set-configs:
create_policy = false
hardware_id = get hardware id
barbara_id = $BARBARA_ID

:check-policy:
<is_policy = blockchain get orchestrator where
    type = "barbara" and
    company = !company_name and
    hardware = !hardware_id and
    barbara = !barbara_id
>

if not !is_policy and !create_policy == true then goto create-error
else if !is_policy then goto end-script

:define-policy:

<new_policy={
   "orchestrator": {
      "type": "barbara",
      "company": !company_name,
      "hardware": !hardware_id,
      "barbara": !barbara_id
}}>

:publish-policy:

process !local_scripts/node-deployment/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy


:end-script:
end script

:terminate-scripts:
exit scripts

:create-error:
echo "Failed to locate hzn policy post creation process"
goto end-script

:sign-policy-error:
print "Failed to sign !node_type policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member !node_type policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare !node_type policy on blockchain"
goto terminate-scripts


