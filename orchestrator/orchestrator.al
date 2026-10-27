on error ignore

:generate policy:
if $HZN_DEVICE_ID or $HZN_NODE_ID then process !local_scripts/orchestrator/open_horizon.al
else if $BARBARA_ID then process !local_scripts/orchestrator/barbara.al
else goto end-script

:extract-id:
if !is_policy then orchestrator_id = from !is_policy bring [*][id]

:end-script:
end script