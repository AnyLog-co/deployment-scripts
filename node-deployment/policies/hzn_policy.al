
:set-debug:
if !enable_debug == true then set debug on

:set-configs:
create_policy = false

:check-policy:
if $HZN_DEVICE_ID then
<do is_policy = blockchain get hzn where
    node_id = $HZN_DEVICE_ID and
    org = $HZN_ORGANIZATION and
    hardware = $HZN_HARDWAREID>
else if $HZN_NODE_ID then
<do is_policy = blockchain get hzn where
    node_id = $HZN_NODE_ID and
    org = $HZN_ORGANIZATION and
    hardware = $HZN_HARDWAREID>
else goto end-script

if not !is_policy and !create_policy == true then goto create-error
else if !is_policy then goto end-script

:create-policy:
set new_policy = ""
set policy new_policy [hzn] = {}

if $HZN_DEVICE_ID then set policy new_policy [hzn][node_id] = !node_name
else if $HZN_NODE_ID then set policy new_policy [hzn][node_id] = $HZN_NODE_ID

if $HZN_ORGANIZATION then set policy new_policy [hzn][org] = $HZN_ORGANIZATION
if $HZN_EXCHANGE_URL then set policy new_policy [hzn][url] = $HZN_EXCHANGE_URL
if $HZN_HOST_IPS then set policy new_policy [hzn][ips] = $HZN_HOST_IPS
if $HZN_ARCH then set policy new_policy [hzn][arch] = $HZN_ARCH
if $HZN_HARDWAREID then set policy new_policy [hzn][hardware] = $HZN_HARDWAREID


set  is_privileged = ""
if $HZN_PRIVILEGED and $HZN_PRIVILEGED == true then set is_privileged = true
if $HZN_PRIVILEGED and $HZN_PRIVILEGED == false then set is_privileged = false

if !is_privileged then set policy new_policy [hzn][privileged] = !is_privileged.bool

if $HZN_PATTERN then set policy new_policy [hzn][pattern] = $HZN_PATTERN

:publish-policy:

process !local_scripts/node-deployment/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
goto check-policy


:end-script:
end script

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



