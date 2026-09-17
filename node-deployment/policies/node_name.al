#----------------------------------------------------------------------------------------------------------------------#
# node name generator if $NODE_NAME not provided
# :logic:
#   if !node_type == operator then check if there's already a policy with the same cluster ID
#   if yes - add a backup operator
#   if no / !node_type != operator - then check number of nodes (not backup) of the same type
# :naming-logic:
#   master
#       acme-master1
#   query
#       acme-query1
#       acme-query2
#   operator
#       acme-operator1, acme-operator1-bkup1, acme-operator1-bkup2
#       acme-operator2, acme-operator2-bkup1
#       acme-operator3
#----------------------------------------------------------------------------------------------------------------------#
# process !local_scripts/node-deployment/policies/node_name.al


:blockchain-check:
on error ignore

# blockchain sync
run blockchain sync
blockchain reload metadata

# check if policy exists
process !local_scripts/node-deployment/policies/validate_node_policy.al

# extract policy ID, name and cluster ID
if !is_policy then
do policy_id = from !is_policy bring [*][id]
do node_name = from !is_policy bring [*][name]
if !node_type == operator and !is_policy then  cluster_id = from !is_policy bring [*][cluster]

# add warning if the blockchain defined node name differs from the user defined ENV param
if !node_name and $NODE_NAME and $NODE_NAME != !node_name then
do echo "Warning: the pre-defined node name for this is not the same as the requested node name"

:define-params;
if !cluster_id and !node_name then goto set-params

if $NODE_NAME then node_name = $NODE_NAME
else if not $NODE_NAME then node_name = !node_hostname + "-" + !node_company_name + "-" + !node_type + "-" + !rand_int

if $CLUSTER_NAME then cluster_name = $CLUSTER_NAME
else if not !cluster_name and !node_name then  cluster_name = "cluster-" + !node_name

:set-params:
set node name !node_name

:end-script:
end script
