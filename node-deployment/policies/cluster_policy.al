#-----------------------------------------------------------------------------------------------------------------------
# Script to deploy a policy of type cluster
#
# ---- Sample Policy ---
# {'cluster' : {
#       'name' : 'litsanleandro-cluster1',
#       'company' : 'Lit San Leandro',
#       'id' : '0015392622f3eaac70eafa4311fc2338',
#       'date' : '2022-06-04T22:47:48.479532Z',
#       'status' : 'active',
#       'ledger' : 'global'
# }}
# ---- Sample Policy ---
#-----------------------------------------------------------------------------------------------------------------------
# process !local_scripts/node-deployment/policies/cluster_policy.al

on error ignore
:set-debug:
if !enable_debug == true then set debug on

set create_policy = false

:check-policy:
on error ignore

# checks nodes based on name, company and networking configurations
# this check for Operator node, but also creates a new cluster name / ID if needed
if $CLUSTER_NAME then cluster_id = blockchain get cluster where company=!company_name and name=$CLUSTER_NAME bring.first [*][id]
if !cluster_id then
do cluster_name = $CLUSTER_NAME
do goto check-primary

process !local_scripts/node-deployment/policies/validate_node_policy.al

if !create_policy == true and not !cluster_id and !cluster_name then
do cluster_id = blockchain get cluster where name=!cluster_name and company=!company_name bring.first [*][id]

if not !cluster_id and !create_policy == true then goto declare-policy-error
else if not !cluster_id and !create_policy == false then goto prep-policy

:check-primary:
if !cluster_id then operator_count = blockchain get operator where cluster = !cluster_id

if $IS_MAIN and $IS_MAIN == true then set is_main = true
else if $IS_MAIN and $IS_MAIN == false then set is_main = false
# operator count wil always be "" or numeric, it will not be 0 (at this time - 2026-10-07)
else if !operator_count then set is_main = false

if !cluster_id then goto end-script


:prep-policy:
on error ignore
new_policy = create policy cluster with defaults where company=!company_name and name=!cluster_name

:publish-policy:

set is_node_policy = true
process !local_scripts/node-deployment/policies/publish_policy.al
if !error_code == 1 then goto sign-policy-error
if !error_code == 2 then goto prepare-policy-error
if !error_code == 3 then goto declare-policy-error
set create_policy = true
set is_node_policy = false

goto check-policy

:end-script:
end script

:terminate-scripts:
exit scripts

:sign-policy-error:
print "Failed to sign cluster policy"
goto terminate-scripts

:prepare-policy-error:
print "Failed to prepare member cluster policy for publishing on blockchain"
goto terminate-scripts

:declare-policy-error:
print "Failed to declare cluster policy on blockchain"
goto terminate-scripts

:policy-error:
print "Failed to publish policy for an unknown reason"
goto terminate-scripts
