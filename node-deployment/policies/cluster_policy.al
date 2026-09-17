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
set create_policy = false

run blockchain sync
blockchain reload metadata

:check-policy:
on error ignore
if !cluster_name and not !cluster_id then cluster_id = blockchain get cluster where name=!cluster_name and company=!company_name bring.first [*][id]

if !cluster_id then operator_count = blockchain get operator where cluster = !cluster_id

if $IS_MAIN and ($IS_MAIN == true or $IS_MAIN == True or $IS_MAIN == TRUE) then set is_main = true
else if $IS_MAIN and ($IS_MAIN == false or $IS_MAIN == False  or $IS_MAIN == FALSE) then set is_main = false
else if !operator_count then set is_main = false

if !cluster_id then goto end-script
if not !cluster_id and !create_policy == true then goto declare-policy-error

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

wait 5
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
