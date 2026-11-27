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

on error ignore

:set-debug:
if !enable_debug == true then set debug on

if not !node_type == operator and not !node_name then goto set-node-name

:cluster-name:
if $CLUSTER_ID then cluster_id = $CLUSTER_ID
if $CLUSTER_NAME then cluster_name = $CLUSTER_NAME
if not !cluster_name and not !cluster_id then  cluster_name = "cluster-" + !node_hostname + "-" + !node_company_name + "-" + !node_type + "-" + !hardware_id

if !cluster_id then is_cluster = blockchain get cluster where id = !cluster_id
else if !cluster_name then !is_cluster = blockchain get cluster where name=!cluster_name and company=!company_name bring.first

if !cluster_id and not !is_cluster then goto missing-cluster
if !is_cluster then
do cluster_name = from !is_cluster bring [*][name]
do cluster_id   = from !is_cluster bring [*][id]

:node-name:
if $NODE_NAME and not !node_name then node_name = $NODE_NAME
else if not !node_name and not $NODE_NAME then node_name = !node_hostname + "-" + !node_company_name + "-" + !node_type + "-" + !hardware_id

:set-node-name:
if not !set_node_name or !set_node_name != true then
do set node name !node_name
do set set_node_name = true

:end-script:
if !enable_debug == true then set debug off
end script

:terminate-scripts:
exit scripts

:missing-cluster:
echo "Missing cluster with ID " + !cluster_id
goto terminate-scripts